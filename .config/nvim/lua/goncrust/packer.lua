-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd([[packadd packer.nvim]])

return require('packer').startup(function(use)
    -- Packer can manage itself
    use("wbthomason/packer.nvim")

    use("joshdick/onedark.vim")

    use("nvim-treesitter/nvim-treesitter", { run = ':TSUpdate' })

    use("nvim-tree/nvim-tree.lua")
    use("nvim-tree/nvim-web-devicons")

    use("mhinz/vim-startify")

    use("vim-airline/vim-airline")
    use("vim-airline/vim-airline-themes")

    use("williamboman/mason.nvim")
    use("williamboman/mason-lspconfig.nvim")
    use("neovim/nvim-lspconfig")

    use("hrsh7th/nvim-cmp")
    use("hrsh7th/cmp-buffer")
    use("hrsh7th/cmp-path")
    use("hrsh7th/cmp-cmdline")
    use("hrsh7th/cmp-nvim-lsp")

    use("L3MON4D3/LuaSnip")
    use("saadparwaiz1/cmp_luasnip")
    use("rafamadriz/friendly-snippets")

    use({
        "windwp/nvim-autopairs",
        config = function() require("nvim-autopairs").setup {} end
    })

    use("hrsh7th/cmp-nvim-lsp-signature-help")
end)
