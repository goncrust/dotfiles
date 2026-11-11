;;; init.el --- goncrust config  -*- lexical-binding: t -*-

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(all-the-icons-dired company-box consult diff-hl doom-modeline doom-themes evil-collection evil-org flycheck
                         lsp-pyright lsp-ui magit-todos marginalia multiple-cursors orderless org-superstar pyvenv
                         quickrun rainbow-delimiters rust-mode undo-fu vertico)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Basics
(add-to-list 'initial-frame-alist '(fullscreen . maximized))

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

(add-hook 'prog-mode-hook #'whitespace-mode)
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
(add-hook 'org-mode-hook (lambda () (whitespace-mode -1)))

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
  :bind (("C-x b" . consult-buffer)
         ("C-c r" . consult-ripgrep)
         ("C-c f" . consult-find))
  :config
  (defun my/consult-ripgrep-symbol-at-point ()
    "Run consult-ripgrep with the symbol at point as initial input."
    (interactive)
    (consult-ripgrep nil (thing-at-point 'symbol)))

  (with-eval-after-load 'evil
    (evil-define-key 'normal 'global (kbd "C-+")
      #'my/consult-ripgrep-symbol-at-point)))

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

  ;(load-theme 'doom-ir-black t)
  (load-theme 'doom-material-dark t)
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

(use-package diff-hl
  :ensure t
  :init
  ;; Enable diff-hl globally across all buffers
  (global-diff-hl-mode)
  :config
  ;; Highlight changes on the fly (as you type, rather than just on save)
  (diff-hl-flydiff-mode)

  ;; Integration with Magit (updates indicators immediately after staging/committing)
  (with-eval-after-load 'magit
    (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
    (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh))

;; Ensure the floating window dynamically scales with NO upper restrictions
  (setq diff-hl-show-hunk-posframe-parameters
        '((min-height . 4)      ; Starts at a reasonable minimum layout
          (height . nil)        ; NIL allows it to expand automatically to fit the code
          (max-height . 40))))  ; Cap it high so large hunks don't get choked down

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
  :init (setq markdown-command "pandoc")
  :config
    (setq browse-url-browser-function 'browse-url-generic
          browse-url-generic-program "firefox"))

;; org mode
(use-package org
  :ensure nil
:hook ((org-mode . visual-line-mode)
       (org-mode . org-indent-mode))
  :bind (("C-c a" . org-agenda)
         ("C-c c" . org-capture))
  :config
  (setq org-directory "~/Documents/org")
  ;; tasks.org, notes.org, journal.org, work.org
  (setq org-agenda-files '("~/Documents/org/"))

  (setq org-hide-leading-stars t)

  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "IN-PROGRESS(i)" "|" "DONE(d)")))

  (setq org-todo-keyword-faces
        '(("NEXT" . "orange")
          ("IN-PROGRESS" . "cyan")))

  ;; time tracking
  (setq org-log-done 'time
        org-agenda-span 'week
        org-agenda-start-on-weekday 1
        org-clock-persist 'history
        org-clock-out-remove-zero-time-clocks t
        org-duration-format 'h:mm
        org-agenda-clockreport-parameter-plist '(:link t :maxlevel 2 :compact t))
  (org-clock-persistence-insinuate)

  ;; clocking in on a TODO/NEXT task marks it IN-PROGRESS
  (setq org-clock-in-switch-to-state
        (lambda (_) (when (member (org-get-todo-state) '("TODO" "NEXT"))
                      "IN-PROGRESS")))

  ;; effort estimates you can pick with C-c C-x e
  (setq org-global-properties
        '(("Effort_ALL" . "0:30 1:00 1:30 2:00 3:00 4:00 6:00 8:00")))

  (setq org-capture-templates
        '(("t" "Todo" entry (file+headline (lambda () (expand-file-name "tasks.org" org-directory)) "Inbox")
           "* TODO %?")
          ("n" "Note" entry (file+headline (lambda () (expand-file-name "notes.org" org-directory)) "Notes")
           "* %u %?\n  %i\n")
          ("j" "Journal" entry (file+olp+datetree (lambda () (expand-file-name "journal.org" org-directory)))
           "* %?\nEntered on %U\n  %i\n"))))

(use-package evil-org
  :after (evil org)
  :hook (org-mode . evil-org-mode)
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

(use-package org-superstar
  :hook (org-mode . org-superstar-mode)
  :config
  (setq org-superstar-leading-bullet " ")

  (setq org-superstar-headline-bullets-list '("◉" "○" "◈" "◇" "•"))
  (custom-set-faces
   '(org-superstar-header-bullet ((t (:height 1.0 :inherit default))))))

(defun my/work-new-week (date)
  "Append a week skeleton to work.org. DATE is any day in that week."
  (interactive (list (org-read-date nil t nil "Any day in the week: ")))
  (let* ((d (decode-time date))
         (monday (decoded-time-add
                  d (make-decoded-time
                     :day (- (mod (+ (decoded-time-weekday d) 6) 7)))))
         (mtime (encode-time monday)))
    (find-file (expand-file-name "work.org" org-directory))
    (goto-char (point-max))
    (unless (bolp) (insert "\n"))
    (insert (format "\n* Week %s · %s\n** Week objectives\n"
                    (format-time-string "%V" mtime)
                    (format-time-string "%d %b %Y" mtime)))
    (dotimes (i 5)
      (let ((day (encode-time
                  (decoded-time-add monday (make-decoded-time :day i)))))
        (insert (format "** %s <%s>\n*** Admin / buffer :admin:\n*** Notes\n*** Hours\n#+BEGIN: clocktable :scope tree2 :maxlevel 3\n#+END:\n"
                        (format-time-string "%a %d %b" day)
                        (format-time-string "%Y-%m-%d %a" day)))))
    (insert "** Week summary\n#+BEGIN: clocktable :scope tree1 :maxlevel 3 :tags t\n#+END:\n")))

;; ;; ------- LSP Configuration --------

;; ;; Core LSP (lsp-mode)
;; (use-package lsp-mode
;;   :init
;;   (setq lsp-keymap-prefix "C-c l")
;;   :hook (
;;          (python-mode . lsp)
;;          (c-mode . lsp)
;;          (c++-mode . lsp)
;;          (rust-mode . lsp)
;;          (js-mode . lsp)

;;          (lsp-mode . lsp-enable-which-key-integration))
;;   :config
;;   (setq lsp-headerline-breadcrumb-enable nil)

;;   (with-eval-after-load 'lsp-mode
;;     (evil-define-key 'normal lsp-mode-map
;;       (kbd "g d") 'lsp-find-definition
;;       (kbd "g r") 'lsp-find-references
;;       (kbd "K")   'lsp-ui-doc-focus-frame
;;       (kbd "g e N") 'flycheck-previous-error
;;       (kbd "g e n") 'flycheck-next-error))
;;   :commands lsp)

;; ;; Better syntax checking
;; (use-package flycheck
;;   :init (global-flycheck-mode))

;; ;; Better UI
;; (use-package lsp-ui
;;   :commands lsp-ui-mode
;;   :custom
;;   ;; Documentation Settings
;;   (lsp-ui-doc-enable t)
;;   (lsp-ui-doc-header nil)
;;   (lsp-ui-doc-include-signature nil)
;;   (lsp-ui-doc-position 'top) ;; Options: 'top, 'bottom, or 'at-point
;;   (lsp-ui-doc-max-height 30)
;;   (lsp-ui-doc-max-width 120)

;;   ;; Control the behavior
;;   (lsp-ui-doc-delay 0.5)          ;; Wait 0.5s before showing (prevents flickering while moving)
;;   (lsp-ui-doc-show-with-cursor t) ;; Don't show just because cursor moved...
;;   (lsp-ui-doc-show-with-mouse nil)    ;; ...but show if mouse hovers (optional)

;;   ;; Sideline settings
;;   (lsp-ui-sideline-enable t)
;;   (lsp-ui-sideline-show-hover nil))      ;; Turn off sideline to focus on the doc window

;; ;; Auto completion
;; (use-package company
;;   :after lsp-mode
;;   :hook (lsp-mode . company-mode)
;;   :bind (:map company-active-map
;;           ("C-j" . company-select-next)
;;           ("C-k" . company-select-previous)
;;           ("<tab>" . company-complete-selection))
;;   :config
;;   (with-eval-after-load 'company
;;     (define-key evil-insert-state-map (kbd "C-SPC") 'company-complete))
;;   :custom
;;   (company-minimum-prefix-length 1)
;;   (company-idle-delay 0.1)) ; 0.1s is usually smoother than 0.0s

;; (use-package company-box
;;   :hook (company-mode . company-box-mode)
;;   :config (custom-set-faces
;;            ;; This handles the background of the selected line in the box
;;            '(company-box-selection ((t (:background "#32383e" :foreground "#ffffff"))))))

;; ;; Python (pyright + ruff)
;; (use-package lsp-pyright
;;   :custom (lsp-pyright-langserver-command "pyright") ;; or basedpyright
;;   :hook (python-mode . (lambda ()
;;                           (require 'lsp-pyright)
;;                           (lsp))))  ; or lsp-deferred

;; (use-package pyvenv
;;   :config
;;   (pyvenv-mode 1))

;; ;; Rust
;; (use-package rust-mode)

;; quick run
(use-package quickrun
    :bind (("C-c x" . quickrun)            ; run current file
           ("C-c X" . quickrun-shell)))    ; run in an interactive shell (for programs that read stdin)

(add-to-list 'display-buffer-alist
               '("\\*\\(quickrun\\|eshell-quickrun\\|compilation\\)\\*"
                 (display-buffer-reuse-window display-buffer-at-bottom)
                 (window-height . 0.3)))
