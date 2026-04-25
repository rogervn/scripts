{
  userName,
  keyPath,
  ...
}: {
  age = {
    identityPaths = [keyPath];
    secrets = {
      serveruser_pass_hash = {
        file = ./secrets/serveruser_pass_hash.age;
        owner = "${userName}";
        group = "users";
        mode = "600";
      };
      serveruser_authorized_keys = {
        file = ./secrets/serveruser_authorized_keys.age;
        owner = "${userName}";
        group = "users";
        mode = "600";
      };
      vaultwarden_env_file = {
        file = ./secrets/vaultwarden_env_file.age;
        owner = "vaultwarden";
        group = "vaultwarden";
        mode = "600";
      };
      mininixos_backup_restic_pass = {
        file = ./secrets/mininixos_backup_restic_pass.age;
        owner = "root";
        group = "root";
        mode = "600";
      };
      cloudflared_token = {
        file = ./secrets/cloudflared_token.age;
        owner = "root";
        mode = "400";
      };
      tailscale_auth_key = {
        file = ./secrets/tailscale_auth_key.age;
        owner = "root";
        mode = "400";
      };
    };
  };
}
