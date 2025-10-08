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

;;; --- package setup ---------------------------------------------------------
(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu"   . "https://elpa.gnu.org/packages/")))
(unless (bound-and-true-p package--initialized)
  (package-initialize))
(unless package-archive-contents
  (package-refresh-contents))

;; Bootstrap use-package if missing
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; --- lag --------------------------------------------------------------------

;; 1) Fewer GCs while typing
(setq gc-cons-threshold (* 64 1024 1024)
      gc-cons-percentage 0.2)

;; 2) Faster I/O from subprocesses (LSP, linters, etc.)
(setq read-process-output-max (* 1024 1024)) ;; 1MB

;; 3) Make redisplay/fontification less eager
(setq fast-but-imprecise-scrolling t
      redisplay-skip-fontification-on-input nil
      jit-lock-defer-time 0.05
      jit-lock-stealth-time 1)

;; 4) Long lines protection (huge minified files, logs)
(global-so-long-mode 1)

;; 5) Disable costly bidi processing (big win)
(setq bidi-inhibit-bpa t
      bidi-display-reordering nil)


;;; --- basic UI --------------------------------------------------------------
(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(setq inhibit-startup-message t
      make-backup-files nil
      create-lockfiles nil)

;; Smooth scrolling
(setq scroll-step 1
      scroll-margin 0
      scroll-conservatively 10000
      scroll-up-aggressively 0.01
      scroll-down-aggressively 0.01)

;; ---------- Font settings ---------------------------------------------------
;; Main font
(set-face-attribute 'default nil
  :font "Hack"
  :height 120
  :weight 'medium)

;; For proportional text (org-mode, markdown, etc.)
(set-face-attribute 'variable-pitch nil
  :font "Hack"
  :height 130)

;; For fixed-pitch sections inside variable-pitch buffers
(set-face-attribute 'fixed-pitch nil
  :font "Hack"
  :height 120)

;;; --- history & recent files ------------------------------------------------
(savehist-mode 1)        ;; persist minibuffer history
(recentf-mode 1)         ;; files for consult-recent-file
(setq recentf-max-saved-items 500)

;; Remember cursor position in files
(save-place-mode 1)
(setq save-place-forget-unreadable-files t) ;; skip weird/unreadable files

;;; --- Evil ------------------------------------------------------------------
(use-package evil
  :init
  (setq evil-want-keybinding nil
        evil-want-C-i-jump nil
        evil-want-C-z-switch-state nil
	evil-undo-system 'undo-redo)
  :config (evil-mode 1))

(use-package evil-collection
  :after evil
  :config (evil-collection-init))

;;; --- which-key -------------------------------------------------------------
(use-package which-key
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.25))

;;; --- Vertico / Orderless / Marginalia --------------------------------------
(use-package vertico
  :init (vertico-mode 1)
  :config
  ;; Vimmy movement in minibuffer
  (define-key vertico-map (kbd "C-j") #'vertico-next)
  (define-key vertico-map (kbd "C-k") #'vertico-previous))

(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides
        '((file (styles basic partial-completion))))
  (setq completion-ignore-case t
        read-file-name-completion-ignore-case t)
  ;; Optional: tune matching flavors
  (setq orderless-matching-styles
        '(orderless-literal orderless-regexp orderless-initialism orderless-flex)))

(use-package marginalia
  :init (marginalia-mode 1))

;;; --- Consult ---------------------------------------------------------------
(use-package consult
  :init
  (global-set-key (kbd "C-x b") #'consult-buffer)
  (global-set-key (kbd "C-c s") #'consult-ripgrep)
  (global-set-key (kbd "C-c f") #'consult-find)
  :config
  ;; Always preview
  (setq consult-preview-key 'any))

;;; --- Theme -----------------------------------------------------------------
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-one t)
  (doom-themes-visual-bell-config))

;;; --- Modeline --------------------------------------------------------------
(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-major-mode-icon t
        doom-modeline-height 15
        doom-modeline-buffer-file-name-style 'truncate-upto-project))
;; After first install, run: M-x nerd-icons-install-fonts

;;; --- Projectile ------------------------------------------------------------
(use-package projectile
  :init (setq projectile-project-search-path '("~/Documents/dev"))
  :config
  (projectile-mode 1)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

;;; --- Magit -----------------------------------------------------------------
(use-package magit
  :bind (("C-c g" . magit-status)))

;;; --- Smartparens -----------------------------------------------------------
(use-package smartparens
  :hook (prog-mode . smartparens-mode))

;;; --- Line numbers ----------------------------------------------------------
(use-package display-line-numbers
  :ensure nil
  :init (setq display-line-numbers-type 'relative)
  :hook (prog-mode . display-line-numbers-mode))

;; ---------- LSP (Eglot) -----------------------------------------------------
(use-package eglot
  :hook
  ((python-mode python-ts-mode
    c-mode c-ts-mode
    c++-mode c++-ts-mode
    java-mode java-ts-mode
    js-mode js-ts-mode
    typescript-ts-mode
    css-mode css-ts-mode
    html-mode
    json-mode json-ts-mode
    latex-mode LaTeX-mode
    markdown-mode markdown-ts-mode)
   . eglot-ensure)
  :config
  ;; Prefer Tree-sitter major modes when available (Emacs 29+), but only if grammar exists
  (dolist (pair '((python-mode . python-ts-mode)
                  (c-mode      . c-ts-mode)
                  (c++-mode    . c++-ts-mode)
                  (java-mode   . java-ts-mode)
                  (js-mode     . js-ts-mode)
                  (css-mode    . css-ts-mode)
                  (json-mode   . json-ts-mode)))
    (when (and (fboundp (cdr pair))
	       (treesit-available-p))
      (add-to-list 'major-mode-remap-alist pair)))

  ;; Server command mappings (idempotent)
  (dolist (entry
           '(((python-mode python-ts-mode)            . ("pyright-langserver" "--stdio"))
             ((c-mode c-ts-mode c++-mode c++-ts-mode) . ("clangd"))
             ((java-mode java-ts-mode)                . ("jdtls"))
             ((js-mode js-ts-mode typescript-ts-mode) . ("typescript-language-server" "--stdio"))
             ((css-mode css-ts-mode)                  . ("vscode-css-language-server" "--stdio"))
             ((html-mode)                             . ("vscode-html-language-server" "--stdio"))
             ((json-mode json-ts-mode)                . ("vscode-json-language-server" "--stdio"))
             ((latex-mode LaTeX-mode)                 . ("texlab"))
             ((markdown-mode markdown-ts-mode)        . ("marksman" "server"))))
    (add-to-list 'eglot-server-programs entry))

  ;; Smoothness / noise reduction
  (setq eglot-autoreconnect t
        eglot-sync-connect nil
        eglot-report-progress nil
        eglot-events-buffer-size 0
        eglot-send-changes-idle-time 0.3)

  ;; Let external formatters handle formatting
  ;; (If you want texlab to format LaTeX, remove LaTeX from this list.)
  (setq eglot-ignored-server-capabilities
        '(:documentFormattingProvider :documentRangeFormattingProvider))
  )

;; Arch stores grammars in /usr/lib/tree-sitter
(when (boundp 'treesit-extra-load-path)
  (add-to-list 'treesit-extra-load-path "/usr/lib/tree-sitter"))

;; Handy keys (tweak as you like)
(with-eval-after-load 'eglot
  (define-key eglot-mode-map (kbd "C-c r") #'eglot-rename)
  (define-key eglot-mode-map (kbd "C-c a") #'eglot-code-actions))

;; ---------- Completions & docs ----------------------------------------------
(use-package corfu
  :init (global-corfu-mode)
  :config
  (setq corfu-auto t
        corfu-auto-delay 0.12
        corfu-auto-prefix 1
        corfu-quit-no-match t
        corfu-preselect 'first
        corfu-quit-at-boundary nil
        corfu-cycle t)
  ;; Docs popup near point
  (require 'corfu-popupinfo)
  (corfu-popupinfo-mode 1)
  (setq corfu-popupinfo-delay 0.2
        corfu-popupinfo-max-width 80
        corfu-popupinfo-max-height 20))

;; TAB should complete nicely
(setq tab-always-indent 'complete)
(with-eval-after-load 'corfu
  (define-key corfu-map (kbd "TAB")       #'corfu-insert)
  (define-key corfu-map (kbd "<tab>")     #'corfu-insert)
  (define-key corfu-map (kbd "S-TAB")     #'corfu-previous)
  (define-key corfu-map (kbd "<backtab>") #'corfu-previous))

;; Eldoc: show rich signatures at the bottom
(setq eldoc-idle-delay 0.12
      eldoc-echo-area-use-multiline-p t
      eldoc-documentation-strategy #'eldoc-documentation-compose)
(add-hook 'prog-mode-hook #'eldoc-mode)

;; Inlay hints (param names/types inline)
(add-hook 'eglot-managed-mode-hook #'eglot-inlay-hints-mode)

;; Re-trigger signature help on (, ,, ), RET, TAB
(defun my/eglot-signature-help-maybe ()
  "Ask Eglot for signature help after chars that usually change arg index."
  (when (and (eglot-current-server)
             (memq last-command-event '(?\( ?, ?\) ?\n ?\t)))
    (ignore-errors (eglot-signature-help))))
(add-hook 'eglot-managed-mode-hook
          (lambda ()
            (add-hook 'post-self-insert-hook #'my/eglot-signature-help-maybe nil t)))

;; Extra completion sources
(use-package cape
  :after corfu
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

;; ---------- Formatters -------------------------------------------------------
;; Python: Black + isort
(use-package python-black :hook (python-mode . python-black-on-save-mode-enable-dwim))
(use-package py-isort     :hook (before-save . py-isort-before-save))

;; C/C++: clang-format on save (buffer-local)
(use-package clang-format
  :hook ((c-mode c++-mode c-ts-mode c++-ts-mode)
         . (lambda () (add-hook 'before-save-hook #'clang-format-buffer nil t))))

;; Web stack: Prettier (requires: npm i -g prettier)
(use-package prettier
  :hook ((js-mode js-ts-mode typescript-ts-mode
                  css-mode css-ts-mode
                  html-mode
                  json-mode json-ts-mode
                  markdown-mode markdown-ts-mode)
         . prettier-mode))

;; LaTeX formatting:
;; Option A (recommended): let texlab format via Eglot (remove LaTeX from ignored caps above).
;; Option B: keep CLI latexindent (but avoid revert-buffer flicker), e.g. via Apheleia.
(add-hook 'LaTeX-mode-hook
          (lambda ()
            (add-hook 'before-save-hook
                      (lambda ()
                        (when (executable-find "latexindent")
                          (shell-command (format "latexindent -w %s"
                                                 (shell-quote-argument buffer-file-name)))))
                      nil t)))
