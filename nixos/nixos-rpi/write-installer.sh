#!/usr/bin/env bash
# Build nvmd's Pi 5 installer and flash it with a chosen root password, ready for nixos-anywhere.

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <device>"
  echo "Example: $0 /dev/sdb"
  echo "Then boot the Pi from it and run nixos-anywhere as usual"
  exit 1
fi

DEV=$1
TARGET_LABEL="NIXOS_SD"
# Read by the installer's root-password activation script (flake.nix)
HASH_DEST="var/lib/installer/root-password-hash"
FLAKE_DIR=$(cd "$(dirname "$0")" && pwd)

for tool in nix zstdcat dd lsblk blockdev udevadm; do
  if ! command -v "$tool" &>/dev/null; then
    echo "Error: Required tool '$tool' is not installed."
    exit 1
  fi
done

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

while true; do
  read -r -s -p "Installer root password: " PASS
  echo
  read -r -s -p "Confirm password: " PASS2
  echo
  [ "$PASS" = "$PASS2" ] && [ -n "$PASS" ] && break
  echo "Passwords do not match or are empty. Try again."
done
HASH=$(printf '%s' "$PASS" | nix run nixpkgs#mkpasswd -- -m yescrypt --stdin)
unset PASS PASS2

echo "--- 1. Building installer image ---"
OUT=$(nix build --no-link --print-out-paths "$FLAKE_DIR#images.rpi5-installer")
IMG=$(find "$OUT/sd-image" -name '*.img.zst' | head -n 1)
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
zstdcat "$IMG" | sudo dd of="$DEV" bs=4M conv=fsync status=progress
sync
sudo blockdev --rereadpt "$DEV"
sudo udevadm settle

ROOT_DEV=$(lsblk -lnpo NAME,LABEL "$DEV" | awk -v l="$TARGET_LABEL" '$2 == l {print $1; exit}')
if [ -z "$ROOT_DEV" ]; then
  echo "Error: could not find '$TARGET_LABEL' partition on $DEV."
  lsblk -f "$DEV"
  exit 1
fi

echo "--- 3. Setting root password on $ROOT_DEV ---"
MNT=$(mktemp -d)
cleanup() {
  sudo umount "$MNT" 2>/dev/null || true
  rmdir "$MNT" 2>/dev/null || true
}
trap cleanup EXIT

sudo mount "$ROOT_DEV" "$MNT"
sudo install -d -m 700 "$MNT/$(dirname "$HASH_DEST")"
printf '%s\n' "$HASH" | sudo install -m 600 -o root -g root /dev/stdin "$MNT/$HASH_DEST"
sync

echo "Done. Boot the Pi from it; it registers as nixos-installer via DHCP and accepts root SSH with that password."
