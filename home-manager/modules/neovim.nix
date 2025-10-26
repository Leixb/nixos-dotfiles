{
  pkgs,
  config,
  ...
}:
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

  telescope-orgmode = pkgs.vimUtils.buildVimPlugin {
    pname = "telescope-orgmode";
    version = "1.4.3";
    src = pkgs.fetchFromGitHub {
      owner = "nvim-orgmode";
      repo = "telescope-orgmode.nvim";
      rev = "1.4.3";
      sha256 = "sha256-6gZR1hJ8dqpnV/DFNn2htG3cPIu/USug4uQU/JS4RpI=";
    };
    doCheck = false;
  };

  # TODO: nvim-R / repl support

in
{

  # Packages needed for synctex
  home.packages = with pkgs; [
    xdotool
    neovim-remote
    pstree

    # orgmode export
    pandoc
    texliveBasic
    emacs
  ];

  programs.fish.shellAliases.agenda = "nvim -c 'lua Org.agenda.a()' ~/orgfiles/refile.org";

  # home.file.".Rprofile".text = ''
  #   .libPaths( c( .libPaths(), "${nvimcom}") )
  #   options(browser = "xdg-open")
  # '';

  home.file.".vale.ini".text = "";

  home.file."${config.xdg.configHome}/nvim/after/ftplugin/gitcommit.lua".text = # lua
    ''
      vim.opt.colorcolumn = "50,72"
    '';

  home.file."${config.xdg.configHome}/nvim/after/ftplugin/jjdescription.lua".text = # lua
    ''
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
      taplo

      dockerfile-language-server
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
        config = # lua
          ''
            vim.loader.enable()
            -- require'impatient'
          '';
      }

      vim-surround
      vim-repeat
      {
        plugin = unimpaired-nvim;
        type = "lua";
        config = # lua
          ''
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
        config = # lua
          ''
            require('git-conflict').setup()
          '';
      }

      vim-easy-align

      # Comment and uncomment lines
      {
        plugin = comment-nvim;
        type = "lua";
        config = # lua
          ''
            require'Comment'.setup()
          '';
      }

      {
        plugin = indent-blankline-nvim-lua;
        type = "lua";
        config = # lua
          ''
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
      {
        plugin = nvim-ts-context-commentstring;
        type = "lua";
        config = # lua
          ''
            require('nvim-treesitter.configs').setup {}
          '';
      }
      nvim-treesitter-refactor
      nvim-treesitter-endwise
      nvim-treesitter-textobjects
      {
        plugin = nvim-treesitter-context;
        type = "lua";
        config = # lua
          ''
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
        config = # lua
          ''
            require'todo-comments'.setup({
              highlight = {
                exclude = { "org" },
              },
            })
            vim.keymap.set('n', '<leader>t' , '<cmd>TodoTelescope<CR>' , { noremap = true , silent = true, desc = "List code with TODO annotations with telescope" })
          '';
      }

      {
        plugin = nvim-autopairs;
        type = "lua";
        config = # lua
          ''
            require'nvim-autopairs'.setup()
          '';
      }

      {
        plugin = whitespace-nvim;
        type = "lua";
        config = # lua
          ''
            require'whitespace-nvim'.setup({
              ignored_filetypes = { 'TelescopePrompt', 'Trouble', 'help', 'lspinfo' },
            })
            vim.api.nvim_create_user_command("Trim", require('whitespace-nvim').trim, { desc = "Trim trailing whitespace" })
          '';
      }

      {
        plugin = nvim-colorizer-lua;
        type = "lua";
        config = # lua
          ''
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
        config = # lua
          ''
            require'bufresize'.setup()
          '';
      }
      nvim-web-devicons

      {
        plugin = which-key-nvim;
        type = "lua";
        config = # lua
          ''
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

      conjure # repl
      cmp-conjure

      {
        plugin = sniprun;
        type = "lua";
        config = # lua
          ''
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
        plugin = pkgs.vimPlugins.hunk-nvim;
        type = "lua";
        config = # lua
          ''
            require'hunk'.setup()
          '';
      }

      {
        # Must go before grammar-guard, null-ls and other lsp things
        plugin = nvim-lspconfig;
        type = "lua";
        config = builtins.readFile ./neovim/lsp.lua;
      }

      {
        plugin = guess-indent-nvim;
        type = "lua";
        config = # lua
          ''
            require'guess-indent'.setup()
          '';
      }

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
      #   config = # lua
      #     ''
      #       require("lsp-format").setup({})
      #     '';
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
        config = # lua
          ''
            vim.keymap.set('n', '<F5>' , function() require'dapui'.toggle() end,
              { noremap = true , silent = true, desc = "DapUI toggle" })
          '';
      }

      {
        plugin = symbols-outline-nvim;
        type = "lua";
        config = # lua
          ''
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
        plugin = orgmode;
        type = "lua";
        config = # lua
          ''
            require('orgmode').setup({
              org_agenda_files = '~/orgfiles/**/*',
              org_default_notes_file = '~/orgfiles/refile.org',
              mappings = {
                org = {
                  org_refile = '<leader>o<S-r>',
                },
              },
              org_startup_indented = true,
              org_adapt_indentation = true,
              org_todo_keywords = { 'TODO(t)', 'WAITING', '|', 'DONE' },
              org_todo_keyword_faces = {
                WAITING = ':foreground lightblue :weight bold',
                REVIEWED = ':foreground orange :weight bold',
                MERGED = ':foreground lightgreen :weight bold',
                CLOSED = ':foreground lightgreen :weight bold :underline on',
                WIP = ':foreground #ED8796 :weight bold',
              },
              org_ellipsis = ' ...',
            })
            vim.api.nvim_create_autocmd('FileType', {
              pattern = 'org',
              callback = function()
                vim.keymap.set('i', '<S-CR>', '<cmd>lua require("orgmode").action("org_mappings.meta_return")<CR>', {
                  silent = true,
                  buffer = true,
                })
              end,
            })
          '';
      }
      {
        plugin = org-roam-nvim;
        type = "lua";
        config = # lua
          ''
            require('org-roam').setup({
                directory = '~/orgfiles/roam'
            })
          '';
      }
      {
        plugin = headlines-nvim;
        type = "lua";
        config = # lua
          ''
            require("headlines").setup({
              org = {
                fat_headlines = false,
              }
            })
          '';
      }
      {
        plugin = telescope-orgmode;
        type = "lua";
        config = # lua
        ''
          require('telescope').load_extension('orgmode')
          vim.keymap.set("n", "<leader>of", require("telescope").extensions.orgmode.search_headings, { desc = "Search headings" })
          vim.api.nvim_create_autocmd('FileType', {
            pattern = 'org',
            group = vim.api.nvim_create_augroup('orgmode_telescope_nvim', { clear = true }),
            callback = function()
              vim.keymap.set('n', '<leader>or', require('telescope').extensions.orgmode.refile_heading, { desc = "Refile Heading" })
              vim.keymap.set("n", "<leader>li", require("telescope").extensions.orgmode.insert_link, { desc = "Insert link" })
            end,
          })
        '';
      }

      {
        plugin = twilight-nvim;
        type = "lua";
        config = # lua
          ''
            require'twilight'.setup()
          '';
      }
      {
        plugin = zen-mode-nvim;
        type = "lua";
        config = # lua
          ''
            require'zen-mode'.setup()
          '';
      }
      {
        # Load after other plugins that use register_progress (e.g. lsp-status)
        plugin = fidget-nvim;
        type = "lua";
        config = # lua
          ''
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
    extraConfig = # lua
      ''
        luafile ${./neovim/init.lua}
      '';
  };

}
