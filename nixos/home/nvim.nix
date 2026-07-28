{
  pkgs,
  nixvim,
  ...
}:
{
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  imports = [ nixvim.homeModules.nixvim ];

  home.packages = with pkgs; [
    ansible-lint
    black
    isort
    prettier
    nixfmt
    nil
    ripgrep
    rust-analyzer
    rustfmt
    shellcheck
    shfmt
    yamlfmt
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    nixpkgs.useGlobalPackages = true;
    luaLoader.enable = true;

    diagnostic.settings = {
      virtual_text = true;
      underline = true;
      severity_sort = true;
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    opts = {
      number = true;
      shiftwidth = 2;
      tabstop = 2;
      softtabstop = 2;
      expandtab = true;
      ignorecase = true;
      smartcase = true;
      smarttab = false;
      termguicolors = false;
    };

    extraPlugins = with pkgs.vimPlugins; [
      ansible-vim
      plenary-nvim
      popup-nvim
      vim-signify
    ];

    keymaps = [
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>y";
        action = "\"+y";
        options.desc = "Copy to system clipboard";
      }
      {
        mode = "n";
        key = "<leader>hp";
        action = "<cmd>SignifyHunkDiff<CR>";
        options.desc = "Preview hunk";
      }
      {
        mode = "n";
        key = "<leader>hr";
        action = "<cmd>SignifyHunkUndo<CR>";
        options.desc = "Undo hunk";
      }
      {
        mode = "n";
        key = "<leader>hd";
        action = "<cmd>SignifyDiff<CR>";
        options.desc = "Diff file";
      }
      {
        mode = "n";
        key = "<leader>hD";
        action = "<cmd>call SignifyDiffParent()<CR>";
        options.desc = "Diff file against parent commit";
      }
      {
        mode = "n";
        key = "<leader>hq";
        action = "<cmd>tabclose<CR>";
        options.desc = "Close diff tab";
      }
    ];

    plugins = {
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
          mapping = {
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
          };
        };
      };

      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = ''
            function(bufnr)
              return { timeout_ms = 500, lsp_fallback = true }
            end
          '';
          formatters = {
            yamlfmt = {
              prepend_args = [
                "-formatter"
                "retain_line_breaks=true"
              ];
            };
          };
          formatters_by_ft = {
            sh = [ "shfmt" ];
            markdown = [ "prettier" ];
            nix = [ "nixfmt" ];
            rust = [ "rustfmt" ];
            python = [
              "isort"
              "black"
            ];
            ansible = [ "yamlfmt" ];
            yaml = [ "yamlfmt" ];
            json = [ "prettier" ];
          };
        };
      };

      lsp = {
        enable = true;
        keymaps = {
          lspBuf = {
            "gd" = "definition";
            "gi" = "implementation";
            "gr" = "references";
            "K" = "hover";
            "<leader>rn" = "rename";
            "<leader>ca" = "code_action";
          };
        };
        servers = {
          bashls.enable = true;
          jsonls.enable = true;
          yamlls.enable = true;

          lua_ls = {
            enable = true;
            settings.telemetry.enable = false;
          };

          marksman.enable = true;
          nil_ls = {
            enable = true;
            settings = {
              formatting.command = [ "nixfmt" ];
            };
          };

          basedpyright = {
            enable = true;
            settings = {
              basedpyright = {
                analysis = {
                  typeCheckingMode = "basic";
                  autoSearchPaths = true;
                  useLibraryCodeForTypes = true;
                  diagnosticMode = "workspace";
                };
              };
            };
          };
        };
      };

      telescope = {
        enable = true;
        extensions = {
          fzf-native.enable = true;
        };
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
          "<leader>fh" = "help_tags";
        };
      };

      treesitter = {
        enable = true;
        highlight.enable = true;
        indent.enable = true;
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          bash
          diff
          dockerfile
          gitcommit
          gitignore
          hcl
          json
          lua
          make
          markdown
          markdown_inline
          nix
          python
          regex
          rust
          toml
          vim
          vimdoc
          yaml
        ];
      };

      lspkind = {
        enable = true;
        cmp.enable = true;
      };

      dressing.enable = true;
      fugitive.enable = true;
      which-key.enable = true;
      web-devicons.enable = true;
    };

    extraConfigVim = ''
      let g:signify_skip = {'vcs': {'allow': ['git', 'hg']}}

      function! SignifyDiffParent() abort
        let l:git_cmd = g:signify_vcs_cmds_diffmode.git
        let l:hg_cmd = g:signify_vcs_cmds_diffmode.hg
        try
          let g:signify_vcs_cmds_diffmode.git = 'git show HEAD~:./%f'
          let g:signify_vcs_cmds_diffmode.hg = 'hg cat --rev .^ %f'
          SignifyDiff
        finally
          let g:signify_vcs_cmds_diffmode.git = l:git_cmd
          let g:signify_vcs_cmds_diffmode.hg = l:hg_cmd
        endtry
      endfunction
    '';
  };
}
