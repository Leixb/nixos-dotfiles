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
in
  {
    programs.neovim = {
      enable = true;

      extraPackages = with pkgs; [
        fd
        gcc
        git
        ltex-ls
        ripgrep
        rnix-lsp
      ];

    plugins = with pkgs.vimPlugins; [
      { # This must be the first plugin to load
        plugin = impatient-nvim;
        type = "lua";
        config = ''
          require'impatient'
        '';
      }

      plenary-nvim

      vim-surround
      vim-repeat
      vim-eunuch
      vim-commentary
      vim-rhubarb
      vim-fugitive

      vim-easy-align

      editorconfig-nvim

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
          vim.cmd[[colorscheme catppuccin]]
        '';
      }


      {
        plugin = lualine-nvim;
        type = "lua";
        config = builtins.readFile ./neovim/lualine-nvim.lua;
      }
      lualine-lsp-progress

      barbar-nvim
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
        type =  "lua";
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
      vimtex
      # dart-vim-plugin
      # julia-vim
      vim-fish
      vim-nix
      {
        plugin = nvim-metals;
        type = "lua";
        config = builtins.readFile ./neovim/nvim-metals.lua;
      }
      direnv-vim

      {
        plugin = gitsigns-nvim;
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

      copilot-vim

      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = builtins.readFile ./neovim/lsp.lua;
      }
      nvim-lsp-ts-utils
      lsp_signature-nvim
      lspkind-nvim
      nvim-code-action-menu

      nvim-dap
      nvim-dap-ui

      symbols-outline-nvim

      {
        plugin = neorg;
        type = "lua";
        config = builtins.readFile ./neovim/neorg.lua;
      }
    ];

    withPython3 = true;
    withRuby = true;
    withNodeJs = true;

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
