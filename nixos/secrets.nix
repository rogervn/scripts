{userName, ...}:
{
  age = {
    identityPaths = [ "/root/.ssh/id_rsa" ];
    secrets = {
      rogervn_pass_hash = {
        file = ./secrets/rogervn_pass_hash.age;
        owner = "${userName}";
        group = "users";
        mode = "600";
      };
    };
  };
}
