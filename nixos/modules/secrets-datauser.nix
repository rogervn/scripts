{
  userName,
  keyPath,
  ...
}: {
  age = {
    identityPaths = [keyPath];
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
        owner = "authentik";
        mode = "400";
      };
    };
  };
}
