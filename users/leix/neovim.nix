{ pkgs, inputs, ... }:
let
  nvim = pkgs.neovim-nightly;
in
  {
    programs.neovim = {
      enable = true;
      package = pkgs.neovim-nightly;

      extraPackages = with pkgs; [
        fd
        gcc
        git
        inputs.rnix-lsp.packages.x86_64-linux.rnix-lsp
        ripgrep
        zathura
      ];

    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars);
        type = "lua";
        config = builtins.readFile ./neovim/nvim-treesitter.lua;
      }

      nvim-ts-rainbow
      nvim-ts-autotag
      nvim-ts-context-commentstring
      nvim-treesitter-refactor

      vim-surround
      vim-repeat
      vim-eunuch
      vim-easy-align
      vim-commentary
      vim-rhubarb
      vim-fugitive

      editorconfig-nvim

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

      nvim-web-devicons

      lualine-lsp-progress
      {
        plugin = lualine-nvim;
        type = "lua";
        config = builtins.readFile ./neovim/lualine-nvim.lua;
      }

      barbar-nvim

      {
        plugin = nvim-notify;
        type = "lua";
        config = ''
          require'notify'.setup()
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

      lsp_signature-nvim

      cmp_luasnip
      friendly-snippets
      lspkind-nvim
      {
        plugin = telescope-nvim;
        type = "lua";
        config = builtins.readFile ./neovim/telescope.lua;
      }

      telescope-fzf-native-nvim

      plenary-nvim
      {
        plugin = rust-tools-nvim;
        type = "lua";
        config = builtins.readFile ./neovim/rust-tools-nvim.lua;
      }
      vimtex
      dart-vim-plugin
      julia-vim
      vim-fish
      vim-nix
      {
        plugin = nvim-metals;
        type = "lua";
        config = builtins.readFile ./neovim/nvim-metals.lua;
      }

      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = builtins.readFile ./neovim/gitsigns.lua;
      }
      gv-vim
      vim-grammarous
      grammar-guard-nvim
      copilot-vim
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = builtins.readFile ./neovim/lsp.lua;
      }
      nvim-lsp-ts-utils
      nvim-dap
      nvim-dap-ui
      symbols-outline-nvim

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
