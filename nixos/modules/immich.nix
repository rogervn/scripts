{ lib, ... }:
let
  httpPort  = 8009;
  mediaPath = "/data/apps/immich";
in {
  services.immich = {
    enable        = true;
    port          = httpPort;
    host          = "0.0.0.0";
    mediaLocation = mediaPath;
    # database.createLocally and redis.createLocally default to true
    # machine-learning.enable defaults to true
  };

  myServices.resticBackup.postgresqlBackup.databases = lib.mkAfter [ "immich" ];
  myServices.resticBackup.paths   = lib.mkAfter [ mediaPath ];
  myServices.resticBackup.exclude = lib.mkAfter [ "${mediaPath}/model-cache" ];

  networking.firewall.allowedTCPPorts = [httpPort];
}
