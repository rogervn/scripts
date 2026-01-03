{
  userName,
  keyPath,
  ...
}: {
  age = {
    identityPaths = [keyPath];
    secrets = {
      backupuser_pass_hash = {
        file = ./secrets/backupuser_pass_hash.age;
        owner = "${userName}";
        group = "users";
        mode = "600";
      };
      backupuser_private_key = {
        file = ./secrets/backupuser_private_key.age;
        owner = "${userName}";
        group = "users";
        mode = "600";
      };
      backupuser_authorized_keys = {
        file = ./secrets/backupuser_authorized_keys.age;
        owner = "${userName}";
        group = "users";
        mode = "600";
      };
    };
  };
}
