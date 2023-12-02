-- Setting mapleader to <Space>
vim.g.mapleader = ' '
vim.api.nvim_set_keymap('', '<Space>', '<Leader>', { noremap = true })

-- Better window navigation
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { noremap = true })

-- Use alt + hjkl to resize windows
vim.api.nvim_set_keymap('n', '<A-k>', ':resize -2<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<A-j>', ':resize +2<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<A-h>', ':vertical resize +2<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<A-l>', ':vertical resize -2<CR>', { noremap = true })

-- TAB in general mode will move to text buffer
vim.api.nvim_set_keymap('n', '<TAB>', ':bnext<CR>', { noremap = true })
-- SHIFT-TAB will go back
vim.api.nvim_set_keymap('n', '<S-TAB>', ':bprevious<CR>', { noremap = true })

-- Better nav for omnicomplete
vim.api.nvim_set_keymap('i', '<c-j>', '<C-n>', { expr = true })
vim.api.nvim_set_keymap('i', '<c-k>', '<C-p>', { expr = true })

-- Alternate way to save and quit
vim.api.nvim_set_keymap('n', '<C-s>', ':w<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-Q>', ':wq!<CR>', { noremap = true })

-- <TAB>: completion.
vim.api.nvim_set_keymap('i', '<TAB>', 'pumvisible() ? "<C-n>" : "<TAB>"', { expr = true })

-- Easy CAPS
vim.api.nvim_set_keymap('i', '<c-u>', '<ESC>viwUi', {})
vim.api.nvim_set_keymap('n', '<c-u>', 'viwU<Esc>', {})

-- Better tabbing
vim.api.nvim_set_keymap('v', '<', '<gv', { noremap = true })
vim.api.nvim_set_keymap('v', '>', '>gv', { noremap = true })

-- Move line or visually selected block - alt+j/k
vim.api.nvim_set_keymap('i', '<A-j>', '<Esc>:m .+1<CR>==gi', { noremap = true })
vim.api.nvim_set_keymap('i', '<A-k>', '<Esc>:m .-2<CR>==gi', { noremap = true })
vim.api.nvim_set_keymap('v', '<A-j>', ':m \'>+1<CR>gv=gv', { noremap = true })
vim.api.nvim_set_keymap('v', '<A-k>', ':m \'<-2<CR>gv=gv', { noremap = true })

-- Close current buffer without closing Neovim
vim.api.nvim_set_keymap('n', '<leader>q', ':bp<cr>:bd #<cr>', { noremap = true })
