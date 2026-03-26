(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Basics
(setq inhibit-startup-message t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq display-line-numbers-type 'visual)
(global-display-line-numbers-mode t)
(setq scroll-step 1
      scroll-conservatively 1000
      scroll-margin 5)

(global-whitespace-mode 1)
(setq whitespace-style '(face    ; Use font-lock faces to colorize
                         spaces  ; Highlight spaces
                         space-mark ; Use a special character for spaces
                         trailing ; Highlight trailing blanks
                         ;lines-tail ; Highlight lines beyond 'fill-column'
                         space-before-tab ; Highlight spaces before tabs
                         indentation ; Highlight improper indentation
                         empty    ; Highlight empty lines at top/bottom
                         ;newline  ; Highlight newlines
                         ;newline-mark ; Use a special character for newlines
                         tabs    ; Highlight tabs
                         tab-mark))   ; Use a special character for tabs

(setq-default fill-column 120)                  ; Set the default width
(global-display-fill-column-indicator-mode 1)  ; Enable the vertical ruler globally

(setq-default indent-tabs-mode nil) ; Use spaces instead of tabs
(setq-default tab-width 4)          ; Set width to 4
(setq tab-always-indent nil)  ; Try to indent, then try to complete

(global-set-key (kbd "C-x C-b") 'ibuffer)

;; Package management
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Evil mode
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-undo-system 'undo-fu)
  (setq evil-symbol-word-search t)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package undo-fu)

;; Better navigation, UI, etc
(use-package vertico
  :init
  (vertico-mode)
  :bind (:map vertico-map
          ("C-j" . vertico-next)
          ("C-k" . vertico-previous)))

(use-package marginalia
  :init
  (marginalia-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic)))

(use-package consult
  :bind (("C-x b" . consult-buffer))
  :bind (("C-c r" . consult-ripgrep)))

(use-package which-key
  :init
  (which-key-mode)
  :config
  (setq which-key-idle-delay 0.3))

;; Modeline
(use-package doom-modeline
  :init
  (doom-modeline-mode 1))

