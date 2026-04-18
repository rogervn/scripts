{ config, lib, pkgs, ... }:
let
  httpPort = 8014;
  cfg = config.services.joplinServer;
in {
  imports = [ ./podman.nix ];

  options.services.joplinServer = {
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/data/apps/joplin_server";
      description = "Host directory mounted into the container as /data";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "https://joplin.vnunes.win";
      description = "Public base URL for Joplin Server (used in SAML SP XML and APP_BASE_URL)";
    };
  };

  config = {
    # ── PostgreSQL ──────────────────────────────────────────────────────────────
    services.postgresql = {
      ensureDatabases = [ "joplin" ];
      ensureUsers = [{
        name = "joplin";
        ensureDBOwnership = true;
      }];
      # Add TCP auth for joplin user on the default podman bridge (10.88.0.0/16)
      # without removing the existing peer/trust rules used by immich + paperlessngx
      authentication = lib.mkAfter ''
        host joplin joplin 10.88.0.0/16 scram-sha-256
      '';
      # Also listen on the podman bridge gateway so the container can reach us via TCP
      settings.listen_addresses = lib.mkForce "localhost,10.88.0.1";
    };

    # One-shot service to set the joplin postgres user's password from the env file
    systemd.services.joplin-server-db-setup = {
      description = "Set Joplin Server PostgreSQL password";
      after = [ "postgresql.service" "postgresql-setup.service" ];
      requires = [ "postgresql.service" "postgresql-setup.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "postgres";
        EnvironmentFile = config.age.secrets.joplin_server_env_file.path;
      };
      script = ''
        ${config.services.postgresql.package}/bin/psql postgres -c \
          "ALTER ROLE \"$POSTGRES_USER\" WITH PASSWORD '$POSTGRES_PASSWORD';"
      '';
    };

    # ── SAML SP XML (non-secret, generated from Nix) ───────────────────────────
    environment.etc."joplin-server/joplin-sp.xml" = {
      text = ''
        <?xml version="1.0"?>
        <md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" entityID="joplin">
          <md:SPSSODescriptor AuthnRequestsSigned="false" WantAssertionsSigned="false" protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
            <md:NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress</md:NameIDFormat>
            <md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
              Location="${cfg.url}/api/saml"
              index="1" />
          </md:SPSSODescriptor>
        </md:EntityDescriptor>
      '';
      mode = "0644";
    };

    # ── OCI container ──────────────────────────────────────────────────────────
    virtualisation.oci-containers.containers.joplin_server = {
      image = "joplin/server:latest";
      ports = [ "${toString httpPort}:22300" ];
      environmentFiles = [ config.age.secrets.joplin_server_env_file.path ];
      environment = {
        APP_BASE_URL = cfg.url;
        API_BASE_URL = cfg.url;
        DB_CLIENT = "pg";
        POSTGRES_PORT = "5432";
        POSTGRES_HOST = "host.docker.internal";
        POSTGRES_DATABASE = "joplin";
        STORAGE_DRIVER = "Type=Filesystem; Path=/data";
        SAML_ENABLED = "true";
        SAML_IDP_CONFIG_FILE = "/etc/saml/joplin-idp.xml";
        SAML_SP_CONFIG_FILE = "/etc/saml/joplin-sp.xml";
        DELETE_EXPIRED_SESSIONS_SCHEDULE = "";
        LOCAL_AUTH_ENABLED = "false";
      };
      volumes = [
        "${cfg.dataDir}:/data"
        "/etc/joplin-server/joplin-sp.xml:/etc/saml/joplin-sp.xml:ro"
        "${config.age.secrets.joplin_idp_file.path}:/etc/saml/joplin-idp.xml:ro"
      ];
      extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
    };

    users.groups.joplin = { gid = 1001; };
    users.users.joplin = {
      uid = 1001;
      group = "joplin";
      isSystemUser = true;
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 joplin joplin -"
    ];

    networking.firewall.allowedTCPPorts = [ httpPort ];
    # Allow the container (podman bridge, podman0) to reach postgres on the host
    networking.firewall.interfaces.podman0.allowedTCPPorts = [ 5432 ];
  };
}
