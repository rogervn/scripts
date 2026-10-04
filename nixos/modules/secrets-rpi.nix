{
  config,
  userName,
  keyPath,
  ...
}:
{
  # Only the serveruser login secrets; the rest of secrets-serveruser.nix is mog-specific.
  age = {
    identityPaths = [ keyPath ];
    secrets = {
      serveruser_pass_hash.file = ./secrets/serveruser_pass_hash.age;
      serveruser_authorized_keys = {
        file = ./secrets/serveruser_authorized_keys.age;
        path = "/home/${userName}/.ssh/authorized_keys";
        owner = userName;
        group = "users";
        mode = "600";
      };
    };
  };

  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
    ];
    hashedPasswordFile = config.age.secrets.serveruser_pass_hash.path;
  };
  systemd.tmpfiles.rules = [ "d /home/${userName}/.ssh 0700 ${userName} users -" ];
}
