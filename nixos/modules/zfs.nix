{
  config,
  lib,
  pkgs,
  ...
}: let
  zfsCompatibleKernelPackages =
    lib.filterAttrs (
      name: kernelPackages:
        (builtins.match "linux_[0-9]+_[0-9]+" name)
        != null
        && (builtins.tryEval kernelPackages).success
        && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
    )
    pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in {
  environment.systemPackages = with pkgs; [zfs];
  networking.hostId = "8425e349";
  boot.kernelPackages = lib.mkForce latestKernelPackage;
  boot.supportedFilesystems = ["zfs"];
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;
}
