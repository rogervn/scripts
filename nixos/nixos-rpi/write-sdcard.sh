#!/usr/bin/env bash

TARGET_LABEL="NIXOS_SD"

set -euo pipefail

# 1. Usage check
if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <image.img.zst> <device> <secrets_dir> <username>"
  echo "Example: $0 ./pi.img.zst /dev/sdb ./my-secrets rogervn"
  exit 1
fi

# 2. Automatic Sudo Elevation
if [ "$EUID" -ne 0 ]; then
  echo "Privileged access required for disk writing and mounting."
  echo "Re-running with sudo..."
  exec sudo "$0" "$@"
fi

IMG=$1
DEV=$2
SECRETS=$3
USER_NAME=$4

# Check for required tools
for tool in zstdcat dd mkpasswd lsblk; do
  if ! command -v "$tool" &>/dev/null; then
    echo "Error: Required tool '$tool' is not installed."
    exit 1
  fi
done

# 3. Interactive Password Collection
get_password() {
  local account_name=$1
  local var_name=$2 # The name of the variable to set
  local p1 p2
  while true; do
    echo "--- Setting password for: $account_name ---"
    read -r -s -p "Enter password: " p1
    echo
    read -r -s -p "Confirm password: " p2
    echo

    if [ "$p1" = "$p2" ] && [ -n "$p1" ]; then
      # Use printf to assign the value to the variable name passed in
      printf -v "$var_name" '%s' "$p1"
      return 0
    else
      echo -e "ERROR: Passwords do not match or are empty. Try again.\n"
    fi
  done
}

echo "Starting deployment setup..."
# Pass the variable names 'PASS_ROOT' as string
get_password "root" "PASS_ROOT"
get_password "$USER_NAME" "PASS_USER"

# 4. Confirmation and Unmounting
echo -e "\n--- Target Device Info ---"
lsblk "$DEV"
echo
read -r -p "ARE YOU SURE you want to overwrite ALL data on $DEV? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Aborting."
  exit 1
fi

echo "--- 1. Writing image to $DEV ---"
# Sparse skips writing the zeros from your swapfile pre-allocation
zstdcat "$IMG" | dd of="$DEV" bs=4M conv=fsync,sparse status=progress

sync
echo "Waiting for partitions to settle..."
sleep 3

# 5. Locate partition by Label using --raw to kill tree symbols
echo "--- 2. Locating $TARGET_LABEL Partition ---"
PROPOSED_PART_PATH=$(lsblk --raw -f -p -n -o NAME,LABEL "$DEV" | grep "$TARGET_LABEL" | awk '{print $1}' | head -n 1)

if [ -z "$PROPOSED_PART_PATH" ]; then
  echo "Warning: Could not find '$TARGET_LABEL' label on $DEV."
  lsblk "$DEV"
  read -r -p "Enter root partition path manually (e.g. /dev/sdb2): " ROOT_DEV
else
  read -r -p "Found $TARGET_LABEL at $PROPOSED_PART_PATH. Use this? (Y/n): " CONFIRM_PART
  if [[ "$CONFIRM_PART" =~ ^[Nn]$ ]]; then
    read -r -p "Enter partition path: " ROOT_DEV
  else
    ROOT_DEV="$PROPOSED_PART_PATH"
  fi
fi

# 6. Mounting and Injection
echo "--- 3. Mounting Root Partition ($ROOT_DEV) ---"
MNT=$(mktemp -d)
mount "$ROOT_DEV" "$MNT"

cleanup() {
  echo -e "\n--- Cleaning up ---"
  umount "$MNT" 2>/dev/null || true
  rmdir "$MNT" 2>/dev/null || true
}
trap cleanup EXIT

echo "--- 4. Injecting Secrets ---"
# Root SSH Key
mkdir -p "$MNT/root/.ssh"
if compgen -G "$SECRETS/id_*" >/dev/null; then
  cp "$SECRETS"/id_* "$MNT/root/.ssh/"
  chmod 600 "$MNT/root/.ssh"/id_*
  echo "Injected: SSH key(s)."
else
  echo "Warning: No files matching 'id_*' found in $SECRETS."
fi

# WiFi PSK (iwd)
mkdir -p "$MNT/var/lib/iwd"
if compgen -G "$SECRETS/*.psk" >/dev/null; then
  cp "$SECRETS"/*.psk "$MNT/var/lib/iwd/"
  chmod 700 "$MNT/var/lib/iwd"
  chmod 600 "$MNT/var/lib/iwd"/*.psk
  echo "Injected: WiFi configuration(s)."
fi

echo "--- 5. Setting Passwords ---"
HASH_ROOT=$(mkpasswd -m sha-512 "$PASS_ROOT")
HASH_USER=$(mkpasswd -m sha-512 "$PASS_USER")

# Create file if missing, or ensure it has entries for our users
mkdir -p "$MNT/etc"
for acct in "root" "$USER_NAME"; do
  if ! grep -q "^$acct:" "$MNT/etc/shadow" 2>/dev/null; then
    echo "$acct:!:19000:0:99999:7:::" >>"$MNT/etc/shadow"
  fi
done

chmod 600 "$MNT/etc/shadow"

# Inject the hash
sed -i "s#^root:[^:]*:#root:$HASH_ROOT:#" "$MNT/etc/shadow"
sed -i "s#^$USER_NAME:[^:]*:#$USER_NAME:$HASH_USER:#" "$MNT/etc/shadow"

echo "--- Finished! Syncing hardware... ---"
sync
echo "Done. You can now remove the SD card and boot your Pi."
