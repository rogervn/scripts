{ pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "vim";
  };
  home.packages = with pkgs; [
    nodejs
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

      highlight CocFloating ctermbg=Black ctermfg=Cyan
      highlight CocMenuSel ctermbg=Cyan ctermfg=Black
      highlight CocSearch ctermfg=Green ctermbg=Black gui=bold
      highlight CocHoverRange ctermbg=Black
      highlight CocCursorRange ctermbg=Black
    '';
  };
}
