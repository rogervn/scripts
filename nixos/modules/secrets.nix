{
  userName,
  keyPath,
  ...
}: {
  age = {
    identityPaths = [keyPath];
    secrets = {
      rogervn_pass_hash = {
        file = ./secrets/rogervn_pass_hash.age;
        owner = "${userName}";
        group = "users";
        mode = "600";
      };
      rogervn_private_key = {
        file = ./secrets/rogervn_private_key.age;
        owner = "${userName}";
        group = "users";
        mode = "600";
      };
      rogervn_authorized_keys = {
        file = ./secrets/rogervn_authorized_keys.age;
        owner = "${userName}";
        group = "users";
        mode = "600";
      };
    };
  };
}
