-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    side = "left",
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
}) 

-- keybindings
vim.api.nvim_set_keymap("n", "<leader>f", ":NvimTreeToggle<cr>", {})

-- autoclose
vim.o.confirm = true
vim.api.nvim_create_autocmd("BufEnter", {
	group = vim.api.nvim_create_augroup("NvimTreeClose", {clear = true}),
	callback = function()
		local layout = vim.api.nvim_call_function("winlayout", {})
		if layout[1] == "leaf" and vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(layout[2]), "filetype") == "NvimTree" and layout[3] == nil then vim.cmd("quit") end
	end
})

-- startup
local function open_nvim_tree(data)
  -- open the tree
  require("nvim-tree.api").tree.open()

  -- focus on editor
  vim.cmd("wincmd p")
end
vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
