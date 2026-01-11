{pkgs, ...}: {
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh.enable = true;
  services.chrony.enable = true;

  environment.systemPackages = with pkgs; [
    curl
    chrony
    file
    git
    killall
    less
    linux-firmware
    man-db
    ncurses
    noto-fonts
    openssh
    tmux
    rsync
    vim-full
    wget
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;
}
