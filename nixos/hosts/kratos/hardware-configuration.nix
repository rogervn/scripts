{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "uas"
        "sd_mod"
      ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    zswap.enable = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/2f85db78-18fd-48e8-9e85-42acf4059a56";
      fsType = "ext4";
    };

    "/data" = {
      device = "/dev/disk/by-uuid/e1869e7f-e166-4f06-8af4-bc1b1a0680f4";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/0DCA-DF2E";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024;
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
