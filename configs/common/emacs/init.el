;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Management
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

;; Pin package versions to the lockfile tracked in nixos-config. The repo copy
;; is the source of truth; regenerate it with `emacs-lock freeze` (run by
;; `nix-flake-update`) or `M-x straight-freeze-versions`. `emacs-lock thaw`
;; forces every package back to it.
(let* ((init-dir (file-name-directory (file-truename load-file-name)))
       (repo-lock (expand-file-name "straight-versions.el" init-dir))
       (straight-lock (expand-file-name "straight/versions/default.el"
                                        user-emacs-directory)))
  (when (file-exists-p repo-lock)
    (make-directory (file-name-directory straight-lock) t)
    (copy-file repo-lock straight-lock t)))

;; Load org via straight early, before anything can pull in built-in Org.
(straight-use-package 'org)

;; FIX: Prevent "Feature provided by different file" errors for built-in
;; packages. Emacs 30 already ships recent versions of all of these; letting
;; straight build its own copies makes them collide with the built-ins that
;; load during startup (e.g. "Feature 'xref' is now provided by a different
;; file .../straight/build/xref/xref.elc"). eglot pulls the whole set as deps.
(dolist (pkg '(eglot project flymake xref eldoc jsonrpc external-completion))
  (add-to-list 'straight-built-in-pseudo-packages pkg))

;; Install use-package
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

;; cond-let is required by transient but not in MELPA/NonGNU — register before transient
(straight-use-package '(cond-let :type git :host github :repo "tarsius/cond-let"))

;; Ensure latest transient is installed before magit/docker/agent-shell load
(straight-use-package 'transient)

;; Inherit shell PATH (needed on NixOS for binaries like claude-code-acp, opencode)
(use-package exec-path-from-shell
  :straight t
  :config
  (exec-path-from-shell-initialize)) 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General Emacs Settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Keep windows balanced
(use-package balanced-windows
  :config
  (balanced-windows-mode))

;; Performance optimizations
(setq gc-cons-threshold 500000000) ; 100 MB

;; ignore warnings
(setq native-comp-async-report-warnings-errors 'silent)

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

(use-package unfill
  :straight t
  :config
  ;; Optional: bind M-q to toggle between fill and unfill globally
  (global-set-key [remap fill-paragraph] 'unfill-toggle))

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
(setq evil-want-C-u-scroll t)

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

(use-package restart-emacs
  :straight t
  :config
  (setq restart-emacs-restore-frames t))

(defun my/find-file-tramp ()
  "Open find-file with the TRAMP prefix pre-filled."
  (interactive)
  (minibuffer-with-setup-hook
      (lambda () (insert "/sftp:"))
    (call-interactively 'find-file)))

(evil-leader/set-key
;; --- FILE MANAGEMENT ---
  "f f" 'find-file
  "f t" 'my/find-file-tramp
  "f C" 'my/find-file-in-ros-container
  "f d" 'dired
  "f s" 'save-buffer
  "f w" 'write-file
  "f r" 'consult-recent-file
  "f R" 'rename-file
  "f D" 'delete-file
  "f c" 'clone-buffer
  "f a" 'format-all-buffer
  "f Q" 'save-buffers-kill-emacs
  "f q" 'kill-emacs
  "f n" 'my/open-in-nemo 

  ;; --- BUFFER MANAGEMENT ---
  "b b" 'consult-buffer
  "b k" 'kill-buffer
  "b K" 'kill-some-buffers
  "b n" 'next-buffer
  "b p" 'previous-buffer
  "b r" 'revert-buffer
  "b l" 'list-buffers

  ;; --- WINDOW MANAGEMENT ---
  "w /"       'split-window-right
  "w -"       'split-window-below
  "w v"       'split-window-right
  "w s"       'split-window-below
  "w c"       'delete-window
  "w o"       'delete-other-windows
  "w ="       'balance-windows
  "w m"       'maximize-window
  "<left>"    'windmove-left
  "<right>"   'windmove-right
  "<up>"      'windmove-up
  "<down>"    'windmove-down
  "w h"       'buf-move-left
  "w j"       'buf-move-down
  "w k"       'buf-move-up
  "w l"       'buf-move-right
  "w <left>"  'buf-move-left
  "w <right>" 'buf-move-right
  "w <up>"    'buf-move-up
  "w <down>"  'buf-move-down

  ;; --- SEARCH & REPLACE ---
  "s s" 'swiper
  "s r" 'query-replace
  "s R" 'query-replace-regexp
  "s f" 'counsel-rg
  "s p" 'counsel-projectile-grep

  ;; --- GIT (MAGIT) ---
  "g s" 'magit-status
  "g f" 'magit-fetch
  "g p" 'magit-pull
  "g c" 'magit-commit
  "g P" 'magit-push
  "g b" 'magit-branch
  "g B" 'magit-blame
  "g l" 'magit-log

  ;; --- PDF NOTER ---
  "n n" 'pdf-noter-add-note-at-point
  "n h" 'pdf-noter-highlight-region
  "n u" 'pdf-noter-unannotate-region
  "n l" 'pdf-noter-list-notes
  "n j" 'pdf-noter-goto-next-note
  "n k" 'pdf-noter-goto-previous-note
  "n d" 'pdf-noter-delete-note
  "n r" 'pdf-noter-reparse-notes
  "n s" 'pdf-noter-sync-notes

  ;; --- PROJECTILE ---
  "p f" 'projectile-find-file
  "p g" 'consult-ripgrep
  "p b" 'projectile-switch-to-buffer
  "p p" 'projectile-switch-project
  "p k" 'projectile-kill-buffers
  "p d" 'projectile-dired
  "p c" 'projectile-compile
  "p s" 'projectile-save-project-buffers

  ;; --- AGENT SHELL ---
  "a s" 'agent-shell
  "a n" 'agent-shell-new-shell
  "a t" 'agent-shell-toggle
  "a b" 'agent-shell-other-buffer
  "a c" 'agent-shell-anthropic-start-claude-code
  "a o" 'agent-shell-opencode-start-agent
  "a m" 'agent-shell-set-session-mode
  "a M" 'agent-shell-set-session-model
  "a i" 'agent-shell-interrupt
  "a r" 'agent-shell-send-region
  "a f" 'agent-shell-send-file

  ;; --- LSP (EGLOT) ---
  "c r" 'eglot-rename
  "c a" 'eglot-code-actions
  "c f" 'eglot-format
  "c d" 'xref-find-definitions
  "c D" 'xref-find-references
  "c i" 'eglot-find-implementation
  "c t" 'eglot-find-typeDefinition
  "c R" 'eglot-reconnect
  "c b" 'xref-go-back
  "c F" 'xref-go-forward

  ;; --- Flyspell ---
  "e h" 'flyspell-correct-at-point

  ;; --- ORG MODE ---
  "o a" 'org-agenda
  "o c" 'org-capture
  "o l" 'org-store-link
  "o b" 'org-iswitchb

  ;; --- GENERAL UTILITIES ---
  "x e" 'eval-buffer
  "x E" 'eval-last-sexp
  "x r" 'restart-emacs
)

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
;; Tramp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(connection-local-set-profile-variables
 'remote-config-profile
 '((tramp-direct-async-process . t)
   (python-shell-interpreter . "python3")
   (python-shell-interpreter-args . "-i")))

(connection-local-set-profiles
 '(:application tramp :protocol "sftp")
 'remote-config-profile)

(setq tramp-use-ssh-controlmaster-options nil)
(setq tramp-default-method "sftp")
(setq magit-tramp-pipe-stty-settings 'pty)

(with-eval-after-load 'tramp
  (with-eval-after-load 'compile
    (remove-hook 'compilation-mode-hook #'tramp-compile-disable-ssh-controlmaster-options))

  ;; Add Docker TRAMP method for ROS container development
  (add-to-list 'tramp-methods
               '("docker"
                 (tramp-login-program "docker")
                 (tramp-login-args (("exec" "-it") ("-u" "%u") ("%h") ("sh")))
                 (tramp-remote-shell "/bin/sh")
                 (tramp-remote-shell-args ("-i" "-c")))))

;; Convenience function to open files in ROS container
(defun my/find-file-in-ros-container ()
  "Open a file in a running ROS container via TRAMP.
Queries Docker for running containers named ros1* or ros2* and prompts
the user to select one."
  (interactive)
  (let* ((containers
          (split-string
           (string-trim
            (shell-command-to-string
             "docker ps --format '{{.Names}}' | grep -E '^ros[12]'"))
           "\n" t))
         (_ (when (null containers)
              (user-error "No running ROS containers found (ros1* or ros2*)")))
         (container (if (= (length containers) 1)
                        (car containers)
                      (completing-read "Select ROS container: " containers nil t)))
         (default-directory (format "/docker:%s:/ros_ws/src/" container)))
    (call-interactively 'find-file)))

;; NOTE: In-buffer LLM completion (minuet) and other LLM integrations were
;; removed; agent-shell below is the only AI tooling in this config. Ollama
;; runs as a systemd user service (see Nix config), not started from Emacs.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Agent Shell
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package acp
  :straight (:host github :repo "xenodium/acp.el"))

(use-package agent-shell
  :straight (:host github :repo "xenodium/agent-shell")
  :config
  (setq agent-shell-anthropic-authentication
        (agent-shell-anthropic-make-authentication :login t)))

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

(use-package swiper
  :straight t)
(use-package counsel
  :straight t)
(use-package counsel-projectile
  :straight t)

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
;; LSP (Eglot) - Native Emacs Client
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package corfu
  :straight t
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode) ;; Enable the doc popup system

  :config
  (setq corfu-auto t)
  (setq corfu-auto-delay 0.0)
  (setq corfu-auto-prefix 1)
  (setq corfu-cycle t)
  (setq corfu-preselect 'first)
  
  ;; Docs are manual (hidden by default)
  (setq corfu-popupinfo-delay nil)
  (setq corfu-popupinfo-max-height 20)

  ;; Prevent Minibuffer Conflicts
  (defun corfu-enable-in-minibuffer ()
    (when (where-is-internal #'completion-at-point (list (current-local-map)))
      (corfu-mode 1)))
  (add-hook 'minibuffer-setup-hook #'corfu-enable-in-minibuffer)

  :bind (:map corfu-map
              ;; TAB = Select/Insert
              ("TAB" . corfu-insert)
              ([tab] . corfu-insert)
              
              ;; Shift + Tab = Toggle Documentation
              ("S-TAB" . corfu-popupinfo-toggle)
              ([backtab] . corfu-popupinfo-toggle)

              ;; Shift + Arrows = Scroll Documentation
              ("S-<up>" . corfu-popupinfo-scroll-down) 
              ("S-<down>" . corfu-popupinfo-scroll-up)))

(use-package yasnippet
  :straight t
  :config
  (yas-global-mode 1))

(use-package eglot
  :ensure nil ;; Built-in to Emacs 29+
  :straight nil ;; use the built-in; don't let straight pull eglot + xref/eldoc/... from ELPA
  :init
  (defun my/eglot-ensure-smart ()
    "Start Eglot, allowing Docker TRAMP but skipping other remote connections."
    (let ((file (or (buffer-file-name) default-directory)))
      (if (and (file-remote-p file)
               (not (string-prefix-p "/docker:" file)))
          (message "Skipping LSP for non-Docker remote file: %s" file)
        (eglot-ensure))))
  :hook ((python-mode . my/eglot-ensure-smart)
         (nix-mode . my/eglot-ensure-smart)
         (c-mode . my/eglot-ensure-smart)
         (c++-mode . my/eglot-ensure-smart)
         (erlang-mode . my/eglot-ensure-smart)
         (elixir-mode . my/eglot-ensure-smart))
  :config
  (setq eglot-events-buffer-config '(:size 0 :format full))
  (setq eglot-autoshutdown t)
  (setq completion-cycle-threshold nil)

  (define-key eglot-mode-map (kbd "<backtab>") #'completion-at-point)

  ;; basedpyright diagnostic tuning: keep "standard" type-checking (same as
  ;; vanilla pyright) but mute the basedpyright-only strict-typing nags.
  ;; `pet' appends the project venv's :python (:pythonPath ...) on top of this
  ;; per-buffer, so completions/nav resolve against the right interpreter.
  (setq-default eglot-workspace-configuration
                '(:basedpyright
                  (:analysis
                   (:typeCheckingMode "standard"
                    :diagnosticSeverityOverrides
                    (:reportAny "none"
                     :reportExplicitAny "none"
                     :reportUnknownMemberType "none"
                     :reportUnknownArgumentType "none"
                     :reportUnknownVariableType "none"
                     :reportUnknownParameterType "none"
                     :reportUnknownLambdaType "none"
                     :reportMissingTypeStubs "none"
                     :reportUnusedCallResult "none"
                     :reportImplicitOverride "none")))))

  ;; Python server: basedpyright locally, pylsp-wrapper inside ROS containers
  ;; (the wrapper puts ROS packages on the server's PYTHONPATH).
  (defun my/eglot-python-command (&optional _interactive)
    "Return the Python LSP command for the current buffer."
    (if (and (file-remote-p default-directory)
             (string-match-p "^ros[12]"
                             (or (file-remote-p default-directory 'host) "")))
        '("/usr/local/bin/pylsp-wrapper")
      '("basedpyright-langserver" "--stdio")))

  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode) . my/eglot-python-command))

  ;; Nix
  (add-to-list 'eglot-server-programs '((nix-mode nix-ts-mode) . ("nixd")))

  ;; Erlang (elp) and Elixir (elixir-ls)
  (add-to-list 'eglot-server-programs '(erlang-mode . ("elp" "server")))
  (add-to-list 'eglot-server-programs '(elixir-mode . ("elixir-ls"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Project-aware Python tooling (pet) + eglot speedups
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Detect per-project venv / poetry / pipenv / conda and point eglot
;; (basedpyright), formatters, and the inferior shell at that interpreter.
(use-package pet
  :straight t
  :config
  (add-hook 'python-base-mode-hook #'pet-mode -10))

;; Speed up eglot's JSON-RPC via emacs-lsp-booster (binary comes from Nix).
(use-package eglot-booster
  :straight (:host github :repo "jdtsmith/eglot-booster")
  :after eglot
  :config
  (eglot-booster-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Route Completions to Vertico
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package consult
  :straight t
  :config
  (setq consult-preview-key nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Xref (Native Code Navigation)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq xref-prompt-for-identifier
      '(not xref-find-definitions
            xref-find-definitions-other-window
            xref-find-definitions-other-frame
            xref-find-references
            xref-find-references-other-window
            xref-find-references-other-frame))

(setq xref-show-xrefs-function #'consult-xref)
(setq xref-show-definitions-function #'consult-xref)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Version Control
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package magit
  :straight t)

(use-package git-gutter
  :straight t
  :hook (prog-mode . git-gutter-mode) ;; Only run in code buffers to prevent errors
  :config
  (setq git-gutter:update-interval 0.02))

(use-package git-gutter-fringe
  :straight t
  :config
  (define-fringe-bitmap 'git-gutter-fr:added    [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:modified [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:deleted  [128 192 224 240] nil nil 'bottom))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code Quality and Formatting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package apheleia
  :straight t)

(use-package format-all
  :straight t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Spell Checking (Aspell)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package flyspell
  :ensure nil
  :straight nil
  :config
  (setq ispell-program-name "aspell")
  (setq ispell-extra-args '("--sug-mode=ultra" "--lang=en_US" "--run-together"))
  (setq flyspell-issue-message-flag nil)
  (define-key flyspell-mode-map (kbd "C-;") 'flyspell-correct-wrapper)
  (add-hook 'text-mode-hook 'flyspell-mode)
  (add-hook 'LaTeX-mode-hook 'flyspell-mode)
  (add-hook 'prog-mode-hook 'flyspell-prog-mode))

(use-package flyspell-lazy
  :straight t
  :after flyspell
  :config
  (flyspell-lazy-mode 1))

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
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :init
  (add-to-list 'file-coding-system-alist '("\\.pdf\\'" . no-conversion))
  :config
  (pdf-tools-install :no-query)
  (setq pdf-view-display-size 'fit-height)
  (defvar my/pdf-view--last-frame-sizes nil
    "Alist of (FRAME . (WIDTH . HEIGHT)) in pixels, used to detect resizes.")
  (defun my/pdf-view-poll-resize ()
    "Redisplay pdf-view buffers when their frame's pixel size has changed.
Tiling window managers resize frames externally, and pdf-view's
built-in resize hooks (`window-configuration-change-hook',
`window-size-change-functions') don't reliably fire for that, so
pages go stale until the next page change. Polling is blunt but
actually works."
    (dolist (frame (frame-list))
      (let* ((size (cons (frame-pixel-width frame) (frame-pixel-height frame)))
             (cell (assq frame my/pdf-view--last-frame-sizes)))
        (unless (equal (cdr cell) size)
          (if cell
              (setcdr cell size)
            (push (cons frame size) my/pdf-view--last-frame-sizes))
          (dolist (win (window-list frame))
            (with-current-buffer (window-buffer win)
              (when (eq major-mode 'pdf-view-mode)
                (pdf-view-redisplay win))))))))
  (run-with-timer 0.5 0.5 #'my/pdf-view-poll-resize)
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

(use-package buffer-move
  :straight t)

(defun my/open-in-nemo ()
  "Open current directory in Nemo, ensuring LD_LIBRARY_PATH doesn't break it."
  (interactive)
  (let ((path (expand-file-name default-directory))
        ;; Create a temporary environment copy for this command only
        (process-environment (copy-sequence process-environment)))
    
    ;; Unset the variable causing the CXXABI error
    (setenv "LD_LIBRARY_PATH" nil)
    
    (if (executable-find "nemo")
        (progn
          (message "Launching Nemo at %s..." path)
          ;; 0 argument ensures it detaches immediately
          (call-process-shell-command (format "nemo \"%s\"" path) nil 0))
      (message "Error: Nemo not found in path."))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Language-Specific Configurations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Python
(use-package python
  :ensure nil
  :mode ("\\.py\\'" . python-mode)
  :interpreter ("python" . python-mode)
  :config)

;; Rust (Rustic)
(use-package rustic
  :straight t
  :config
  (setq rustic-lsp-client 'eglot) ;; Changed from nil to eglot
  (setq rustic-format-on-save t)) ;;

;; TOML
(use-package toml-mode
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

;; Elixir
(use-package elixir-mode
  :straight t)

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
  (setq org-startup-indented t)
  (add-hook 'org-mode-hook (lambda () (electric-indent-local-mode -1)))
  (add-hook 'org-mode-hook (lambda () (electric-pair-local-mode -1)))

  ;; --- Workflow: capture -> inbox -> review/refile -----------------------
  (defvar my/org-inbox (expand-file-name "inbox.org" org-directory)
    "Single drop point for captured todos and notes.")

  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "WAIT(w@/!)" "|" "DONE(d!)" "CANCELLED(c@)")))
  (setq org-log-done 'time
        org-log-into-drawer t)

  ;; Agenda starts from the inbox; vulpea (below) appends any roam note that
  ;; carries live TODOs, so nothing you capture goes invisible.
  (setq org-agenda-files (list my/org-inbox))
  (setq org-agenda-start-with-log-mode t)

  (setq org-refile-targets '((org-agenda-files :maxlevel . 3)
                             (nil :maxlevel . 3))
        org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil
        org-refile-allow-creating-parent-nodes 'confirm)

  (setq org-capture-templates
        `(("t" "Todo -> inbox" entry (file ,my/org-inbox)
           "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n%i"
           :empty-lines 1)
          ("n" "Note -> inbox" entry (file ,my/org-inbox)
           "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n%i"
           :empty-lines 1)
          ("l" "Link here -> inbox" entry (file ,my/org-inbox)
           "* %?  %a\n:PROPERTIES:\n:CREATED: %U\n:END:"
           :empty-lines 1)))

  (defun my/org-capture-todo () (interactive) (org-capture nil "t"))
  (defun my/org-capture-note () (interactive) (org-capture nil "n"))
  (defun my/open-inbox () (interactive) (find-file my/org-inbox))

  (defun my/org-search-all ()
    "Ripgrep across the entire org-directory (roam + course/work notes)."
    (interactive)
    (consult-ripgrep (expand-file-name org-directory)))

  (defun my/org-roam-adopt-file ()
    "Turn the current whole-file org note into an org-roam node.
Adds a top-level ID and moves the file into `org-roam-directory' so
it joins the graph and full-text search. Use to migrate old notes."
    (interactive)
    (unless (derived-mode-p 'org-mode) (user-error "Not an org buffer"))
    (save-excursion
      (goto-char (point-min))
      (org-id-get-create))
    (save-buffer)
    (let* ((dest (expand-file-name (file-name-nondirectory buffer-file-name)
                                   org-roam-directory)))
      (rename-file buffer-file-name dest 1)
      (set-visited-file-name dest)
      (save-buffer)
      (org-roam-db-sync)
      (message "Adopted into org-roam: %s" dest)))

  (unless (file-exists-p my/org-inbox)
    (with-temp-file my/org-inbox
      (insert "#+TITLE: Inbox\n#+FILETAGS: :inbox:\n\n")))

  ;; --- Global capture frame (spawned by the `org-capture` shell script /
  ;;     Hyprland SUPER+SHIFT+N keybind) ----------------------------------
  (defun my/org-capture-frame ()
    "Run `org-capture' in a throwaway frame for a window-manager keybind."
    (interactive)
    (require 'org-capture)
    (select-frame-set-input-focus (selected-frame))
    (condition-case nil
        (org-capture)
      (error (when (frame-parameter nil 'my-org-capture-frame)
               (delete-frame)))))

  (add-hook 'org-capture-after-finalize-hook
            (lambda ()
              (when (frame-parameter nil 'my-org-capture-frame)
                (delete-frame)))))

(use-package evil-org
  :straight t
  :config
  (add-hook 'org-mode-hook 'evil-org-mode)
  (setq evil-org-ret-behavior 'org-return))

(use-package org-roam
  :straight t
  :after org
  :custom
  (org-roam-directory (file-truename "~/org/roam/"))
  (org-roam-dailies-directory "daily/")
  (org-roam-completion-everywhere t)
  (org-roam-node-display-template
   (concat "${title:*} " (propertize "${tags:40}" 'face 'org-tag)))
  :config
  (unless (file-directory-p org-roam-directory)
    (make-directory org-roam-directory t))
  (require 'org-roam-dailies)

  (setq org-roam-capture-templates
        '(("d" "default" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n")
           :unnarrowed t)))
  (setq org-roam-dailies-capture-templates
        '(("d" "default" entry "* %<%H:%M>  %?"
           :target (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n"))))

  ;; Backlinks buffer as a docked side window (SPC r b to toggle).
  (add-to-list 'display-buffer-alist
               '("\\*org-roam\\*"
                 (display-buffer-in-side-window)
                 (side . right)
                 (window-width . 0.33)
                 (window-parameters . ((no-delete-other-windows . t)))))

  (org-roam-db-autosync-mode))

;; Fuzzy search across the whole note corpus (title search + full-text
;; ripgrep with live preview) and backlink navigation.
(use-package consult-org-roam
  :straight t
  :after org-roam
  :init
  (consult-org-roam-mode 1)
  :config
  (setq consult-org-roam-grep-func #'consult-ripgrep
        consult-org-roam-buffer-narrow-key ?r
        consult-org-roam-buffer-after-buffers t))

;; Interactive graph view in the browser (Obsidian-style).
(use-package org-roam-ui
  :straight (:host github :repo "org-roam/org-roam-ui" :files ("*.el" "out"))
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start nil))

(evil-leader/set-key
  ;; capture / inbox / agenda
  "o a" 'org-agenda
  "o c" 'org-capture
  "o t" 'my/org-capture-todo
  "o n" 'my/org-capture-note
  "o i" 'my/open-inbox
  "o l" 'org-store-link
  "o b" 'org-iswitchb
  "o /" 'my/org-search-all
  "o A" 'my/org-roam-adopt-file
  ;; roam: notes + linking + search
  "r f" 'org-roam-node-find
  "r i" 'org-roam-node-insert
  "r c" 'org-roam-capture
  "r b" 'org-roam-buffer-toggle
  "r g" 'org-roam-graph
  "r u" 'org-roam-ui-open
  "r s" 'consult-org-roam-search
  "r l" 'consult-org-roam-backlinks
  "r r" 'consult-org-roam-forward-links
  ;; roam dailies (journal)
  "r j" 'org-roam-dailies-capture-today
  "r J" 'org-roam-dailies-goto-today
  "r Y" 'org-roam-dailies-goto-yesterday
  "r n" 'org-roam-dailies-goto-next-note
  "r p" 'org-roam-dailies-goto-previous-note)

(evil-leader/set-key-for-mode 'org-mode
  "o r" 'org-refile
  "o w" 'org-refile)

;; --- vulpea: make roam notes with live TODOs show up in the agenda -------
(use-package vulpea
  :straight t
  :after org-roam
  :hook (org-roam-db-autosync-mode . vulpea-db-autosync-enable)
  :config
  (defun my/vulpea-buffer-p ()
    "Non-nil if the current buffer is an org-roam note."
    (and buffer-file-name
         (string-prefix-p
          (expand-file-name (file-name-as-directory org-roam-directory))
          (expand-file-name (file-name-directory buffer-file-name)))))

  (defun my/vulpea-project-p ()
    "Non-nil if the current buffer has any todo entry that is not done."
    (seq-find
     (lambda (type) (eq type 'todo))
     (org-element-map
         (org-element-parse-buffer 'headline)
         'headline
       (lambda (h) (org-element-property :todo-type h)))))

  (defun my/vulpea-project-update-tag ()
    "Add or remove the \"project\" filetag based on todo contents."
    (when (and (not (active-minibuffer-window))
               (my/vulpea-buffer-p))
      (save-excursion
        (goto-char (point-min))
        (let* ((tags (vulpea-buffer-tags-get))
               (original-tags tags))
          (if (my/vulpea-project-p)
              (setq tags (cons "project" tags))
            (setq tags (remove "project" tags)))
          (setq tags (seq-uniq tags))
          (when (or (seq-difference tags original-tags)
                    (seq-difference original-tags tags))
            (apply #'vulpea-buffer-tags-set tags))))))

  (defun my/vulpea-project-files ()
    "All org-roam files currently tagged as a project."
    (seq-uniq
     (seq-map
      #'car
      (org-roam-db-query
       [:select [nodes:file]
        :from tags
        :left-join nodes :on (= tags:node-id nodes:id)
        :where (like tag (quote "%\"project\"%"))]))))

  (defun my/vulpea-agenda-files-update (&rest _)
    (setq org-agenda-files
          (seq-uniq (cons my/org-inbox (my/vulpea-project-files)))))

  (add-hook 'find-file-hook #'my/vulpea-project-update-tag)
  (add-hook 'before-save-hook #'my/vulpea-project-update-tag)
  (advice-add 'org-agenda :before #'my/vulpea-agenda-files-update)
  (advice-add 'org-todo-list :before #'my/vulpea-agenda-files-update))

;; ROS Launch
(add-to-list 'auto-mode-alist '("\\.launch\\'" . nxml-mode))

;; C/C++
(use-package cc-mode
  :ensure nil
  :config
  ;; Set C style preferences
  (setq c-default-style "linux"
        c-basic-offset 4)

  ;; Add useful hooks
  (add-hook 'c-mode-hook
            (lambda ()
              (setq indent-tabs-mode nil)  ; Use spaces
              (setq show-trailing-whitespace t)))

  (add-hook 'c++-mode-hook
            (lambda ()
              (setq indent-tabs-mode nil)
              (setq show-trailing-whitespace t))))
