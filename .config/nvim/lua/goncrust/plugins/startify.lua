-- Define the session directory
vim.g.startify_session_dir = '~/.config/nvim/session'

-- Startify lists configuration
vim.g.startify_lists = {
  { type = 'bookmarks', header = { '   Bookmarks' } },
  { type = 'files', header = { '   Recent' } },
  { type = 'dir', header = { '   Current Directory ' .. vim.fn.getcwd() } },
  { type = 'sessions', header = { '   Sessions' } },
}

-- Startify bookmarks
vim.g.startify_bookmarks = {
  { c = '~/.xmonad/xmonad.hs' },
  { n = '~/.config/nvim/init.vim' },
  { z = '~/.zshrc' },
  '/first-hdd/dev',
  '/first-hdd/dev/SchoolProjects',
}

-- Use Unicode in Startify fortune
vim.g.startify_fortune_use_unicode = 1

-- Startify custom header
vim.g.startify_custom_header = {
  '                                             _______________________',
  '   _______________________-------------------                       `\\',
  '/:--__                                                              |',
  '||< > |                                   ___________________________/',
  '| \\__/_________________-------------------                         |',
  '|                                                                  |',
  ' |       Three Rings for the Elven-kings under the sky,             |',
  '  |        Seven for the Dwarf-lords in their halls of stone,        |',
  '  |      Nine for Mortal Men doomed to die,                          |',
  '  |        One for the Dark Lord on his dark throne                  |',
  '  |      In the Land of Mordor where the Shadows lie.                 |',
  '   |       One Ring to rule them all, One Ring to find them,          |',
  '   |       One Ring to bring them all and in the darkness bind them   |',
  '   |     In the Land of Mordor where the Shadows lie.                 |',
  '  |                                              ____________________|_',
  '  |  ___________________-------------------------                      `\\',
  '  |/`--_                                                                 |',
  '  ||[ ]||                                            ___________________/',
  '   \\===/___________________--------------------------',
}
