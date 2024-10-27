-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd.packadd('packer.nvim')

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use({'nvim-lua/plenary.nvim'})

  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.8',
	  -- or                            , branch = '0.1.x',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }

  use "miikanissi/modus-themes.nvim"
  vim.cmd.colorscheme("modus")

  use({
      "folke/trouble.nvim",
      config = function()
          require("trouble").setup {
              icons = false,
              -- your configuration comes here
              -- or leave it empty to use the default settings
              -- refer to the configuration section below
          }
      end
  })


  use({"nvim-treesitter/nvim-treesitter", run = ":TSUpdate"})
  use("theprimeagen/harpoon")
--   use("theprimeagen/refactoring.nvim")
  use("mbbill/undotree")
  use("tpope/vim-fugitive")
  use("nvim-treesitter/nvim-treesitter-context");

  use({"hrsh7th/nvim-cmp"})
  use({"hrsh7th/cmp-buffer"})
  use({"hrsh7th/cmp-path"})
  use({"hrsh7th/cmp-nvim-lsp"})
  use({"hrsh7th/cmp-nvim-lua"})
  use({"saadparwaiz1/cmp_luasnip"})
  use {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
  }

  -- use {
	--   'VonHeikemen/lsp-zero.nvim',
	--   branch = 'v1.x',
	--   requires = {
	-- 	  -- LSP Support
	-- 	  {'neovim/nvim-lspconfig'},
	-- 	  {'williamboman/mason.nvim'},
	-- 	  {'williamboman/mason-lspconfig.nvim'},

	-- 	  -- Autocompletion
	-- 	  {'hrsh7th/nvim-cmp'},
	-- 	  {'hrsh7th/cmp-buffer'},
	-- 	  {'hrsh7th/cmp-path'},
	-- 	  {'saadparwaiz1/cmp_luasnip'},
	-- 	  {'hrsh7th/cmp-nvim-lsp'},
	-- 	  {'hrsh7th/cmp-nvim-lua'},

	-- 	  -- Snippets
	-- 	  {'L3MON4D3/LuaSnip'},
	-- 	  {'rafamadriz/friendly-snippets'},
	--   }
  -- }

--   use("folke/zen-mode.nvim")
--   use("github/copilot.vim")
--   use("eandrju/cellular-automaton.nvim")
--   use("laytan/cloak.nvim")

end)
