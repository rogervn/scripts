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
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "usbhid" "usb_storage" "sr_mod" "sdhci_pci"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/f4d458b2-2fff-48c2-ac2a-fdfce96dc4f6";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/833D-D2A6";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  # datasets are mounted automatically by zfs
  fileSystems."/data/share/nfs" = {
    device = "data/share/nfs";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  swapDevices = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
