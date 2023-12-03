require("goncrust.packer")
require("goncrust.colors")
require("goncrust.keymaps")

-- plugins
require("goncrust.plugins.treesitter")
require("goncrust.plugins.nvim-tree")
require("goncrust.plugins.startify")
vim.cmd("source $HOME/.config/nvim/lua/goncrust/plugins/airline.vim")
require("goncrust.plugins.lsp-config")

-- other config
vim.opt.hidden = true                              -- Required to keep multiple buffers open
vim.opt.wrap = false                               -- Display long lines as one line
vim.opt.encoding = 'utf-8'                         -- The encoding displayed
vim.opt.pumheight = 9                              -- Popup menu height
vim.opt.fileencoding = 'utf-8'                     -- The encoding written to a file
vim.opt.ruler = true                               -- Show the cursor position all the time
vim.opt.cmdheight = 2                              -- More space for displaying messages
vim.opt.mouse = 'a'                                -- Enable your mouse
vim.opt.splitbelow = true                          -- Horizontal splits will automatically be below
vim.opt.splitright = true                          -- Vertical splits will automatically be to the right
vim.opt.conceallevel = 0                           -- So that you can see `` in markdown files
vim.opt.tabstop = 4                                -- Number of columns occupied by a tab
vim.opt.softtabstop = 4                            -- See multiple spaces as tabstops so <BS> does the right thing
vim.opt.shiftwidth = 4                             -- Width for autoindents
vim.opt.smarttab = true                            -- Makes tabbing smarter
vim.opt.expandtab = true                           -- Converts tabs to spaces
vim.opt.laststatus = 0                             -- Always display the status line
vim.opt.number = true                              -- Show line numbers
vim.opt.relativenumber = true                      -- Show relative line numbers
vim.opt.cursorline = true                          -- Enable highlighting of the current line
vim.opt.showtabline = 2                            -- Always show tabs
vim.opt.showmode = false                           -- Don't show things like -- INSERT --
vim.opt.clipboard = 'unnamedplus'                  -- Copy paste between vim and everything else
vim.opt.ignorecase = true                          -- Case insensitive
vim.opt.hlsearch = true                            -- Highlight search
vim.opt.colorcolumn = '100'                        -- Set a 100 column border for good coding style
vim.opt.signcolumn = 'auto'                        -- Show signs in a new column
vim.opt.iskeyword:append('-')                      -- treat dash separated words as a word text object

-- Remember last position in file
local lastplace = vim.api.nvim_create_augroup("LastPlace", {})
vim.api.nvim_clear_autocmds({ group = lastplace })
vim.api.nvim_create_autocmd("BufReadPost", {
    group = lastplace,
    pattern = { "*" },
    desc = "remember last cursor place",
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Stop newline continuation of comments
vim.cmd([[ autocmd FileType * set formatoptions-=cro ]])

-- History setup
vim.opt.undodir = "/home/goncrust/.vim/undodir"
vim.opt.undofile = true
