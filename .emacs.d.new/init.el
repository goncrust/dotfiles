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

;; Save place and history
(use-package savehist
  :config
  (savehist-mode))

(use-package saveplace
  :config
  (save-place-mode 1))

;; Font
(set-face-attribute 'default nil :font "Hack" :height 130)

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
    (evil-define-key 'normal 'global (kbd "-") 'dired-jump)

    ;; Dired-specific navigation
    (evil-define-key 'normal dired-mode-map
      ;; 'l' opens the directory/file in the SAME buffer
      (kbd "l") 'dired-find-alternate-file
      
      ;; 'h' goes up a directory and kills the current buffer
      ;; We use a lambda to ensure the "up" movement also replaces the buffer
      (kbd "h") (lambda () (interactive) (find-alternate-file "..")))))
