{ pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.fzf.enable = true;
  programs.zsh = {
    enable = true;

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    history = {
      size = 130000;
      save = 130000;
      path = "$HOME/.histfile";
      ignoreAllDups = true;
      expireDuplicatesFirst = true;
      share = true;
    };

    defaultKeymap = "viins";

    completionInit = ''
      autoload -Uz compinit && compinit
      zstyle ':completion:*' menu select
      zstyle ':completion::complete:*' gain-privileges 1
      zstyle ':completion:*' rehash true
    '';

    initContent = ''
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      PROMPT_EOL_MARK=""
    '';
  };
}
