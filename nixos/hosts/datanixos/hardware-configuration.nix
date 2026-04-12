# Placeholder — will be overwritten by nixos-generate-config on first boot.
# After first boot, re-add the ZFS dataset mounts below manually.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ohci_pci" "ehci_pci" "virtio_pci" "virtio_scsi" "nvme" "ahci" "usbhid" "sr_mod" "virtio_blk"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5295b131-58d7-43e8-94d2-ea04a385a8f7";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/82B5-AAE2";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  swapDevices = [];

  # ZFS datasets — mounted from the 'data' pool
  fileSystems."/data/share/nfs" = {
    device = "data/share/nfs";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/data/share/smb" = {
    device = "data/share/smb";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/data/docker" = {
    device = "data/docker";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/data/backup" = {
    device = "data/backup";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