;; Theme
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)

  (load-theme 'doom-ir-black t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

;; Font
(set-face-attribute 'default nil :font "Hack" :height 130)

;; Save place and history
(use-package savehist
  :config
  (savehist-mode))

(use-package saveplace
  :config
  (save-place-mode 1))

;; parens
(electric-pair-mode 1)
(show-paren-mode 1)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Magit
(use-package magit
  :bind ("C-c g" . magit-status))

;; Dired
(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired
  :ensure nil  ; Dired is built-in
  :config
  ;; Allow 'dired-find-alternate-file' to run without a warning
  (put 'dired-find-alternate-file 'disabled nil)

  (with-eval-after-load 'evil
    ;; Global bind for '-' to jump into Dired from any buffer
    (define-prefix-command 'my-dired-prefix)
    (evil-define-key 'normal 'global (kbd "-") 'my-dired-prefix)

    (evil-define-key 'normal 'global (kbd "- <") 'consult-buffer)

    (evil-define-key 'normal 'global (kbd "--") 'dired-jump)
    (evil-define-key 'normal 'global (kbd "-d")
      (lambda () (interactive) (dired "~/Documents/dev")))
    (evil-define-key 'normal 'global (kbd "-h")
      (lambda () (interactive) (dired "~")))
    (evil-define-key 'normal 'global (kbd "-o")
      (lambda () (interactive) (dired "~/Documents/org")))

    ;; Dired-specific navigation
    (evil-define-key 'normal dired-mode-map
      ;; 'l' opens the directory/file in the SAME buffer
      (kbd "l") 'dired-find-alternate-file

      ;; 'h' goes up a directory and kills the current buffer
      ;; We use a lambda to ensure the "up" movement also replaces the buffer
      (kbd "h") (lambda () (interactive) (find-alternate-file "..")))))

;; todos
(use-package hl-todo
  :hook (prog-mode . hl-todo-mode))

(use-package magit-todos
  :after magit
  :config
  (magit-todos-mode 1))

;; multiple cursors
(use-package multiple-cursors
  :bind (("C-*"         . mc/mark-next-like-this)
         ("C-#"         . mc/mark-previous-like-this)
         ("C-c C-*"     . mc/mark-all-like-this)))

;; markdown
(use-package markdown-mode
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown"))

;; org mode
(use-package org
  :ensure nil
  :hook (org-mode . visual-line-mode)
  :bind (("C-c a" . org-agenda)
         ("C-c c" . org-capture))
  :config
  (setq org-directory "~/Documents/org")
  ;; tasks.org, notes.org, journal.org
  (setq org-agenda-files '("~/Documents/org/"))

  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "IN-PROGRESS(i)" "|" "DONE(d)")))

  (setq org-todo-keyword-faces
        '(("NEXT" . "orange")
          ("IN-PROGRESS" . "cyan")))

  (setq org-capture-templates
        '(("t" "Todo" entry (file+headline (lambda () (expand-file-name "tasks.org" org-directory)) "Inbox")
           "* TODO %?")
          ("n" "Note" entry (file+headline (lambda () (expand-file-name "notes.org" org-directory)) "Notes")
           "* %u %?\n  %i\n")
          ("j" "Journal" entry (file+olp+datetree (lambda () (expand-file-name "journal.org" org-directory)))
           "* %?\nEntered on %U\n  %i\n"))))

(use-package org-superstar
  :hook (org-mode . org-superstar-mode))

;; ------- LSP Configuration --------

;; Core LSP (lsp-mode)
(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook (
         (python-mode . lsp)
         (c-mode . lsp)
         (c++-mode . lsp)
         (rust-mode . lsp)
         (js-mode . lsp)

         (lsp-mode . lsp-enable-which-key-integration))
  :config
  (setq lsp-headerline-breadcrumb-enable nil)

  (with-eval-after-load 'lsp-mode
    (evil-define-key 'normal lsp-mode-map
      (kbd "g d") 'lsp-find-definition
      (kbd "g r") 'lsp-find-references
      (kbd "K")   'lsp-ui-doc-focus-frame
      (kbd "g e N") 'flycheck-previous-error
      (kbd "g e n") 'flycheck-next-error))
  :commands lsp)

;; Better syntax checking
(use-package flycheck
  :init (global-flycheck-mode))

;; Better UI
(use-package lsp-ui
  :commands lsp-ui-mode
  :custom
  ;; Documentation Settings
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-header nil)
  (lsp-ui-doc-include-signature nil)
  (lsp-ui-doc-position 'top) ;; Options: 'top, 'bottom, or 'at-point
  (lsp-ui-doc-max-height 30)
  (lsp-ui-doc-max-width 120)

  ;; Control the behavior
  (lsp-ui-doc-delay 0.5)          ;; Wait 0.5s before showing (prevents flickering while moving)
  (lsp-ui-doc-show-with-cursor t) ;; Don't show just because cursor moved...
  (lsp-ui-doc-show-with-mouse nil)    ;; ...but show if mouse hovers (optional)

  ;; Sideline settings
  (lsp-ui-sideline-enable t)
  (lsp-ui-sideline-show-hover nil))      ;; Turn off sideline to focus on the doc window

;; Auto completion
(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
          ("C-j" . company-select-next)
          ("C-k" . company-select-previous)
          ("<tab>" . company-complete-selection))
  :config
  (with-eval-after-load 'company
    (define-key evil-insert-state-map (kbd "C-SPC") 'company-complete))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.1)) ; 0.1s is usually smoother than 0.0s

(use-package company-box
  :hook (company-mode . company-box-mode)
  :config (custom-set-faces
           ;; This handles the background of the selected line in the box
           '(company-box-selection ((t (:background "#32383e" :foreground "#ffffff"))))))

;; Python (pyright + ruff)
(use-package lsp-pyright
  :custom (lsp-pyright-langserver-command "pyright") ;; or basedpyright
  :hook (python-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp))))  ; or lsp-deferred

(use-package pyvenv
  :config
  (pyvenv-mode 1))

;; Rust
(use-package rust-mode)
