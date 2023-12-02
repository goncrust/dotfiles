" :SLoad       load a session
" :SSave[!]    save a session
" :SDelete[!]  delete a session
" :SClose      close a session

let g:startify_session_dir = '~/.config/nvim/session'

let g:startify_lists = [
          \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
          \ { 'type': 'files',     'header': ['   Recent']            },
          \ { 'type': 'dir',       'header': ['   Current Directory '. getcwd()] },
          \ { 'type': 'sessions',  'header': ['   Sessions']       },
          \ ]

let g:startify_bookmarks = [
            \ { 'c': '~/.xmonad/xmonad.hs' },
            \ { 'n': '~/.config/nvim/init.vim' },
            \ { 'z': '~/.zshrc' },
            \ '/first-hdd/dev',
            \ '/first-hdd/dev/SchoolProjects',
            \ ]

let g:startify_fortune_use_unicode = 1

let g:startify_custom_header = [
        \ '                                             _______________________',
        \ '   _______________________-------------------                       `\',
        \ ' /:--__                                                              |',
        \ '||< > |                                   ___________________________/',
        \ '| \__/_________________-------------------                         |',
        \ '|                                                                  |',
        \ ' |       Three Rings for the Elven-kings under the sky,             |',
        \ '  |        Seven for the Dwarf-lords in their halls of stone,        |',
        \ '  |      Nine for Mortal Men doomed to die,                          |',
        \ '  |        One for the Dark Lord on his dark throne                  |',
        \ '  |      In the Land of Mordor where the Shadows lie.                 |',
        \ '   |       One Ring to rule them all, One Ring to find them,          |',
        \ '   |       One Ring to bring them all and in the darkness bind them   |',
        \ '   |     In the Land of Mordor where the Shadows lie.                 |',
        \ '  |                                              ____________________|_',
        \ '  |  ___________________-------------------------                      `\',
        \ '  |/`--_                                                                 |',
        \ '  ||[ ]||                                            ___________________/',
        \ '   \===/___________________--------------------------',
        \]
