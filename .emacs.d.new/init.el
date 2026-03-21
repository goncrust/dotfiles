(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(all-the-icons-dired consult doom-modeline doom-themes evil-collection magit marginalia orderless rainbow-delimiters
                         undo-fu vertico)))
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

    (evil-define-key 'normal 'global (kbd "--") 'dired-jump)
    (evil-define-key 'normal 'global (kbd "-d")
      (lambda () (interactive) (dired "~/Documents/dev")))
    (evil-define-key 'normal 'global (kbd "-h")
      (lambda () (interactive) (dired "~")))

    ;; Dired-specific navigation
    (evil-define-key 'normal dired-mode-map
      ;; 'l' opens the directory/file in the SAME buffer
      (kbd "l") 'dired-find-alternate-file

      ;; 'h' goes up a directory and kills the current buffer
      ;; We use a lambda to ensure the "up" movement also replaces the buffer
      (kbd "h") (lambda () (interactive) (find-alternate-file "..")))))
