{ pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "vim";
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
  programs.ghostty.installVimSyntax = true;
  programs.vim = {
    enable = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      ale
      coc-docker
      coc-json
      coc-nvim
      coc-yaml
      fzf-vim
      gruvbox
      polyglot
      vim-nix
    ];

    settings = {
      tabstop = 4;
      shiftwidth = 2;
      expandtab = true;
      copyindent = true;
      number = true;
      ignorecase = true;
      smartcase = true;
    };

    extraConfig = ''
      syntax enable
      set hlsearch
      set showmatch
      set softtabstop=1
      set nosmarttab

      let g:ale_fix_on_save = 1
      let g:ale_fixers = {
      \   'sh': ['shfmt'],
      \   'python': ['black'],
      \   'nix': ['nixfmt'],
      \   'rust': ['rustfmt'],
      \   'yaml': ['prettier'],
      \   'ansible': ['ansible-lint'],
      \   'dockerfile': ['hadolint'],
      \}

      inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
      inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#next(1) : "\<TAB>"
      inoremap <silent><expr> <S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<S-TAB>"

      highlight CocFloating ctermbg=Black ctermfg=Cyan
      highlight CocMenuSel ctermbg=Cyan ctermfg=Black
      highlight CocSearch ctermfg=Green ctermbg=Black gui=bold
      highlight CocHoverRange ctermbg=Black
      highlight CocCursorRange ctermbg=Black
    '';
  };
}
