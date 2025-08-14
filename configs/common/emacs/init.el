;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Management
;;
;; straight.el is a package manager for Emacs that allows
;; for declarative package management and building packages
;; directly from their Git repositories.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; straight.el bootstrap
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Install use-package
(straight-use-package 'use-package)
(setq straight-use-package-by-default t) ;; Make all use-package calls use straight.el


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General Emacs Settings
;;
;; Basic settings for better usability and a more modern feel.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Keep windows balanced
(use-package balanced-windows
  :config
  (balanced-windows-mode))

;; Performance optimizations
(setq gc-cons-threshold 500000000) ; 100 MB
(setq acm-enable-doc nil)

;; Line wrapping vs. truncation
(setq truncate-lines nil) ; This will ensure lines are NOT truncated

;; Appearance settings
(setq-default cursor-in-non-selected-windows nil)
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror 'nomessage)
(add-to-list 'default-frame-alist '(font . "Monospace 10"))
(setq-default tab-width 4)           ; Set default tab width
(setq-default indent-tabs-mode nil)  ; Use spaces instead of tabs
(setq-default electric-indent-chars '(?\n ?\^?))
(electric-pair-mode 1)
(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative)
(show-paren-mode t)

;; File management
(setq auto-save-default t)
(auto-insert-mode 1)
(setq auto-insert-query nil)
(setq make-backup-files t)
(setq backup-directory-alist `(("." . ,(expand-file-name "backups/" user-emacs-directory))))
(setq auto-save-list-file-prefix (expand-file-name "auto-saves/" user-emacs-directory))
;; Ensure backup and auto-save directories exist
(unless (file-exists-p (expand-file-name "backups/" user-emacs-directory))
  (make-directory (expand-file-name "backups/" user-emacs-directory) t))
(unless (file-exists-p (expand-file-name "auto-saves/" user-emacs-directory))
  (make-directory (expand-file-name "auto-saves/" user-emacs-directory) t))

;; UI and Dialogs
(setq use-dialog-box nil)
(setq confirm-noninteractive-kill t)

;; Minibuffer
;; Close the minibuffer when the mouse leaves it.
(defun stop-using-minibuffer ()
  (when (and (>= (recursion-depth) 1) (active-minibuffer-window))
    (abort-recursive-edit)))
(add-hook 'mouse-leave-buffer-hook 'stop-using-minibuffer)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Theme and Modeline
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Dracula Theme
(use-package doom-themes
  :straight (:host github :repo "doomemacs/themes")
  :config
  (load-theme 'doom-dracula t))

;; Doom Modeline
(straight-use-package 'doom-modeline)
(setq doom-modeline-height 1)
(setq doom-modeline-major-mode-icon t)
(setq doom-modeline-buffer-file-name-style 'truncate-at-project-dir)
(setq doom-modeline-buffer-state-icon t)
(setq doom-modeline-indent-info t)
(setq doom-modeline-enable-word-count t)
(setq doom-modeline-time-format "%H:%M")
(setq doom-modeline-display-debug-info nil)
(doom-modeline-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; HL Todo
;;
;; Highlight todo comments
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package hl-todo
  :straight t
  :config
  (global-hl-todo-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Vim Emulation (Evil Mode)
;;
;; Evil mode provides Vim keybindings with Doom Emacs style mappings for a consistent experience.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq evil-want-keybinding nil)
(straight-use-package 'evil)
(evil-mode 1)
(evil-set-undo-system 'undo-redo)
(straight-use-package 'evil-leader)
(require 'evil-leader)
(global-evil-leader-mode)
(with-eval-after-load 'Messages
  (evil-leader-mode 1)
  (evil-mode 1))
(setq evil-leader/leader "<SPC>")
(evil-leader/set-leader evil-leader/leader)
(straight-use-package 'evil-collection)
(evil-collection-init)
(fset 'evil-visual-update-x-selection 'ignore)

;; Custom Keybindings
(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "C-0") 'text-scale-adjust)
(evil-leader/set-key
  ;; FILE MANAGEMENT
  "f f" 'find-file
  "f d" 'dired
  "f s" 'save-buffer
  "f w" 'write-file
  "f r" 'consult-recent-file
  "f R" 'rename-file
  "f D" 'delete-file
  "f c" 'clone-buffer
  "f Q" 'save-buffers-kill-emacs
  "f q" 'kill-emacs
  ;; BUFFER MANAGEMENT
  "b b" 'consult-buffer
  "b k" 'kill-buffer
  "b K" 'kill-some-buffers
  "b n" 'next-buffer
  "b p" 'previous-buffer
  "b r" 'revert-buffer
  "b l" 'list-buffers
  ;; WINDOW MANAGEMENT (FRAMES/SPLITS)
  "w /" 'split-window-right
  "w -" 'split-window-below
  "w v" 'split-window-right
  "w s" 'split-window-below
  "w c" 'delete-window
  "w o" 'delete-other-windows
  "w h" 'windmove-left
  "w l" 'windmove-right
  "w k" 'windmove-up
  "w j" 'windmove-down
  "w r" 'rotate-window
  "w =" 'balance-windows
  "w m" 'maximize-window
  "w M" 'restore-window-configuration
  "<left>" 'windmove-left
  "<right>" 'windmove-right
  "<up>" 'windmove-up
  "<down>" 'windmove-down
  ;; SEARCH & REPLACE
  "s s" 'swiper
  "s r" 'query-replace
  "s R" 'query-replace-regexp
  "s f" 'counsel-rg
  "s p" 'counsel-projectile-grep
  ;; GIT (MAGIT)
  "g s" 'magit-status
  "g f" 'magit-fetch
  "g p" 'magit-pull
  "g c" 'magit-commit
  "g P" 'magit-push
  "g b" 'magit-branch
  "g B" 'magit-blame
  "g l" 'magit-log
  ;; PDF NOTER
  "p n" 'pdf-noter-add-note-at-point
  "p h" 'pdf-noter-highlight-region
  "p u" 'pdf-noter-unannotate-region
  "p l" 'pdf-noter-list-notes
  "p j" 'pdf-noter-goto-next-note
  "p k" 'pdf-noter-goto-previous-note
  "p d" 'pdf-noter-delete-note
  "p r" 'pdf-noter-reparse-notes
  "p s" 'pdf-noter-sync-notes
  ;; PROJECTILE
  "p f" 'projectile-find-file
  "p g" 'consult-ripgrep
  "p b" 'projectile-switch-to-buffer
  "p p" 'projectile-switch-project
  "p k" 'projectile-kill-buffers
  "p d" 'projectile-dired
  "p c" 'projectile-compile
  "p s" 'projectile-save-project-buffers
  ;; LSP-BRIDGE (Revised to use xref commands)
  "x l r" 'lsp-bridge-restart-process
  "x l d" 'xref-find-definitions
  "x l R" 'lsp-bridge-rename
  "x l h" 'xref-find-references
  "x l i" 'lsp-bridge-find-implementation
  "x l t" 'lsp-bridge-find-type-definition
  "x l a" 'lsp-bridge-code-action
  "x l o" 'lsp-bridge-toggle-diagnostics-in-minibuffer
  "x l f" 'lsp-bridge-format-buffer
  "c r" 'lsp-bridge-rename
  "c d" 'xref-find-definitions
  "c D" 'xref-find-references
  ;; Flycheck
  "e l" 'flycheck-list-errors
  "e n" 'flycheck-next-error
  "e p" 'flycheck-previous-error
  "e c" 'flycheck-clear
  "e d" 'flycheck-describe-checker
  "e a" 'flycheck-disable-checker
  "e e" 'flycheck-buffer
  ;; ORG MODE
  "o a" 'org-agenda
  "o c" 'org-capture
  "o l" 'org-store-link
  "o b" 'org-iswitchb
  ;; GENERAL UTILITIES
  "x e" 'eval-buffer
  "x E" 'eval-last-sexp
  "x r" 'reload-init-file
  "x v" 'view-emacs-init-file)

(evil-leader/set-key "<SPC>" 'projectile-find-file)
(evil-define-key 'insert 'global (kbd "C-a") 'beginning-of-line)
(evil-define-key 'insert 'global (kbd "C-e") 'end-of-line)
(evil-define-key 'normal 'global (kbd "C-e") 'end-of-line)
(evil-define-key 'visual 'global (kbd "C-e") 'end-of-line)

(define-key evil-visual-state-map (kbd ">")
  (lambda () (interactive) (call-interactively 'evil-shift-right) (evil-normal-state) (evil-visual-restore)))
(define-key evil-visual-state-map (kbd "<")
  (lambda () (interactive) (call-interactively 'evil-shift-left) (evil-normal-state) (evil-visual-restore)))
(defun reload-init-file ()
  "Reloads the Emacs initialization file (init.el)."
  (interactive)
  (load-file user-init-file)
  (message "init.el reloaded!"))

;; Undo-Fu
(use-package undo-fu
  :straight t)
(use-package undo-fu-session
  :straight t
  :config
  (undo-fu-session-global-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Completion Framework
;;
;; Vertico provides a minimalistic completion UI.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package vertico
  :straight t
  :init
  (vertico-mode)
  :bind (:map vertico-map
              ("C-<backspace>" . vertico-directory-up)
              ("<backspace>" . delete-backward-char)))

(straight-use-package 'orderless)
(setq completion-styles '(orderless basic))
(setq completion-category-defaults nil)
(setq completion-category-overrides '((file (styles . (partial-completion)))))

(straight-use-package 'marginalia)
(marginalia-mode)

(straight-use-package 'consult)
(setq consult-preview-key nil)

(straight-use-package 'swiper)
(straight-use-package 'counsel)
(straight-use-package 'counsel-projectile)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Projectile
;;
;; This section configures Projectile to find and remember your projects.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package projectile
  :straight t
  :init
  ;; This ensures Projectile is enabled from the start.
  ;; You can also use `(projectile-mode)` to enable it for specific modes.
  (projectile-mode +1)
  ;; This enables persistent caching, which saves the list of known projects
  ;; so they are available on startup.
  (setq projectile-enable-caching t)
  :config
  ;; Projectile saves its cache in this file. It's a good idea to know where it is.
  (setq projectile-project-list-file (expand-file-name ".projectile.cache" user-emacs-directory)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Language Server Protocol (LSP)
;;
;; LSP-Bridge is a fast LSP client for Emacs.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(straight-use-package 'yasnippet)
(yas-global-mode 1)
(use-package lsp-bridge
  :straight '(lsp-bridge :type git :host github :repo "manateelazycat/lsp-bridge"
                         :files (:defaults "*.el" "*.py" "acm" "core" "langserver" "multiserver" "resources")
                         :build (:not compile))
  :init
  (global-lsp-bridge-mode)
  :config
  (setq lsp-bridge-ui-handler 'vertico)
  (setq lsp-bridge-display-list-in-other-window nil))
(setq lsp-bridge-enable-with-tramp nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Xref and Code Navigation
;;
;; LSP (via lsp-bridge) is prioritized, with dumb-jump as a fallback.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package dumb-jump
  :straight t
  :init
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))
(setq xref-prompt-for-identifier
      '(not xref-find-definitions
            xref-find-definitions-other-window
            xref-find-definitions-other-frame
            xref-find-references
            xref-find-references-other-window
            xref-find-references-other-frame))
(setq xref-show-xrefs-function #'consult-xref)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Version Control
;;
;; Magit is the best Git client for Emacs.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(straight-use-package 'magit)

;; Git-Gutter
(straight-use-package 'git-gutter)
(require 'git-gutter)
(straight-use-package 'git-gutter-fringe)
(require 'git-gutter-fringe)
(define-fringe-bitmap 'git-gutter-fr:added    [224] nil nil '(center repeated))
(define-fringe-bitmap 'git-gutter-fr:modified [224] nil nil '(center repeated))
(define-fringe-bitmap 'git-gutter-fr:deleted  [128 192 224 240] nil nil 'bottom)
(global-git-gutter-mode t)
(setq git-gutter:update-interval 0.02)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code Quality and Formatting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Apheleia (Code Formatting Framework)
(straight-use-package 'apheleia)
(require 'apheleia)
(straight-use-package 'format-all)
(require 'format-all)

;; Flycheck (On-the-fly syntax checking)
(straight-use-package 'flycheck)
(global-flycheck-mode 1)
(setq flycheck-highlighting-mode 'lines)
(setq flycheck-display-errors-delay 0.5)
(setq flycheck-check-syntax-automatically '(mode-enable save new-line))
(setq flycheck-indication-mode 'right-fringe)

;; Flyspell (Spell Checking)
(straight-use-package 'flyspell)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Shell and Terminals
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Vterm (Emacs terminal emulator)
(use-package vterm
  :commands vterm
  :config
  (setq vterm-shell "zsh")
  (setq vterm-max-scrollback 10000)
  (setq vterm-copy-on-select-mouse t))

(add-hook 'vterm-mode-hook (lambda () (display-line-numbers-mode -1)))
(add-hook 'vterm-mode-hook (lambda () (setq-local buffer-face-mode-face '(:height 100))))

;; Direnv (Environment Variable Management)
(straight-use-package 'direnv)
(direnv-mode)
(setq direnv-always-show-log nil)
(setq direnv-always-show-summary nil)

;; Docker Integration
(straight-use-package 'docker)
(straight-use-package 'dockerfile-mode)
(straight-use-package 'docker-compose-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Other Packages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; PDF Tools
(use-package pdf-tools
  :straight t
  :config
  (pdf-loader-install)
  :hook (pdf-view-mode . (lambda () (display-line-numbers-mode -1))))

;; Recentf (Recent Files)
(setq recentf-max-menu-items 25)
(setq recentf-max-saved-items 250)
(setq recentf-save-file (expand-file-name "recentf" user-emacs-directory))
(recentf-mode 1)

;; Clipboard Integration
(setq x-select-enable-clipboard t)
(setq x-select-enable-primary t)
(if (display-graphic-p)
    (progn
      (setq select-enable-clipboard t)
      (setq mouse-yank-at-point t)
      (setq interprogram-paste-last-comment t)
      (setq gui-set-selection-tool 'x-clipboard-mode)))

;; Keybinding Discovery (which-key)
(which-key-mode 1)
(setq which-key-idle-delay 0.2)
(setq which-key-popup-type 'side-window)
(setq which-key-side-window-location 'bottom)
(setq which-key-sort-order 'which-key-description-order)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Language-Specific Configurations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Python
(straight-use-package 'python-mode)

;; web
(straight-use-package 'web-mode)

;; config stuff
(straight-use-package 'json-mode)
(straight-use-package 'yaml-mode)

;; LaTeX
(straight-use-package 'auctex)
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq TeX-master t)
(add-hook 'LaTeX-mode-hook 'visual-line-mode)
(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(add-hook 'LaTeX-mode-hook 'turn-on-reftex)
(setq reftex-plug-into-AUCTeX t)

;; Nix
(straight-use-package 'nix-mode)
(add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode))

;; Erlang
(use-package erlang
  :straight t
  :mode (("\\.erl\\'" . erlang-mode)
         ("\\.hrl\\'" . erlang-mode)))

;; Org Mode
(straight-use-package 'org)
(straight-use-package 'evil-org)
(setq org-directory "~/org/")
(defvar my-org-template-file (expand-file-name "templates/org-template.org" user-emacs-directory))
(require 'skeleton)
(define-skeleton my-org-file-frontmatter
  "Front matter for new org files with dynamic content and prompts."
  ""
  "#+TITLE: " (file-name-sans-extension (file-name-nondirectory buffer-file-name)) "\n"
  "#+DATE: <" (format-time-string "%Y-%m-%d %a %H:%M") ">\n"
  "#+TAGS:" "\n"
  "\n")
(add-to-list 'auto-insert-alist '("\\.org\\'" . my-org-file-frontmatter))
(setq org-return-follows-link t)
(add-hook 'org-mode-hook (lambda () (electric-indent-local-mode -1)))
(add-hook 'org-mode-hook (lambda () (electric-pair-local-mode -1)))
(add-hook 'org-mode-hook 'evil-org-mode)
(setq evil-org-ret-behavior 'org-return)

;; ROS Launch
(add-to-list 'auto-mode-alist '("\\.launch\\'" . nxml-mode))

