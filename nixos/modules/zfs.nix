{
  config,
  lib,
  pkgs,
  ...
}:
let
  zfsCompatibleKernelPackages = lib.filterAttrs (
    name: kernelPackages:
    (builtins.match "linux_[0-9]+_[0-9]+" name) != null
    && (builtins.tryEval kernelPackages).success
    && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
  ) pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in
{
  imports = [ ./smtp.nix ];

  options.myServices.zfsZed = {
    enableMail = lib.mkEnableOption "ZED mail notifications via msmtp";
  };

  config = {
    environment.systemPackages = with pkgs; [ zfs ];
    boot = {
      kernelPackages = lib.mkForce latestKernelPackage;
      kernelParams = [ "nohibernate" ];
      zfs.forceImportRoot = false;
      supportedFilesystems = [ "zfs" ];
    };
    services.zfs = {
      autoScrub.enable = true;
      autoSnapshot.enable = true;
      trim.enable = true;
      zed = lib.mkIf config.myServices.zfsZed.enableMail {
        enableMail = true;
        settings = {
          ZED_EMAIL_ADDR = [ "root" ];
          ZED_NOTIFY_VERBOSE = true;
        };
      };
    };
  };
}
