{
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ohci_pci"
        "ehci_pci"
        "virtio_pci"
        "ahci"
        "usbhid"
        "sr_mod"
        "virtio_blk"
      ];
      kernelModules = [ ];
      luks.devices."cryptroot".device = "/dev/vda2";
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/cryptroot";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/vda1";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

  swapDevices = [
    {
      device = "/swapfile";
      size = 2048;
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
