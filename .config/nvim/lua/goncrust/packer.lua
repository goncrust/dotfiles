-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd([[packadd packer.nvim]])

return require('packer').startup(function(use)
  -- Packer can manage itself
  use("wbthomason/packer.nvim")

  use("joshdick/onedark.vim")

  use("nvim-treesitter/nvim-treesitter", {run = ':TSUpdate'})

  use("nvim-tree/nvim-tree.lua")
  use("nvim-tree/nvim-web-devicons")

  use("mhinz/vim-startify")

  use("vim-airline/vim-airline")
  use("vim-airline/vim-airline-themes")
end)
