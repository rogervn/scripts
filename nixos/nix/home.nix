{
  pkgs,
  userName,
  nixvim,
  ...
}: {
  targets.genericLinux.enable = true;
  home.stateVersion = "25.11";
  home.username = userName;
  home.homeDirectory = "/home/${userName}";
  programs.home-manager.enable = true;

  imports = [
    (import ../home/zsh.nix {inherit pkgs;})
    (import ../home/nvim.nix {inherit pkgs nixvim;})
    ({pkgs, ...}: {
      systemd.user.services.hyprpolkitagent = {
        Unit = {
          Description = "Hyprland Polkit Agent";
          After = ["graphical-session.target"];
        };
        Service = {
          ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = ["graphical-session.target"];
        };
      };
    })
  ];
}
