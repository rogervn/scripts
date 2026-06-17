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
        mode = "v";
        key = "<C-S-c>";
        action = "\"+y";
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
      gitsigns = {
        enable = true;
        settings = {
          on_attach = ''
            function(bufnr)
              local gs = package.loaded.gitsigns

              local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
              end

              -- Navigation
              map('n', ']c', function()
                if vim.wo.diff then return ']c' end
                vim.schedule(function() gs.next_hunk() end)
                return '<Ignore>'
              end, {expr=true})

              map('n', '[c', function()
                if vim.wo.diff then return '[c' end
                vim.schedule(function() gs.prev_hunk() end)
                return '<Ignore>'
              end, {expr=true})

              -- Actions
              map('n', '<leader>hs', gs.stage_hunk)
              map('n', '<leader>hr', gs.reset_hunk)
              map('n', '<leader>hp', gs.preview_hunk)
              map('n', '<leader>hb', function() gs.blame_line{full=true} end)
              map('n', '<leader>hd', gs.diffthis)
              map('n', '<leader>hD', function() gs.diffthis('~') end)
            end
          '';
        };
      };
      web-devicons.enable = true;
    };

    extraConfigVim = ''
      let g:signify_vcs_list = ['git', 'hg']
    '';
  };
}
