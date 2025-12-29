{
  pkgs,
  inputs,
  ...
}: {
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  imports = [inputs.nixvim.homeModules.nixvim];

  home.packages = with pkgs; [
    alejandra
    black
    isort
    nodePackages.prettier
    nixfmt-rfc-style
    nil
    rust-analyzer
    rustfmt
    shellcheck
    shfmt
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    nixpkgs.useGlobalPackages = true;
    luaLoader.enable = true;
    colorscheme = "vim";

    diagnostic.settings = {
      virtual_text = true;
      underline = true;
      severity_sort = true;
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
      smartindent = true;
      termguicolors = false;
    };

    plugins = {
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          sources = [
            {name = "nvim_lsp";}
            {name = "path";}
            {name = "buffer";}
          ];
          mapping = {
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
          };
        };
        cmp-nvm-lsp.enable = true;
        cmp-path.enable = true;
        cmp-buffer.enable = true;
      };

      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = ''
            function(bufnr)
              return { timeout_ms = 500, lsp_fallback = true }
            end
          '';
          formatters_by_ft = {
            sh = ["shfmt"];
            markdown = ["prettier"];
            nix = ["alejandra"];
            rust = ["rustfmt"];
            python = [
              "isort"
              "black"
            ];
            yaml = ["yamlfmt"];
            json = ["prettier"];
          };
        };
      };

      lsp = {
        enable = true;
        keymaps = {
          "gd" = "definition";
          "gi" = "implementation";
          "gr" = "references";
          "K" = "hover";
          "<leader>rn" = "rename";
          "<leader>ca" = "code_action";
        };
        servers = {
          bashls.enable = true;
          jsonls.enable = true;
          lua_ls = {
            enable = true;
            settings.telemetry.enable = false;
          };
          marksman.enable = true;
          nil_ls = {
            enable = true;
            settings = {
              formatting.command = ["nixpkgs-fmt"];
            };
          };
          pyright = {
            enable = true;
            settings = {
              python = {
                analysis = {
                  typeCheckingMode = "basic";
                  autoSearchPaths = true;
                  useLibraryCodeForTypes = true;
                  diagnosticMode = "workspace";
                };
              };
            };
          };
          yamlls = {
            enable = true;
            extraOptions = {
              settings = {
                yaml = {
                  schemas = {
                    "http://json.schemastore.org/ansible-stable-2.9" = "roles/*/tasks/*.{yml,yaml}";
                    "http://json.schemastore.org/chart" = "Chart.{yml,yaml}";
                  };
                };
              };
            };
          };
        };
      };

      telescope = {
        enable = true;
        extensions = {fzf-native.enable = true;};
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
      };

      lspkind = {
        enable = true;
        cmp.enable = true;
      };

      lsp-format.enable = true;
      dressing.enable = true;
      fugitive.enable = true;
      web-devicons.enable = true;
    };
  };
}
