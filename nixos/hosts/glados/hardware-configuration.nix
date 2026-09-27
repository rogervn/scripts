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
      # systemd-cryptsetup keeps the LUKS passphrase in the kernel keyring so
      # greetd's PAM stack can unlock compatible credential stores during autologin.
      systemd.enable = true;
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
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 2048;
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
