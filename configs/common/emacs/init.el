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
(setq truncate-lines nil)

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
(global-auto-revert-mode 1) ; Automatically reload files changed on disk

;; UI and Dialogs
(setq use-dialog-box nil)
(setq confirm-noninteractive-kill t)

;; Minibuffer
(defun stop-using-minibuffer ()
  (when (and (>= (recursion-depth) 1) (active-minibuffer-window))
    (abort-recursive-edit)))
(add-hook 'mouse-leave-buffer-hook 'stop-using-minibuffer)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Theme and Modeline
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package doom-themes
  :straight (:host github :repo "doomemacs/themes")
  :config
  (load-theme 'doom-dracula t))

(use-package doom-modeline
  :straight t
  :config
  (setq doom-modeline-height 1)
  (setq doom-modeline-major-mode-icon t)
  (setq doom-modeline-buffer-file-name-style 'truncate-at-project-dir)
  (setq doom-modeline-buffer-state-icon t)
  (setq doom-modeline-indent-info t)
  (setq doom-modeline-enable-word-count t)
  (setq doom-modeline-time-format "%H:%M")
  (setq doom-modeline-display-debug-info nil)
  (doom-modeline-mode 1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; HL Todo
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package hl-todo
  :straight t
  :config
  (global-hl-todo-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Vim Emulation (Evil Mode)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq evil-want-keybinding nil)
(use-package evil
  :straight t
  :config
  (evil-mode 1)
  (evil-set-undo-system 'undo-redo))

(use-package evil-leader
  :straight t
  :config
  (global-evil-leader-mode)
  (with-eval-after-load 'Messages
    (evil-leader-mode 1)
    (evil-mode 1))
  (setq evil-leader/leader "<SPC>")
  (evil-leader/set-leader evil-leader/leader))

(use-package evil-collection
  :straight t
  :config
  (evil-collection-init))

(fset 'evil-visual-update-x-selection 'ignore)

;; Custom Keybindings
(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "C-0") 'text-scale-adjust)

(defun reload-init-file ()
  "Reloads the Emacs initialization file (init.el)."
  (interactive)
  (load-file user-init-file)
  (message "init.el reloaded!"))

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
  "f a" 'format-all-buffer        ;; Format current buffer
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
  ;; AIDER (EVIL LEADER)
  "a c" 'aider-chat
  "a f" 'aider-add-current-file
  "a d" 'aider-drop-current-file
  "a r" 'aider-send-region
  "a i" 'aider-code-change
  "a t" 'aider-implement-todo
  "a a" 'aider-run-aider
  "a D" 'aider-diff
  "a C" 'aider-commit
  "a x" 'aider-clear-chat-and-context
  "a q" 'aider-quit
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

;; Undo-Fu
(use-package undo-fu
  :straight t)
(use-package undo-fu-session
  :straight t
  :config
  (undo-fu-session-global-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; AI Tools (Aider & Gptel)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my/ensure-ollama-is-running ()
  "Check if Ollama server is running, and start it if not."
  (interactive)
  (let ((ollama-process (shell-command-to-string "pgrep ollama")))
    (when (string-empty-p ollama-process)
      (message "Ollama server not running. Starting it now...")
      (start-process "ollama-server" nil "ollama" "serve")
      (sleep-for 0.5)))) ; Give the server a moment to start

;; Advise key functions to run our check first.
(advice-add #'completion-at-point :before #'my/ensure-ollama-is-running)
(advice-add #'aider-chat :before #'my/ensure-ollama-is-running)

(use-package aider
  :straight t
  :config
  (setq aider-args `("--config" ,(expand-file-name "~/.aider.conf.yml")))
  ;; Set a key binding for the transient menu
  (global-set-key (kbd "C-c a") 'aider-transient-menu)
  ;; Add aider magit function to magit menu
  (aider-magit-setup-transients)
  :hook (aider-chat-mode . corfu-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Completion Framework
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package vertico
  :straight t
  :init
  (vertico-mode)
  :bind (:map vertico-map
              ("C-<backspace>" . vertico-directory-up)
              ("<backspace>" . delete-backward-char)))

(use-package orderless
  :straight t
  :config
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil)
  (setq completion-category-overrides '((file (styles . (partial-completion))))))

(use-package marginalia
  :straight t
  :config
  (marginalia-mode))

(use-package consult
  :straight t
  :config
  (setq consult-preview-key nil))

(use-package swiper
  :straight t)
(use-package counsel
  :straight t)
(use-package counsel-projectile
  :straight t)

;; Corfu (Completion In Region) UI
(use-package corfu
  :straight t
  :init
  (global-corfu-mode)
  :config
  (setq corfu-cycle t)
  (setq corfu-auto nil) ; You requested manual completion
  (setq corfu-separator ?\s)
  (setq corfu-quit-at-boundary 'separator)
  :bind (:map corfu-map
              ("TAB" . corfu-complete)
              ("S-TAB" . corfu-complete-previous)))

;; Cape (Completion At Point Extensions) for backends
(use-package cape
  :straight t
  :init
  ;; Add the correct function from gptel to provide AI completions
  (add-to-list 'completion-at-point-functions #'gptel-completion-at-point)
  ;; Add other useful completion backends
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-keyword))

;; Add a manual keybinding to request completions
(define-key evil-insert-state-map (kbd "C-<SPC>") #'completion-at-point)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Projectile
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package projectile
  :straight t
  :init
  (projectile-mode +1)
  (setq projectile-enable-caching t)
  :config
  (setq projectile-project-list-file (expand-file-name ".projectile.cache" user-emacs-directory)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Language Server Protocol (LSP)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package yasnippet
  :straight t
  :config
  (yas-global-mode 1))

(use-package lsp-bridge
  :straight '(lsp-bridge :type git :host github :repo "manateelazycat/lsp-bridge"
                         :files (:defaults "*.el" "*.py" "acm" "core" "langserver" "multiserver" "resources")
                         :build (:not compile))
  :init
  (global-lsp-bridge-mode)
  :config
  (setq lsp-bridge-ui-handler 'vertico)
  (setq lsp-bridge-display-list-in-other-window nil)
  (setq lsp-bridge-enable-with-tramp nil))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Xref and Code Navigation
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package magit
  :straight t)

(use-package git-gutter
  :straight t
  :config
  (global-git-gutter-mode t)
  (setq git-gutter:update-interval 0.02))

(use-package git-gutter-fringe
  :straight t
  :config
  (define-fringe-bitmap 'git-gutter-fr:added    [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:modified [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:deleted  [128 192 224 240] nil nil 'bottom))

(defun my/disable-modes-in-tramp ()
  "Disable modes in remote TRAMP buffers."
  (when (file-remote-p default-directory)
    (git-gutter-mode -1)))

(add-hook 'find-file-hook #'my/disable-modes-in-tramp)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code Quality and Formatting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package apheleia
  :straight t)

(use-package format-all
  :straight t)

(use-package flycheck
  :straight t
  :config
  (global-flycheck-mode 1)
  (setq flycheck-highlighting-mode 'lines)
  (setq flycheck-display-errors-delay 0.5)
  (setq flycheck-check-syntax-automatically '(mode-enable save new-line))
  (setq flycheck-indication-mode 'right-fringe))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Spell Checking (Aspell)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package flyspell
  :straight t
  :config
  ;; Set Aspell as the spell checker
  (setq ispell-program-name "aspell")

  ;; Performance and dictionary settings
  (setq ispell-extra-args '("--sug-mode=ultra" "--lang=en_US" "--run-together"))

  ;; Make Flyspell faster by not checking while you are typing fast
  (setq flyspell-issue-message-flag nil)

  ;; Bindings for correcting words
  (define-key flyspell-mode-map (kbd "C-;") 'flyspell-correct-wrapper)

  ;; Hooks
  (add-hook 'text-mode-hook 'flyspell-mode)
  (add-hook 'prog-mode-hook 'flyspell-prog-mode))

(use-package flyspell-correct
  :straight t
  :after flyspell
  :bind (:map flyspell-mode-map ("C-;" . flyspell-correct-wrapper)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Shell and Terminals
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package vterm
  :commands vterm
  :config
  (setq vterm-shell "zsh")
  (setq vterm-max-scrollback 10000)
  (setq vterm-copy-on-select-mouse t))

(add-hook 'vterm-mode-hook (lambda () (display-line-numbers-mode -1)))
(add-hook 'vterm-mode-hook (lambda () (setq-local buffer-face-mode-face '(:height 100))))

(use-package direnv
  :straight t
  :config
  (direnv-mode)
  (setq direnv-always-show-log nil)
  (setq direnv-always-show-summary nil))

(use-package docker
  :straight t)
(use-package dockerfile-mode
  :straight t)
(use-package docker-compose-mode
  :straight t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Org Sync
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun org-git-pull ()
  "Pull updates for the git repo, but only if online."
  (interactive)
  (let ((org-path (expand-file-name org-directory)))
    (if (and buffer-file-name (string-prefix-p org-path (file-name-directory (buffer-file-name))))
        (let* ((repo-root (locate-dominating-file default-directory ".git"))
               (default-directory repo-root)
               (pull-command "if ping -c 1 -W 1 github.com &>/dev/null; then git pull --ff-only; else echo 'Offline. Skipping pull.'; fi"))
          (message "Checking connection...")
          (let ((output (shell-command-to-string pull-command)))
            (message "%s" (string-trim output))))
      (message "Not a file in your org-directory."))))

(defun org-git-sync ()
  "Sync (commit and push) the git repo if the current file is in 'org-directory'."
  (interactive)
  (let ((org-path (expand-file-name org-directory)))
    (if (and buffer-file-name (string-prefix-p org-path (file-name-directory (buffer-file-name))))
        (let* ((repo-root (locate-dominating-file default-directory ".git"))
               (default-directory repo-root))
          (shell-command "git add -A")
          (if (= 1 (call-process "git" nil nil nil "diff" "--cached" "--quiet"))
              (progn
                (shell-command (format "git commit -m \"Sync: %s\""
                                       (file-name-nondirectory buffer-file-name)))
                (message "Local commit successful. Pushing to remote...")
                (let ((exit-code (call-process "git" nil nil nil "push")))
                  (if (zerop exit-code)
                      (message "Org repo synced successfully!")
                    (message "Push failed. (Are you offline?) Commits are saved locally."))))
            (message "No changes to commit.")))
      (message "Not a file in your org-directory."))))

(evil-leader/set-key-for-mode 'org-mode
  "o p" 'org-git-pull
  "o s" 'org-git-sync)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Other Packages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package pdf-tools
  :straight t
  :mode ("\\.pdf\\'" . pdf-view-mode) ;; Bind .pdf to the viewer immediately
  :init
  (add-to-list 'file-coding-system-alist '("\\.pdf\\'" . no-conversion))
  :config
  (pdf-tools-install :no-query)
  ;; UPDATED HOOK: Disables line numbers AND git-gutter
  :hook (pdf-view-mode . (lambda () 
                           (display-line-numbers-mode -1)
                           (git-gutter-mode -1))))

(use-package recentf
  :config
  (setq recentf-max-menu-items 25)
  (setq recentf-max-saved-items 250)
  (setq recentf-save-file (expand-file-name "recentf" user-emacs-directory))
  (recentf-mode 1))

(setq x-select-enable-clipboard t)
(setq x-select-enable-primary t)
(if (display-graphic-p)
    (progn
      (setq select-enable-clipboard t)
      (setq mouse-yank-at-point t)
      (setq interprogram-paste-last-comment t)
      (setq gui-set-selection-tool 'x-clipboard-mode)))

(use-package which-key
  :straight t
  :config
  (which-key-mode 1)
  (setq which-key-idle-delay 0.2)
  (setq which-key-popup-type 'side-window)
  (setq which-key-side-window-location 'bottom)
  (setq which-key-sort-order 'which-key-description-order))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Language-Specific Configurations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Python
(use-package python-mode
  :straight t)

;; web
(use-package web-mode
  :straight t)

;; config stuff
(use-package json-mode
  :straight t)
(use-package yaml-mode
  :straight t)

;; LaTeX
(use-package auctex
  :straight t
  :config
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq TeX-master t)
  (add-hook 'LaTeX-mode-hook 'visual-line-mode)
  (add-hook 'LaTeX-mode-hook 'flyspell-mode)
  (add-hook 'LaTeX-mode-hook 'turn-on-reftex)
  (setq reftex-plug-into-AUCTeX t))

;; Nix
(use-package nix-mode
  :straight t
  :config
  (add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode)))

;; Erlang
(use-package erlang
  :straight t
  :mode (("\\.erl\\'" . erlang-mode)
         ("\\.hrl\\'" . erlang-mode)))

;; Org Mode
(use-package org
  :straight t
  :config
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
  (add-hook 'org-mode-hook (lambda () (electric-pair-local-mode -1))))

(use-package evil-org
  :straight t
  :config
  (add-hook 'org-mode-hook 'evil-org-mode)
  (setq evil-org-ret-behavior 'org-return))

;; ROS Launch
(add-to-list 'auto-mode-alist '("\\.launch\\'" . nxml-mode))
