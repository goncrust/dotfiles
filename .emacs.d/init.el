;; TODO lsp-ui configuration
;; TODO setup more servers
;; TODO learn orgmode
;; TODO config to orgmode

;; Set up package.el to work with MELPA
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
					;(add-to-list 'package-archives
					;             '(("melpa" . "https://melpa.org/packages/")
					;	       ("org" . "https://orgmode.org/elpa/")))
(package-initialize)
(package-refresh-contents)

;; Packages
;; use-package
(unless (package-installed-p 'use-package)
  :ensure t
  (package-refresh-contents)
  (package-install 'use-package))
(eval-and-compile
  :ensure t
  (setq use-package-always-ensure t
        use-package-expand-minimally t))
;; evil
(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1)
  (evil-set-undo-system 'undo-redo))
;; evil-collection (evil mode for more apps like pacakge-list-packages)
(use-package evil-collection
  :ensure t
  :after evil
  :config
  (evil-collection-init))
;; doom-themes
(use-package doom-themes
  :ensure t)
;; which-key
(use-package which-key
  :ensure t
  :init
  (which-key-mode 1)
  :config
  (setq which-key-idle-delay 0))
;; ivy
(use-package ivy
  :ensure t
  :bind (:map ivy-mode-map
	      ("C-j" . ivy-next-line)
	      ("C-k" . ivy-previous-line))
  :config
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  :init
  (ivy-mode 1))
;; marginalia
(use-package marginalia
  :ensure t
  :init
  (marginalia-mode 1))
;; swiper
(use-package swiper
  :ensure t
  :config
  (global-set-key (kbd "C-s") 'swiper))
;; counsel - (C-x C-f) M-o for more options
(use-package counsel
  :ensure t
  :config
  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
  (global-set-key (kbd "C-x b") 'counsel-switch-buffer))
;; doom-modeline
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))
;; orgmode
(use-package org
  :ensure t
  :config
  (setq org-ellipsis " ▾")
  (setq org-agenda-files
        '("~/org-files/tasks.org"))
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t))
(use-package org-bullets
  :ensure t
  :hook (org-mode . org-bullets-mode))
(use-package org-contrib
  :ensure t)
;; rainbow parenthesis
(use-package rainbow-delimiters
  :ensure t
  :config
  (add-hook 'foo-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))
;; undo history
(use-package undohist
  :ensure t
  :config
  (undohist-initialize))
;; magit
(use-package magit
  :ensure t)
;; all the icons
(use-package all-the-icons
  :ensure t
  :if (display-graphic-p))
(use-package all-the-icons-dired
  :ensure t
  :if (display-graphic-p)
  :hook (dired-mode . (lambda () (all-the-icons-dired-mode t)))
  :config (setq all-the-icons-dired-monochrome nil))
;; helpful
(use-package helpful
  :ensure t
  :config
  (global-set-key (kbd "C-h f") #'helpful-callable)
  (global-set-key (kbd "C-h v") #'helpful-variable)
  (global-set-key (kbd "C-h k") #'helpful-key)
  (global-set-key (kbd "C-h x") #'helpful-command))
;; vterm
;; zsh not working???
(use-package vterm
  :ensure t
  :config
  (setq shell-file-name '"/bin/zsh")
  (setq vterm-shell '"/bin/zsh")
  (setq vterm-max-scrollback 5000))
(use-package vterm-toggle
  :ensure t)
;; dashboard
;; projects??
(use-package dashboard
  :ensure t
  :init
  (setq initial-buffer-choice 'dashboard-open)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-banner-logo-title "GNU Emacs")
  (setq dashboard-projects-backend 'projectile)
  (setq dashboard-startup-banner 'logo)
  (setq dashboard-center-content nil)
  (setq dashboard-items '((recents . 5)
			  (agenda . 5)
			  (bookmarks . 3)
			  (projects . 3)
			  (registers . 3)))
  :config
  (dashboard-setup-startup-hook))
;; projectile
(use-package projectile
  :ensure t
  :config (projectile-mode 1)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/Documents/dev")
    (setq projectile-project-search-path '("~/Documents/dev")))
  (setq projectile-switch-project-action #'projectile-dired))
(use-package counsel-projectile
  :ensure t
  :config (counsel-projectile-mode 1))
;; lsp
(use-package lsp-mode
  :ensure t
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         ;;(XXX-mode . lsp)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp
  :config
  (add-hook 'prog-mode-hook 'lsp-deferred)
  ;; Less chatty for unsupported modes
  (setq lsp-warn-no-matched-clients nil))
(use-package lsp-ui
  :ensure t
  :config
  (setq lsp-ui-doc-show-with-cursor t)
  (setq lsp-ui-doc-delay 2))
(use-package flycheck
  :ensure t
  :config
  (add-hook 'after-init-hook #'global-flycheck-mode))
;; company
(use-package company
  :ensure t
  :config
  (setq company-minimum-prefix-length 1)
  (define-key company-mode-map (kbd "C-SPC") 'company-complete)
  :init
  (global-company-mode 1))
(use-package company-box
  :ensure t
  :hook (company-mode . company-box-mode))
;; autoformat
(use-package format-all
  :ensure t
  :hook (prog-mode . format-all-mode)
  :config
  ;; we have to set default, otherwise it doesnt autoformat on save before the first manual format-all-buffer
  (add-hook 'format-all-mode-hook 'format-all-ensure-formatter))
;; whitespace-mode
(use-package whitespace
  :ensure t
  :hook (before-save . whitespace-cleanup)
  :hook (prog-mode . whitespace-mode)
  :config
  (setq whitespace-style
	'(face spaces empty tabs newline trailing space-mark tab-mark)))
;; treemacs
(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                2000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-header-scroll-indicators        '(nil . "^^^^^^")
          treemacs-hide-dot-git-directory          t
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-project-follow-into-home        nil
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               70
          treemacs-width                           35
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil
          ;; custom
          treemacs-wrap-around                     nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . -find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil
  :after (treemacs evil)
  :ensure t)

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

(use-package treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-enable-once)
  :ensure t)

(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)

(use-package treemacs-persp ;;treemacs-perspective if you use perspective.el vs. persp-mode
  :after (treemacs persp-mode) ;;or perspective vs. persp-mode
  :ensure t
  :config (treemacs-set-scope-type 'Perspectives))

(use-package treemacs-tab-bar ;;treemacs-tab-bar if you use tab-bar-mode
  :after (treemacs)
  :ensure t
  :config (treemacs-set-scope-type 'Tabs))

;; Window Config
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(setq confirm-kill-emacs #'yes-or-no-p)
(setq inhibit-startup-message t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode -1)
(global-hl-line-mode 1)
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)
(setq scroll-step 1)
(setq scroll-conservatively 1000)
(save-place-mode 1)

;; Theme
(load-theme 'doom-one t)

;; Font
(set-face-attribute 'default nil :font "Hack Nerd Font" :height 135)

;; Keys
(electric-pair-mode 1)
(global-set-key (kbd "M-8") "[")
(global-set-key (kbd "M-9") "]")
(global-set-key (kbd "M-7") "{")
(global-set-key (kbd "M-0") "}")
(global-set-key (kbd "C-c f") 'format-all-mode)
(define-key evil-normal-state-map (kbd "SPC q") 'kill-current-buffer)
(define-key evil-normal-state-map (kbd "SPC f") 'treemacs-select-window)
(evil-define-key 'treemacs treemacs-mode-map (kbd "SPC f") #'treemacs-select-window)
(define-key evil-normal-state-map (kbd "SPC \\") 'vterm-toggle)
(evil-define-key 'treemacs treemacs-mode-map (kbd "SPC \\") #'vterm-toggle)
(define-key evil-normal-state-map (kbd "SPC l") 'next-buffer)
(define-key evil-normal-state-map (kbd "SPC h") 'previous-buffer)
(define-key evil-normal-state-map (kbd "SPC b") 'ibuffer)
(define-key evil-normal-state-map (kbd "SPC w j") 'evil-window-down)
(define-key evil-normal-state-map (kbd "SPC w k") 'evil-window-up)
(define-key evil-normal-state-map (kbd "SPC w h") 'evil-window-left)
(define-key evil-normal-state-map (kbd "SPC w l") 'evil-window-right)
(evil-define-key 'treemacs treemacs-mode-map (kbd "SPC w l") #'evil-window-right)
(define-key evil-normal-state-map (kbd "SPC d") 'dashboard-open)
;; swap ciw with cio
(define-key evil-outer-text-objects-map "w" 'evil-a-symbol)
(define-key evil-inner-text-objects-map "w" 'evil-inner-symbol)
(define-key evil-outer-text-objects-map "o" 'evil-a-word)
(define-key evil-inner-text-objects-map "o" 'evil-inner-word)
;; Dired
(evil-define-key 'normal dired-mode-map
  (kbd "h") 'dired-up-directory
  (kbd "l") 'dired-find-file)
(add-hook 'dired-mode-hook 'auto-revert-mode)
(setf dired-kill-when-opening-new-dired-buffer t)

;; tabs
(setq tab-width 4
      tab-always-indent 'complete
      indent-tabs-mode nil)
(defun my-c-mode-common-hook ()
  (setq c-basic-offset 4)
  (setq c-basic-indent 4))
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

;; autosave and backup
(setq auto-save-visited-mode t
      auto-save-visited-interval 2)
(setq make-backup-files nil)

;; Don't know what this is, will find later
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("7e377879cbd60c66b88e51fad480b3ab18d60847f31c435f15f5df18bdb18184" "88f7ee5594021c60a4a6a1c275614103de8c1435d6d08cc58882f920e0cec65e" "4594d6b9753691142f02e67b8eb0fda7d12f6cc9f1299a49b819312d6addad1d" "4b6cc3b60871e2f4f9a026a5c86df27905fb1b0e96277ff18a76a39ca53b82e1" "b754d3a03c34cfba9ad7991380d26984ebd0761925773530e24d8dd8b6894738" "9d29a302302cce971d988eb51bd17c1d2be6cd68305710446f658958c0640f68" "4990532659bb6a285fee01ede3dfa1b1bdf302c5c3c8de9fad9b6bc63a9252f7" "f4d1b183465f2d29b7a2e9dbe87ccc20598e79738e5d29fc52ec8fb8c576fcfd" "c1d5759fcb18b20fd95357dcd63ff90780283b14023422765d531330a3d3cec2" "dd4582661a1c6b865a33b89312c97a13a3885dc95992e2e5fc57456b4c545176" "dfb1c8b5bfa040b042b4ef660d0aab48ef2e89ee719a1f24a4629a0c5ed769e8" "8b148cf8154d34917dfc794b5d0fe65f21e9155977a36a5985f89c09a9669aa0" "8c7e832be864674c220f9a9361c851917a93f921fedb7717b1b5ece47690c098" "dccf4a8f1aaf5f24d2ab63af1aa75fd9d535c83377f8e26380162e888be0c6a9" "b5fd9c7429d52190235f2383e47d340d7ff769f141cd8f9e7a4629a81abc6b19" "014cb63097fc7dbda3edf53eb09802237961cbb4c9e9abd705f23b86511b0a69" \"4ade6b630ba8cbab10703b27fd05bb43aaf8a3e5ba8c2dc1ea4a2de5f8d45882\" \"aec7b55f2a13307a55517fdf08438863d694550565dee23181d2ebd973ebd6b8\" \"88f7ee5594021c60a4a6a1c275614103de8c1435d6d08cc58882f920e0cec65e\" default))
 '(package-selected-packages
   '(format-all vterm-toggle treemacs-tab-bar treemacs-persp treemacs-magit treemacs-icons-dired treemacs-projectile treemacs-evil treemacs flycheck-inline flycheck company-box company company-mode counsel-projectile projectile helpful dired+ all-the-icons-dired all-the-icons magit rainbow-delimiters doom-modeline which-key evil-collection evil)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
