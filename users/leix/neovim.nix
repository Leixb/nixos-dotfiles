{ pkgs, inputs, ... }:
let
  bufresize-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "bufresize-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "kwkarlwang";
      repo = "bufresize.nvim";
      rev = "3b19527ab936d6910484dcc20fb59bdb12322d8b";
      sha256 = "sha256-6jqlKe8Ekm+3dvlgFCpJnI0BZzWC3KDYoOb88/itH+g=";
    };
  };

  nvim-R = pkgs.vimUtils.buildVimPlugin {
    name = "nvim-R";
    src =  inputs.nvim-R;
  };

  nvimcom = pkgs.rPackages.buildRPackage {
    name = "nvimcom";
    src = inputs.nvim-R + "/R/nvimcom";
  } + "/library";

  # neorg_master = pkgs.vimUtils.buildVimPluginFrom2Nix {
  #   name = "neorg";
  #   src = inputs.neorg;
  # };
in {

  home.file.".Rprofile".text = ''
    .libPaths( c( .libPaths(), "${nvimcom}") )
    options(browser = "xdg-open")
  '';

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;

    extraPackages = with pkgs; [
      gcc
      git

      ## telescope
      ripgrep
      fd

      ## LSP
      ltex-ls
      ripgrep
      rnix-lsp
      sumneko-lua-language-server
      gopls
      texlab
      clang-tools

      nodePackages.dockerfile-language-server-nodejs
      nodePackages.typescript
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      nodePackages.yaml-language-server

      nodejs-16_x # copilot 14-17

      ## null-ls
      actionlint
      hadolint
      shellcheck
      stylua
      vale
    ];

    # plugins = with pkgs.vimPlugins; [
    plugins = with pkgs.trunk.vimPlugins; [
      { # This must be the first plugin to load
        plugin = impatient-nvim;
        type = "lua";
        config = ''
          require'impatient'
        '';
      }

      vim-surround
      vim-repeat
      vim-eunuch
      vim-commentary
      vim-rhubarb
      vim-fugitive

      vim-easy-align

      {
        plugin = editorconfig-nvim;
        type = "lua";
        config = ''
          vim.g.EditorConfig_exclude_patterns = {'fugitive://.*'},
        '';
      }

      {
        plugin = nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars);
        type = "lua";
        config = builtins.readFile ./neovim/nvim-treesitter.lua;
      }

      nvim-ts-rainbow
      nvim-ts-autotag
      nvim-ts-context-commentstring
      nvim-treesitter-refactor

      {
        plugin = telescope-nvim;
        type = "lua";
        config = builtins.readFile ./neovim/telescope.lua;
      }
      telescope-fzf-native-nvim

      {
        plugin = nvim-autopairs;
        type = "lua";
        config = ''
          require'nvim-autopairs'.setup()
        '';
      }

      {
        plugin = nvim-colorizer-lua;
        type = "lua";
        config = ''
          require'colorizer'.setup()
        '';
      }

      {
        plugin = catppuccin-nvim;
        type = "lua";
        config = ''
          vim.g.catppuccin_flavour = "macchiato" -- latte, frappe, macchiato, mocha
          vim.cmd.colorscheme("catppuccin")
        '';
      }

      {
        plugin = lualine-nvim;
        type = "lua";
        config = builtins.readFile ./neovim/lualine-nvim.lua;
      }
      lualine-lsp-progress

      {
        plugin = barbar-nvim;
        type = "lua";
        config = builtins.readFile ./neovim/barbar-nvim.lua;
      }
      {
        plugin = bufresize-nvim;
        type = "lua";
        config = ''
          require'bufresize'.setup()
        '';
      }
      nvim-web-devicons

      {
        plugin = nvim-notify;
        type = "lua";
        config = builtins.readFile ./neovim/nvim-notify.lua;
      }

      {
        plugin = nvim-cmp;
        type = "lua";
        config = builtins.readFile ./neovim/cmp.lua;
      }

      cmp-buffer
      cmp-path
      cmp-calc
      cmp-latex-symbols
      cmp-nvim-lua
      cmp-nvim-lsp

      {
        plugin = luasnip;
        type = "lua";
        config = builtins.readFile ./neovim/snippets.lua;
      }
      cmp_luasnip
      friendly-snippets

      {
        plugin = rust-tools-nvim;
        type = "lua";
        config = builtins.readFile ./neovim/rust-tools-nvim.lua;
      }
      {
        plugin = vimtex;
        type = "lua";
        config = builtins.readFile ./neovim/vimtex.lua;
      }

      # dart-vim-plugin
      # julia-vim
      nvim-luapad
      vim-fish
      vim-nix
      {
        plugin = nvim-R;
        type = "lua";
        config = ''
          vim.g.R_assign = 0
          vim.g.R_args = { "--no-save", "--quiet" }
          vim.g.R_nvimcom_home = "${nvimcom}"
        '';
      }
      {
        plugin = nvim-metals;
        type = "lua";
        config = builtins.readFile ./neovim/nvim-metals.lua;
      }
      direnv-vim

      {
        plugin = pkgs.vimPlugins.gitsigns-nvim-fixed;
        type = "lua";
        config = builtins.readFile ./neovim/gitsigns.lua;
      }
      gv-vim

      vim-grammarous
      {
        plugin = grammar-guard-nvim;
        type = "lua";
        config = builtins.readFile ./neovim/grammar-guard-nvim.lua;
      }

      {
        plugin = copilot-vim;
        type = "lua";
        config = builtins.readFile ./neovim/copilot-vim.lua;
      }

      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = builtins.readFile ./neovim/lsp.lua;
      }
      nvim-lsp-ts-utils
      lsp_signature-nvim
      lspkind-nvim
      nvim-code-action-menu

      {
        plugin = null-ls-nvim;
        type = "lua";
        config = builtins.readFile ./neovim/null-ls-nvim.lua;
      }

      {
        plugin = nvim-dap;
        type = "lua";
        config = builtins.readFile ./neovim/dap.lua;
      }
      {
        plugin = nvim-dap-ui;
        type = "lua";
        config = ''
          vim.keymap.set('n', '<F5>' , function() require'dapui'.toggle() end,
            { noremap = true , silent = true, desc = "DapUI toggle" })
        '';
      }

      {
        plugin = symbols-outline-nvim;
        type = "lua";
        config = ''
          vim.keymap.set('n', '<F4>' , function() require'symbols-outline'.toggle_outline() end,
            { noremap = true , silent = true, desc = "SymbolsOutline toggle" })
        '';
      }

      {
        # plugin = neorg_master;
        plugin = neorg;
        type = "lua";
        config = builtins.readFile ./neovim/neorg.lua;
      }

      {
        plugin = twilight-nvim;
        type = "lua";
        config = ''
          require'twilight'.setup()
        '';
      }
      {
        plugin = zen-mode-nvim;
        type = "lua";
        config = ''
          require'zen-mode'.setup()
        '';
      }

      {
        plugin = auto-session;
        type = "lua";
        config = builtins.readFile ./neovim/auto-session.lua;
      }
    ];

    withPython3 = true;
    withRuby = true;
    # withNodeJs = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # Add library code here for use in the Lua config from the
    # plugins list above.
    extraConfig = ''
      luafile ${./neovim/init.lua}
    '';
  };

}
