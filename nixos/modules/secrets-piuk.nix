{
  userName,
  keyPath,
  ...
}: {
  age = {
    identityPaths = [keyPath];
    secrets = {
      piuk_authorized_keys = {
        file = ./secrets/piuk_authorized_keys.age;
        owner = "${userName}";
        group = "users";
        mode = "600";
      };
    };
  };
}
