{ lib, ... }:
let
  httpPort = 8009;
  mediaPath = "/data/apps/immich";
in
{
  services.immich = {
    enable = true;
    port = httpPort;
    host = "0.0.0.0";
    mediaLocation = mediaPath;
    # database.createLocally and redis.createLocally default to true
    # machine-learning.enable defaults to true
  };

  # Pinned so a reinstall keeps ownership of the data on ZFS
  users = {
    users.immich.uid = 994;
    groups.immich.gid = 995;
  };

  myServices.resticBackup = {
    postgresqlBackup.databases = lib.mkAfter [ "immich" ];
    paths = lib.mkAfter [ mediaPath ];
    exclude = lib.mkAfter [ "${mediaPath}/model-cache" ];
  };

  networking.firewall.allowedTCPPorts = [ httpPort ];
}
