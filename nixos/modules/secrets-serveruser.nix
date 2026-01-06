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
    };
  };
}
