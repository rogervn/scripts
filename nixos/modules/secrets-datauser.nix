{
  userName,
  keyPath,
  ...
}:
{
  age = {
    identityPaths = [ keyPath ];
    secrets = {
      datauser_pass_hash = {
        file = ./secrets/datauser_pass_hash.age;
        owner = "${userName}";
        group = "users";
        mode = "600";
      };
      datauser_private_key = {
        file = ./secrets/datauser_private_key.age;
        owner = "${userName}";
        group = "users";
        mode = "600";
      };
      datauser_authorized_keys = {
        file = ./secrets/datauser_authorized_keys.age;
        owner = "${userName}";
        group = "users";
        mode = "600";
      };
      authentik_env_file = {
        file = ./secrets/authentik_env_file.age;
        owner = "root";
        mode = "400";
      };
      paperlessngx_env_file = {
        file = ./secrets/paperlessngx_env_file.age;
        owner = "paperless";
        mode = "400";
      };
      joplin_server_env_file = {
        file = ./secrets/joplin_server_env_file.age;
        owner = "root";
        group = "postgres";
        mode = "440";
      };
      joplin_idp_file = {
        file = ./secrets/joplin_idp_file.age;
        mode = "444";
      };
      nextcloud_admin_pass = {
        file = ./secrets/nextcloud_admin_pass.age;
        owner = "nextcloud";
        mode = "400";
      };
      smtp_password = {
        file = ./secrets/smtp_password.age;
        owner = "root";
        mode = "400";
      };
      datanixos_restic_pass = {
        file = ./secrets/datanixos_restic_pass.age;
        owner = "root";
        mode = "400";
      };
      datanixos_rclone_env = {
        file = ./secrets/datanixos_rclone_env.age;
        owner = "root";
        mode = "400";
      };
      datanixos_backupuser_authorized_keys = {
        file = ./secrets/datanixos_backupuser_authorized_keys.age;
        path = "/etc/ssh/authorized_keys.d/backupuser";
        owner = "backupuser";
        group = "backupuser";
        mode = "400";
      };
      # mode 444: beszel-agent runs under a systemd DynamicUser, so the file
      # must be world-readable since it can't be chowned to a fixed uid.
      beszel_hub_key_file = {
        file = ./secrets/beszel_hub_key_file.age;
        mode = "444";
      };
      datanixos_beszel_token_file = {
        file = ./secrets/datanixos_beszel_token_file.age;
        mode = "444";
      };
    };
  };
}
