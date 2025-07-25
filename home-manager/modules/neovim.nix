{ pkgs, config, inputs, ... }:
let
  bufresize-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "bufresize-nvim";
    version = "2021-03-21";
    src = pkgs.fetchFromGitHub {
      owner = "kwkarlwang";
      repo = "bufresize.nvim";
      rev = "3b19527ab936d6910484dcc20fb59bdb12322d8b";
      sha256 = "sha256-6jqlKe8Ekm+3dvlgFCpJnI0BZzWC3KDYoOb88/itH+g=";
    };
  };

  # TODO: nvim-R / repl support

in
{

  # Packages needed for synctex
  home.packages = with pkgs; [
    xdotool
    neovim-remote
    pstree
  ];

  # home.file.".Rprofile".text = ''
  #   .libPaths( c( .libPaths(), "${nvimcom}") )
  #   options(browser = "xdg-open")
  # '';

  home.file.".vale.ini".text = "";

  home.file."${config.xdg.configHome}/nvim/after/ftplugin/gitcommit.lua".text = ''
    vim.opt.colorcolumn = "50,72"
  '';

  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.NVIM_PACKAGE = config.programs.neovim.finalPackage;

  programs.neovim = {
    enable = true;
    defaultEditor = true;

    extraPackages = with pkgs; [
      gcc
      git

      ## telescope
      ripgrep
      fd

      ## LSP
      ltex-ls
      ripgrep
      # rnix-lsp
      nil
      lua-language-server
      gopls
      texlab
      clang-tools
      marksman

      nodePackages.dockerfile-language-server-nodejs
      nodePackages.typescript
      nodePackages.typescript-language-server
      # nodePackages.vscode-langservers-extracted
      nodePackages.yaml-language-server

      nodejs

      actionlint
      hadolint
      shellcheck
      stylua
      vale

      vscode-langservers-extracted
    ];

    plugins = with pkgs.vimPlugins; [
      {
        # This must be the first plugin to load
        plugin = impatient-nvim;
        type = "lua";
        config = ''
          vim.loader.enable()
          -- require'impatient'
        '';
      }

      vim-surround
      vim-repeat
      {
        plugin = unimpaired-nvim;
        type = "lua";
        config = ''
          require('unimpaired').setup()
        '';
      }

      # Automatic detection of indentation settings
      vim-eunuch

      # Git plugins
      vim-rhubarb
      vim-fugitive
      {
        plugin = git-conflict-nvim;
        type = "lua";
        config = ''
          require('git-conflict').setup()
        '';
      }

      vim-easy-align

      # Comment and uncomment lines
      {
        plugin = comment-nvim;
        type = "lua";
        config = ''
          require'Comment'.setup()
        '';
      }

      {
        plugin = indent-blankline-nvim-lua;
        type = "lua";
        config = ''
          require'ibl'.setup()
        '';
      }

      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config = builtins.readFile ./neovim/nvim-treesitter.lua;
      }

      rainbow-delimiters-nvim
      nvim-ts-autotag
      # {
      #   plugin = nvim-ts-context-commentstring;
      #   type = "lua";
      #   config = ''
      #     require('nvim-treesitter.configs').setup {}
      #   '';
      # } # TODO: check is this ever gets fixed: https://github.com/JoosepAlviste/nvim-ts-context-commentstring/issues/103
      nvim-treesitter-refactor
      nvim-treesitter-endwise
      nvim-treesitter-textobjects
      {
        plugin = nvim-treesitter-context;
        type = "lua";
        config = ''
          require('treesitter-context').setup {
            enable = true,
            max_lines = 10, -- How many lines the window should span. Values <= 0 mean no limit.
            min_window_height = 40, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
            multiline_threshold = 7, -- Maximum number of lines to show for a single context
          }
        '';
      }

      {
        plugin = telescope-nvim;
        type = "lua";
        config = builtins.readFile ./neovim/telescope.lua;
      }
      telescope-fzf-native-nvim

      vim-tmux-navigator

      {
        plugin = todo-comments-nvim;
        type = "lua";
        config = ''
          require'todo-comments'.setup()
          vim.keymap.set('n', '<leader>t' , '<cmd>TodoTelescope<CR>' , { noremap = true , silent = true, desc = "List code with TODO annotations with telescope" })
        '';
      }

      {
        plugin = nvim-autopairs;
        type = "lua";
        config = ''
          require'nvim-autopairs'.setup()
        '';
      }

      {
        plugin = whitespace-nvim;
        type = "lua";
        config = ''
          require'whitespace-nvim'.setup({
            ignored_filetypes = { 'TelescopePrompt', 'Trouble', 'help', 'lspinfo' },
          })
          vim.api.nvim_create_user_command("Trim", require('whitespace-nvim').trim, { desc = "Trim trailing whitespace" })
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
        config = builtins.readFile ./neovim/catppuccin.lua;
      }

      {
        plugin = lualine-nvim;
        type = "lua";
        config = builtins.readFile ./neovim/lualine-nvim.lua;
      }

      {
        plugin = bufferline-nvim;
        type = "lua";
        config = builtins.readFile ./neovim/bufferline-nvim.lua;
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
        plugin = which-key-nvim;
        type = "lua";
        config = ''
          require'which-key'.setup()
        '';
      }

      nvim-bqf

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
      cmp-cmdline
      cmp-git

      {
        plugin = luasnip;
        type = "lua";
        config = builtins.readFile ./neovim/snippets.lua;
      }
      cmp_luasnip
      friendly-snippets

      {
        plugin = vimtex;
        type = "lua";
        config = builtins.readFile ./neovim/vimtex.lua;
      }

      # dart-vim-plugin
      # julia-vim
      haskell-tools-nvim
      nvim-luapad
      vim-fish
      vim-nix
      {
        plugin = nvim-metals;
        type = "lua";
        config = builtins.readFile ./neovim/nvim-metals.lua;
      }
      direnv-vim

      {
        plugin = sniprun;
        type = "lua";
        config = ''
          require'sniprun'.setup({
            repl_enable = {'Julia_original'},
            display = { "TerminalWithCode" },
          })
        '';
      }

      {
        plugin = pkgs.vimPlugins.gitsigns-nvim;
        type = "lua";
        config = builtins.readFile ./neovim/gitsigns.lua;
      }
      gv-vim

      {
        # Must go before grammar-guard, null-ls and other lsp things
        plugin = nvim-lspconfig;
        type = "lua";
        config = builtins.readFile ./neovim/lsp.lua;
      }

      {
        plugin = guess-indent-nvim;
        type = "lua";
        config = ''
          require'guess-indent'.setup()
        '';
      }

      vim-grammarous
      {
        plugin = grammar-guard-nvim;
        type = "lua";
        config = builtins.readFile ./neovim/grammar-guard-nvim.lua;
      }

      nvim-lsp-ts-utils
      lsp_signature-nvim
      lspkind-nvim
      # {
      #   plugin = lsp-format-nvim;
      #   type = "lua";
      #   config = ''
      #     require("lsp-format").setup({})
      #   '';
      # }
      {
        plugin = rust-tools-nvim;
        type = "lua";
        config = builtins.readFile ./neovim/rust-tools-nvim.lua; # After lsp.lua
      }

      {
        plugin = none-ls-nvim;
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
        plugin = neorg;
        type = "lua";
        config = builtins.readFile ./neovim/neorg.lua;
      }
      neorg-telescope

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
        # Load after other plugins that use register_progress (e.g. lsp-status)
        plugin = fidget-nvim;
        type = "lua";
        config = ''
          require'fidget'.setup()
        '';
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
