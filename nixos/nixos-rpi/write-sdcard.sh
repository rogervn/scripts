#!/usr/bin/env bash
# Build a Pi SD image and flash it, then copy an extra-files dir onto its root (like nixos-anywhere --extra-files)
# and optionally an iwd WiFi profile. Login secrets are decrypted by agenix on first boot.

set -euo pipefail
# ASCII-only character classes, matching iwd's SSID file-name rule
export LC_ALL=C

TARGET_LABEL="NIXOS_SD"
# agenix identity; must match keyPath in flake.nix
KEY_DEST="root/.ssh/id_ed25519"

if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
  echo "Usage: $0 <host> <device> <extra_files_dir> [wifi_ssid]"
  echo "Example: $0 pichu /dev/sdb ~/secrets"
  echo "extra_files_dir mirrors / on the Pi and must contain $KEY_DEST."
  echo "With an SSID, the WiFi passphrase is prompted for and written as an iwd profile."
  exit 1
fi

HOST=$1
DEV=$2
EXTRA=$3
SSID=${4:-}
FLAKE_DIR=$(cd "$(dirname "$0")" && pwd)

for tool in nix zstdcat dd lsblk blockdev udevadm tar; do
  if ! command -v "$tool" &>/dev/null; then
    echo "Error: Required tool '$tool' is not installed."
    exit 1
  fi
done

[ -f "$EXTRA/$KEY_DEST" ] || {
  echo "Error: '$EXTRA/$KEY_DEST' not found; the agenix identity key is required."
  exit 1
}
if [ -n "$SSID" ]; then
  if [ "$(printf '%s' "$SSID" | wc -c)" -gt 32 ]; then
    echo "Error: SSID is longer than 32 bytes."
    exit 1
  fi
  while true; do
    read -r -s -p "WiFi passphrase for '$SSID': " PASS
    echo
    read -r -s -p "Confirm passphrase: " PASS2
    echo
    [ "$PASS" = "$PASS2" ] && [ ${#PASS} -ge 8 ] && [ ${#PASS} -le 63 ] && break
    echo "Passphrases do not match or are not 8-63 characters. Try again."
  done
  # iwd stores SSIDs with other characters hex-encoded as "=<hex>" (iwd.network(5))
  if [[ "$SSID" =~ ^[A-Za-z0-9_\ -]+$ ]]; then
    PSK_NAME="$SSID.psk"
  else
    PSK_NAME="=$(printf '%s' "$SSID" | od -An -tx1 | tr -d ' \n').psk"
  fi
fi
[ "$(lsblk -dno TYPE "$DEV" 2>/dev/null)" = "disk" ] || {
  echo "Error: $DEV is not a whole disk."
  exit 1
}
# Refuse internal disks: only removable, USB or SD/MMC devices
read -r RM TRAN < <(lsblk -dno RM,TRAN "$DEV")
if [ "$RM" != "1" ] && [ "${TRAN:-}" != "usb" ] && [[ "$DEV" != /dev/mmcblk* ]]; then
  echo "Error: $DEV is not a removable, USB or SD/MMC device."
  exit 1
fi

echo "--- 1. Building image for $HOST ---"
OUT=$(nix build --no-link --print-out-paths "$FLAKE_DIR#images.$HOST")
IMG=$(find "$OUT/sd-image" -name '*.img*' | head -n 1)
[ -n "$IMG" ] || {
  echo "Error: no image found in $OUT/sd-image."
  exit 1
}
echo "Image: $IMG"

echo -e "\n--- Target Device Info ---"
lsblk -o NAME,SIZE,MODEL,LABEL,MOUNTPOINTS "$DEV"
echo
read -r -p "ARE YOU SURE you want to overwrite ALL data on $DEV? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Aborting."
  exit 1
fi

echo "--- 2. Writing image to $DEV ---"
for part in $(lsblk -lnpo NAME "$DEV" | tail -n +2); do
  sudo umount "$part" 2>/dev/null || true
done
if [[ "$IMG" == *.zst ]]; then
  zstdcat "$IMG" | sudo dd of="$DEV" bs=4M conv=fsync status=progress
else
  sudo dd if="$IMG" of="$DEV" bs=4M conv=fsync status=progress
fi
sync
sudo blockdev --rereadpt "$DEV"
sudo udevadm settle

ROOT_DEV=$(lsblk -lnpo NAME,LABEL "$DEV" | awk -v l="$TARGET_LABEL" '$2 == l {print $1; exit}')
if [ -z "$ROOT_DEV" ]; then
  echo "Error: could not find '$TARGET_LABEL' partition on $DEV."
  lsblk -f "$DEV"
  exit 1
fi

echo "--- 3. Injecting secrets into $ROOT_DEV ---"
MNT=$(mktemp -d)
cleanup() {
  sudo umount "$MNT" 2>/dev/null || true
  rmdir "$MNT" 2>/dev/null || true
}
trap cleanup EXIT

sudo mount "$ROOT_DEV" "$MNT"
# --no-overwrite-dir keeps the image's modes on existing dirs such as / and /root
tar -C "$EXTRA" --owner=0 --group=0 -cf - . | sudo tar -C "$MNT" --no-overwrite-dir -xpf -
sudo chmod 700 "$MNT/$(dirname "$KEY_DEST")"
sudo chmod 600 "$MNT/$KEY_DEST"
echo "Injected: extra files from $EXTRA."
if [ -n "$SSID" ]; then
  sudo install -d -m 700 "$MNT/var/lib/iwd"
  printf '[Security]\nPassphrase=%s\n' "$PASS" |
    sudo install -m 600 -o root -g root /dev/stdin "$MNT/var/lib/iwd/$PSK_NAME"
  echo "Injected: WiFi profile for '$SSID'."
fi
sync

echo "Done. Boot the Pi; it will join the network and register as $HOST."
