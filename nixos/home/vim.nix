{ pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.packages = with pkgs; [
    ansible
    ansible-lint
    docker-compose-language-service
    hadolint
    nodejs
    nixfmt-rfc-style
    nil
    (python3.withPackages (
      ps: with ps; [
        black
        pyright
      ]
    ))
    rust-analyzer
    rustfmt
    shellcheck
    shfmt
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      coc-docker
      coc-json
      coc-yaml
      fzf-vim
      polyglot
      vim-nix
      {
        plugin = ale;
        config = ''
          let g:ale_fix_on_save = 1

          let g:ale_fixers = {
            \ 'sh': ['shfmt'],
            \ 'python': ['black'],
            \ 'nix': ['nixfmt'],
            \ 'rust': ['rustfmt'],
            \ 'yaml': ['prettier'],
            \ 'dockerfile': ['hadolint'],
          \ }
        '';
      }
      {
        plugin = coc-nvim;
        config = ''
          inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
          inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#next(1) : "\<TAB>"
          inoremap <silent><expr> <S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<S-TAB>"
        '';
      }
    ];

    coc = {
      enable = true;
      settings = {
        "suggest.noselect" = true;
        "suggest.enablePreview" = true;
        "suggest.snippetIndicator" = " ►";
        "suggest.triggerAfterInsertEnter" = true;
        "diagnostic.displayByAle" = true;

        "languageserver" = {
          "nix" = {
            "command" = "nil";
            "filetypes" = [ "nix" ];
            "rootPatterns" = [ "flake.nix" ];
          };
        };

        "python.formatting.provider" = "black";
        "python.linting.enabled" = true;
      };
    };

    extraConfig = ''
      set number
      set tabstop=2
      set shiftwidth=2
      set expandtab
      set ignorecase
      set smartcase
      set softtabstop=1
      set nosmarttab
    '';

  };
}
