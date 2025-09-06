;; After 10+ years of my old .emacs, I have to start from a complete scratch :)
;; The goal is to keep only the necessary stuff in a clean manner.
;; Good luck to me!
;; Inspired by
;; * https://github.com/a13/emacs.d
;; * https://github.com/howardabrams/dot-files

;;; Code:
;; GLOBALS
(defvar init-dir (file-name-directory load-file-name))
(defvar var-dir (concat init-dir "var/"))



(defun main()
  (message "Main started")
  (dotemacs/custom)

  (dotemacs/repositories)
  (dotemacs/package-management)
  (dotemacs/env)
  (dotemacs/ui)
  (dotemacs/ux)
  (dotemacs/editor)
  (dotemacs/editor/fonts)
  (dotemacs/editor/highlight)
  (dotemacs/minibuffer)
  (dotemacs/search)
  (dotemacs/lang)

  (dotemacs/prog/shared)
  (dotemacs/prog/vc)
  (dotemacs/prog/snippets)

  ;; Major editor modes
  (dotemacs/dired)
  (dotemacs/org)
  (dotemacs/prog/docker)
  (dotemacs/prog/elisp)
  (dotemacs/prog/python)
  (dotemacs/prog/js)
  (dotemacs/prog/shell)
  (dotemacs/prog/restructured-text)
  (dotemacs/prog/configuration-files)
  (dotemacs/prog/latex)

  (dotemacs/mode/eshell)
  t)


(defun dotemacs/custom ()
  (setq-default custom-file "~/.emacs.d/custom.el")
  (load custom-file))

(defun dotemacs/repositories ()
  (message "dotemacs/repositories")
  ;; By default, Emacs knows about GNU ELPA only, add some more repositories.
  (require 'package)
  (customize-set-variable 'package-archives
                          `(,@package-archives
                            ("melpa" . "https://melpa.org/packages/")
                            ("org" . "https://orgmode.org/elpa/")
                            ))
  (customize-set-variable 'package-enable-at-startup nil)
  (package-initialize)
  t)


(defun dotemacs/package-management ()
  (message "dotemacs/package-management")
  ;; Use-package and Quelpa installation and setup
  ;; It can’t install itself so we have to bootstrap it
  (unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package)

    ;; Quelpa “is a tool to compile and install Emacs Lisp packages locally
    ;; from local or remote source code”. No more manual package installation
    ;; This is used for example to install dired+ directly from Github.
    (package-install 'quelpa)
    (package-install 'quelpa-use-package))

  (eval-when-compile
    ;; quelpa setup before use-package to avoid
    ;; "Failed to parse package XXX: use-package: Unrecognized keyword: :quelpa"
    (require 'quelpa)
    (require 'quelpa-use-package)
    (setq quelpa-update-melpa-p nil) ; "Don't update the MELPA git repo."
    (setq quelpa-use-package-inhibit-loading-quelpa t)

    (require 'use-package))

  (put 'use-package 'lisp-indent-function 1)

  (use-package use-package-core
    :custom
    ;; (use-package-verbose t)
    ;; (use-package-minimum-reported-time 0.005)
    (use-package-enable-imenu-support t))

  ;; Use use-package to extend its own functionality by some more useful keywords.
  (use-package system-packages
    :ensure t
    :custom
    (system-packages-noconfirm t))

  ;; GCMH - the Garbage Collector Magic Hack
  ;; https://gitlab.com/koral/gcmh
  (use-package gcmh
    :ensure t
    :init
    (gcmh-mode 1))

  ;; Project for modernizing Emacs' Package Menu. With improved appearance,
  ;; mode-line information. Github integration, customizability, asynchronous
  ;; upgrading, and more.
  (use-package paradox
    :ensure t
    :defer t
    :config
    (paradox-enable))

  ;; package showcase -- install a package for current session only
  (use-package try
    :ensure t
    :defer t)
  t)


(defun dotemacs/env ()
  (message "dotemacs/env")

  ;; Ensure environment variables inside Emacs look the same as in the user's shell.
  (use-package exec-path-from-shell
    :ensure t
    :defer 0.1
    :config

    (exec-path-from-shell-initialize))

  (use-package keychain-environment
    :ensure t
    :defer 0.1
    :init
    (keychain-refresh-environment) ;; load SSH environmental variables from user shell
    )
  t)


(defun dotemacs/ui ()
  (message "dotemacs/ui")

  (use-package emacs
    :init
    (setq fast-but-imprecise-scrolling t)  ;; supposed to make scrolling faster on hold
    (fset 'yes-or-no-p 'y-or-n-p)    ;; replace yes/no questions with y/n
    (toggle-indicate-empty-lines)    ;; show the empty lines at the end (bottom) of the buffer
    (blink-cursor-mode 0)            ;; the blinking cursor is pretty annoying, so disable it.
    (tool-bar-mode 0)                ;; disable toolbar
    (menu-bar-mode 0)                ;; disable menu bar
    (global-prettify-symbols-mode t) ;; render "lambda" as λ
    :custom
    (show-trailing-whitespace t)     ;; show trailing whitespace in all modes
    (indent-tabs-mode nil)           ;; spaces instead of tabs
    (tab-width 4)                    ;; default tab width
    (frame-title-format              ;; Friendly Emacs window title
     (list '(buffer-file-name "%f" (dired-directory dired-directory "%b"))
           " - Emacs " emacs-version))
    (column-number-mode 1)                         ;; show the column number
    (global-display-fill-column-indicator-mode 1)  ;; show vertical column indicator ...
    (display-fill-column-indicator-column 80)      ;; ... on 80th column position
    (global-display-line-numbers-mode 1)           ;; show line numbers everywhere

    :bind
    ;; kill current buffer, without prompting
    (("\C-xk" . (lambda () (interactive) (kill-buffer (current-buffer))))
     ("\C-xwd" . 'delete-trailing-whitespace)))

  ;; Enable shift-arrows switching between windows
  (use-package windmove
    :config
    (windmove-default-keybindings))

  ;; Undo / Redo windowing configuration (C-c left/right)
  (use-package winner
    :config
    (winner-mode 1))

  ;; (use-package tabbar
  ;;   :ensure
  ;;   :bind
  ;;   (("M-<up>" . 'tabbar-backward-tab)
  ;;    ("M-<down>" . 'tabbar-forward-tab)
  ;;    ("M-S-<up>" . 'tabbar-backward-group)
  ;;    ("M-S-<down>" . 'tabbar-forward-group))
  ;;   :custom
  ;;   (tabbar-mode t)               ;; enable tabbar mode
  ;;   (tabbar-use-images nil)       ;; speed up thing displaying characters instead of images in left-top corner
  ;;   (tabbar-cycle-scope 'tabs))   ;; cycle through tabs of current group

  (use-package desktop
    :config
    (progn
      (setq desktop-path `(,var-dir))
      (setq desktop-dirname var-dir)
      (setq desktop-base-file-name "emacs.desktop")
      (setq desktop-globals-to-save
            (append '((extended-command-history . 50)
                      (file-name-history . 200)
                      (grep-history . 50)
                      (compile-history . 50)
                      (minibuffer-history . 100)
                      (query-replace-history . 100)
                      (read-expression-history . 100)
                      (regexp-history . 100)
                      (regexp-search-ring . 100)
                      (search-ring . 50)
                      (shell-command-history . 50)
                      tags-file-name
                      register-alist)))
      (add-to-list 'desktop-modes-not-to-save 'dired-mode)
      (desktop-save-mode 1)))


  (use-package solarized-theme
    :ensure
    :config
    (load-theme 'solarized-light t)
    :custom
    (solarized-distinct-fringe-background t)
    (solarized-high-contrast-mode-line t)
    ;; Don't change size of org-mode headlines (but keep other size-changes)
    (solarized-scale-org-headlines nil)

    ;; Determines how to draw underlined text.
    ;; nil - draw it at the baseline level of the font;
    ;; t -   draw the underline at the same height as the font’s descent line.
    (x-underline-at-descent-line t)
    ;; The brightness of the background hint to font renderer.
    (frame-background-mode 'light)
    ;; Mark Solarized Light and Dark themes as safe to load, by explicitly
    ;; white-listing their *.el files hashes
    (custom-safe-themes
     '(; solarized light
       "2b0fcc7cc9be4c09ec5c75405260a85e41691abb1ee28d29fcd5521e4fca575b"
       ; solarized dark
       "7fea145741b3ca719ae45e6533ad1f49b2a43bf199d9afaee5b6135fd9e6f9b8"
       default))
    )

  ;; Automatically  switch between dark and light mode
  ;; base on system settings
  (use-package auto-dark
    :ensure t
    :after (solarized-theme)
    :custom
    (auto-dark-themes '((solarized-dark) (solarized-light)))
    :init (auto-dark-mode))

  ;; smooth mouse scrolling
  (use-package mwheel
    :custom
    (mouse-wheel-scroll-amount '(2
                                 ((shift) . 5)
                                 ((control))))
    (mouse-wheel-progressive-speed nil))

  ;; keyboard scroll one line at a time
  (setq scroll-step 1)

  ;; show time in bottom bbar
  (use-package time
    :defer t
    :custom
    (display-time-default-load-average nil)
    (display-time-24hr-format t)
    (display-time-mode t))
  t)


(defun dotemacs/ux ()
  (setq-default
   confirm-kill-processes nil    ;; exit emacs without asking to kill processes
   ring-bell-function 'ignore    ;; prevent beep sound.
   inhibit-startup-screen t      ;; hide startup screen
   initial-scratch-message nil)  ;; no text in scratch buffer

  ;; A fantastic mode which shows key combination completions in minibuffer
  (use-package which-key
    :ensure t
    :custom
    (which-key-show-transient-maps t) ;; also show transient keymap bindings
    :config
    (which-key-mode)))


(defun dotemacs/minibuffer ()
  (message "dotemacs/minibuffer")
  ;; Ivy is an interactive interface for completion in Emacs.
  ;; Ivy is for quick and easy selection from a list. When Emacs
  ;; prompts for a string from a list of several possible choices,
  ;; Ivy springs into action to assist in narrowing and picking
  ;; the right string from a vast number of choices.
  ;; Ivy strives for minimalism, simplicity, customizability and discoverability.
  ;; More at https://oremacs.com/swiper/
  (use-package ivy
    :ensure t

    :custom
    (ivy-count-format "%d/%d ")   ;; ivy completions counter format, e.g. 2/9
    (ivy-use-selectable-prompt t) ;; "Make the prompt line selectable"
    :config
    (ivy-mode t)

    ;; CHEATSHEET: ivy-immediate-done is bound to C-M-j
    )

  ;; TODO
  (use-package ivy-xref
    :ensure t
    :custom
    (xref-show-definitions-function #'ivy-xref-show-defs))

  t)


(defun dotemacs/search ()
  (message "dotemacs/search")
  ;; Superfast Silver Searcher tool
  (use-package ag
    :ensure t
    :defer t
    :ensure-system-package (ag . silversearcher-ag)
    :custom
    (ag-highlight-search t)) ;; Highlight the current search term

  ;; Dumb Jump is an Emacs "jump to definition" package with support for 50+
  ;; programming languages that favors "just working".
  ;; This means minimal -- and ideally zero -- configuration with absolutely
  ;; no stored indexes (TAGS) or persistent background processes
  (use-package dumb-jump
    :ensure t
    :defer t
    :custom
    (dumb-jump-selector 'ivy)
    (dumb-jump-prefer-searcher 'ag))
  t)


(defun dotemacs/editor/highlight ()
  (message "dotemacs/editor/highlight")

  (use-package paren
    :config
    (show-paren-mode t)
    :custom
    (show-paren-delay 0.15))

  ;; Render parens, brackets, and braces according to their depth.
  ;; Each successive level is highlighted a different color.
  (use-package rainbow-delimiters
    :ensure t
    :hook
    (prog-mode . rainbow-delimiters-mode))

  ;; Highlight current cursor line in all modes
  (use-package hl-line
    :init
    (global-hl-line-mode))

  ;; Render numeric literals in source code via configured font
  (use-package highlight-numbers
    :ensure t
    :hook
    (prog-mode . highlight-numbers-mode))

  ;; Render TODO in comments via Italic font
  (use-package hl-todo
    :ensure t
    :custom-face
    (hl-todo ((t (:inherit hl-todo :italic t))))
    :hook ((prog-mode . hl-todo-mode)
           (yaml-mode . hl-todo-mode)))
  t)


(defun dotemacs/dired ()
  (use-package dired+
    :quelpa
    (dired+ :fetcher github :repo "emacsmirror/dired-plus")
    :custom
    (diredp-hide-details-initially-flag nil)
    (toggle-diredp-find-file-reuse-dir 1)
    (dired-dwim-target t)
    (dired-recursive-copies 'top)
    (dired-recursive-deletes 'top)
    (diredp-hide-details-initially-flag nil)
    (dired-listing-switches "-alh --group-directories-first")
    :config
    (diredp-toggle-find-file-reuse-dir 1))

  (use-package dired-hide-dotfiles
    :ensure t
    :bind
    (:map dired-mode-map
          ("." . dired-hide-dotfiles-mode))
    :hook
    (dired-mode . dired-hide-dotfiles-mode))
  t)


(defun dotemacs/editor ()
  (message "dotemacs/editor")

  ;; When the lines in a file are so long that performance could suffer to an
  ;; unacceptable degree, we say "so long" to the slow modes and options enabled
  ;; in that buffer, and invoke something much more basic in their place.
  (global-so-long-mode)

  (use-package files
    :hook
    (before-save . (lambda () (unless (derived-mode-p 'markdown-mode)
                             (delete-trailing-whitespace))))
    :custom
    (require-final-newline t)
    (create-lockfiles nil)     ;; .#locked-file-name
    ;; backup settings
    (backup-by-copying t)   ;; Copy all files, don't rename them.
    (delete-old-versions t) ;; Don't ask to delete excess backup versions.
    (kept-new-versions 8)   ;; Number of newest versions to keep.
    (kept-old-versions 0)   ;; Number of oldest versions to keep.
    (version-control t)     ;; Use version numbers for backups.d
    (backup-directory-alist
     `((".*" . ,(locate-user-emacs-file "var/backups")))))

  ;; automatically revert buffers if file contents change
  (use-package autorevert
    :defer t
    :config
    (global-auto-revert-mode t))

  ;; Electric Pair mode is a global minor mode.  When enabled, typing an open parenthesis
  ;; automatically inserts the corresponding closing parenthesis, and vice versa.
  (use-package elec-pair
    :config
    (electric-pair-mode)
    :custom
    (electric-pair-delete-adjacent-pairs t)      ;; backspacing between two adjacent delimiters also automatically delete the closing delimiter
    (electric-pair-preserve-balance t)           ;; balance out the number of opening and closing delimiters
    (electric-pair-open-newline-between-pairs t) ;; inserting a newline between two adjacent pairs also automatically open an extra newline after point.
    (electric-pair-skip-whitespace t))           ;; skip whitespace forward before deciding whether to skip over the closing delimiter.

  (use-package multiple-cursors
    :ensure   t
    :bind
    (("C-M-SPC" . set-rectangular-region-anchor)
     ("C->" . mc/mark-next-like-this)
     ("C-<" . mc/mark-previous-like-this)
     ("C-c C->" . mc/mark-all-like-this)
     ("C-c C-SPC" . mc/edit-lines)))

  "dotemacs-editor")


(defun dotemacs/editor/fonts ()
  (message "dotemacs/editor/fonts")

  (use-package faces
    :defer t
    :custom
    (face-font-family-alternatives
     '(("Monospace" "Hack" "Ubuntu Mono")
       ("Monospace Serif" "Monospace")
       ("Serif" "DejaVu Serif" "Times New Roman" "serif")))
    :custom-face
    (variable-pitch ((t (:family "Serif" :height 120))))
    (fixed-pitch ((t (:family "Monospace Serif" :height 110))))
    (font-lock-comment-face ((t (:family "Monospace Serif" :height 120))))
    (mode-line ((t (:family "Monospace Serif" :height 90))))
    (mode-line-buffer-id ((t (:family "Monospace Serif" :height 90))))
    (mode-line-emphasis ((t (:family "Monospace Serif" :height 90))))
    (mode-line-highlight ((t (:family "Monospace Serif" :height 90))))
    (mode-line-inactive ((t (:family "Monospace Serif" :height 90))))
    (default ((t (:family "Monospace Serif" :height 130)))))
  t)


(defun dotemacs/lang ()
  (message "dotemacs/lang")

  ;; Flyspell enables on-the-fly spell checking in Emacs by the means of a minor mode.
  ;; Flyspell highlights incorrect words as soon as they are completed or as soon as
  ;; the cursor hits a new word.
  (use-package flyspell
    :ensure t
    :defer t
    :custom
    ;; printing messages for every word (when checking the entire buffer)
    ;; causes an enormous slowdown.
    (flyspell-issue-message-flag nil)
    (flyspell-delay 1))

  ;; Correcting misspelled words with flyspell using favourite interface (IVY)
  (use-package flyspell-correct
    :ensure t
    :after flyspell
    :bind (:map flyspell-mode-map ("C-;" . flyspell-correct-wrapper)))

  (use-package flyspell-correct-ivy
    :ensure t
    :after flyspell-correct)
  t)

(defun dotemacs/prog/shared ()
  (message "dotemac/prog/shared")

  ;; Language Server Protocol support for Emacs
  ;; The idea behind LSP is to standardize the protocol for how tools and
  ;; servers communicate, so a single Language Server can be re-used in multiple
  ;; development tools, and tools can support languages with minimal effort.
  (use-package lsp-mode
    :init
    ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
    (setq lsp-keymap-prefix "C-c l")
    :hook ((python-mode . lsp)
           (lsp-mode . lsp-enable-which-key-integration))
    :bind ("C-c ." . lsp-goto-type-definition)
    :commands lsp)

  ;; lsp-mode client leveraging pyright and basedpyright language server.
  (use-package lsp-pyright
    :ensure t
    :custom (lsp-pyright-langserver-command "basedpyright") ;; or pyright
    :hook (python-mode . (lambda ()
                           (require 'lsp-pyright)
                           (lsp))))

  ;; Contains all the higher level UI modules of lsp-mode,
  ;; like flycheck support and code lenses.
  (use-package lsp-ui
    :ensure t
    :commands lsp-ui-mode)

  (use-package lsp-ivy
    :ensure t
    :commands lsp-ivy-workspace-symbol)

  (use-package lsp-treemacs
    :ensure t
    :config
    (lsp-treemacs-sync-mode 1)
    :commands lsp-treemacs-errors-list)

  ;; optional if you want which-key integration
  (use-package which-key
    :config
    (which-key-mode))

  ;; Autocompletion ;;
  ;; Company is a text completion framework for Emacs.
  ;; The name stands for "complete anything". It uses pluggable back-ends and
  ;; front-ends to retrieve and display completion candidates.
  (use-package company
    :ensure t
    :bind
    (("C-<return>" . company-complete)
     ("C-." . company-files)
     (:map company-active-map
           ("C-n" . company-select-next-or-abort)
           ("C-p" . company-select-previous-or-abort)))
    :hook
    (after-init . global-company-mode))

  ;; control how documentation pops up when idling on completion candidate
  (use-package company-quickhelp
    :ensure t
    :defer t
    :custom
    (company-quickhelp-delay 3)
    (company-quickhelp-mode 1))

  ;; syntax checking
  (use-package flycheck
    :ensure t
    :hook
    (prog-mode . flycheck-mode))

  ;; Treemacs is a file and project explorer similar to NeoTree or vim’s NerdTree
  (use-package treemacs
    :custom
    (treemacs-project-follow-mode 1)
    (treemacs-git-mode 'deferred)
    :config
    (treemacs-hide-gitignored-files-mode 1)
    :hook
    (emacs-startup . treemacs-start-on-boot)
    (treemacs-mode . (lambda () (text-scale-decrease 2)))
    :bind
    (:map global-map
          ("C-x t t" . treemacs)))

  ;; projectile

  (use-package treemacs-projectile
    :after (treemacs projectile)
    :ensure t)

  ;; Trigger different comment actions taking the current location
  ;; of the point into acount.
  (use-package smart-comment
    :ensure t
    :bind ("M-;" . smart-comment))

  ;; Project interaction, management and navigation
  (use-package projectile
    :defer 0.2
    :ensure t
    :init
    (projectile-mode +1)
    :bind
    (:map mode-specific-map ("p" . projectile-command-map))  ;; C-c p ...
    :custom
    (projectile-completion-system 'ivy))

  ;; Set per-buffer environment variables, requires direnv
  ;; Use case: e.g. virtualenv
  (use-package envrc
    :ensure t
    :hook (after-init . envrc-global-mode))

  "dotemacs/prog/shared")


(defun dotemacs/prog/vc ()
  (message "dotemacs/prog/vc")

  (use-package magit
    :ensure t
    :custom
    (magit-clone-default-directory (expand-file-name "~/git"))
    (magit-completing-read-function 'ivy-completing-read "Force Ivy usage.")
    ;; If I type a new branch name instead of the base branch - accept the new branch
    ;; and ask for a base branch once again.
    ;; See discussion at https://github.com/magit/magit/issues/3647
    (magit-branch-read-upstream-first 'fallback))

  ;; Emacs major modes for various Git configuration files
  (use-package git-modes
    :ensure t
    :defer t)

  ;; Highlights diff compared to file in VCS
  (use-package diff-hl
    :ensure t
    :init
    (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
    (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
    :custom-face
    (diff-hl-change ((t (:background "#3a81c3"))))
    (diff-hl-insert ((t (:background "#7ccd7c"))))
    (diff-hl-delete ((t (:background "#ff7272"))))
    :config
    (global-diff-hl-mode))
  )

(defun dotemacs/prog/snippets ()
  (message "dotemacs/prog/snippets")

  (use-package yasnippet
    :defer 0.1
    :ensure t
    :custom
    (yas-prompt-functions '(yas-completing-prompt))
    :config
    (yas-reload-all)
    :hook
    (prog-mode  . yas-minor-mode))
  )


(defun dotemacs/prog/docker ()
  (message "dotemacs/prog/docker")

  (use-package dockerfile-mode
    :ensure t)
  (use-package docker-compose-mode
    :ensure t))


(defun dotemacs/prog/elisp ()
  (message "dotemacs/prog/elisp")

  (use-package lisp-mode
    :commands emacs-lisp-mode
    :init
    (defconst lisp--prettify-symbols-alist
      '(("lambda"  . ?λ)                  ; Shrink this
        ("."       . ?•)))                ; Enlarge this
    ;; check unbalanced parenthesis in current buffer
    (add-hook 'emacs-lisp-mode-hook (lambda () (add-hook 'after-save-hook 'check-parens nil 'buffer-local-only))))

  (use-package checkdoc
    :custom
    (checkdoc-force-docstrings-flag nil)) ;; no need to warn about missing docstrings

  (use-package eros
    :ensure t
    :init
    (add-hook 'emacs-lisp-mode-hook (lambda () (eros-mode 1))))
  t)


(defun dotemacs/prog/python ()
  (message "dotemacs/prog/python")

  (use-package pyvenv
    :ensure t
    :config
    (pyvenv-mode 1)
    :hook
    (pyvenv-post-activate-hooks
     .
     (lambda ()
       (when (bound-and-true-p lsp-mode) (lsp)))))

  ;; requires tree-sitter-python e.g. from OS packages
  (use-package python-pytest
    :ensure t
    :after python
    :bind
    (:map python-mode-map
          ("C-c t d" . python-pytest-dispatch)
          ("C-c t t" . python-pytest-run-def-or-class-at-point))
    :hook
    (python-pytest-finished-hook
     .
     (lambda ()
       (unless (with-current-buffer (current-buffer)
                 (save-excursion
                   (goto-char (point-min))
                   (re-search-forward "[[:digit:]] failed" nil t)))
         (run-with-timer 1 nil #'delete-window (get-buffer-window (current-buffer)))))))

  "dotemacs/prog/python")


(defun dotemacs/prog/shell ()
  (use-package sh-script
    :mode (("zshrc" . sh-mode)
           ("\\.zsh\\'" . sh-mode))))


(defun dotemacs/prog/restructured-text ()
  (message "dotemacs/prog/restructured-text")

  (use-package rst
    :hook
    (rst-mode . flyspell-mode)
    (rst-mode . visual-line-mode)))

(defun dotemacs/prog/js ()
  (message "dotemacs/prog/js")

  (use-package json-mode
    :ensure t
    :mode ("\\.json?\\'" . json-mode)))

(defun dotemacs/prog/configuration-files ()
  (message "dotemacs/prog/configuration-files")

  (use-package caddyfile-mode
    :ensure t))

(defun dotemacs/org ()
  (use-package org
    :init
    (setq org-hide-emphasis-markers t)
    :custom
    (org-hide-emphasis-markers t)
    (org-todo-keywords '((sequence "TODO(t)" "WAIT(w@/!)" "IN PROGRESS(p!)" "|" "DONE(d!)" "CANCELED(c@)")))
    (org-clock-persist 'history)  ;; Save the clock history across Emacs sessions
    (calendar-week-start-day 1)   ;; Start Calendar week on Monday
    :custom-face
    (org-link ((t (:inherit Monospace :italic t))))
    :init
    (org-clock-persistence-insinuate) ;; Save the clock history across Emacs sessions
    (org-indent-mode)                 ;; Display buffer in indented view
    ))

(defun dotemacs/markdown ()
  (use-package markdown-mode
    :ensure t
    :mode ("README\\.md\\'" . gfm-mode)  ;; github-flavored
    :hook
    (markdown-mode . flyspell-mode)
    :init
    (setq markdown-command "multimarkdown")))


(defun dotemacs/mode/eshell ()
  (message "dotemacs/mode/eshell")

  ;; smart display of output
  ;; hard to explain, just see for yourself
  (use-package em-smart
    :defer t
    :config
    (eshell-smart-initialize)
    :custom
    (eshell-where-to-jump 'begin)
    (eshell-review-quick-commands nil)
    (eshell-smart-space-goes-to-end t))

  ;; Fish-like history autosuggestions in eshell
  (use-package esh-autosuggest
    :ensure t
    :hook (eshell-mode . esh-autosuggest-mode))

  ;; Display extra information and color for your eshell prompt.
  ;; e.g. remote user, host, git branch, virtualenv etc.
  (use-package eshell-prompt-extras
    :ensure t
    :after (eshell esh-opt)
    :custom
    (eshell-prompt-function #'epe-theme-dakrone))

  ;; Show/hide eshell at the bottom of active window with directory of its buffer.
  (use-package eshell-toggle
    :ensure t
    :after projectile
    :custom
    (eshell-toggle-use-projectile-root t)
    (eshell-toggle-run-command nil)
    :bind
    ("M-`" . eshell-toggle))
  t)

(defun dotemacs/prog/latex ()
  (message "dotemacs/prog/latex")
  (use-package tex
    :pin gnu
    :ensure auctex
    :mode ("\\.tex\\$" . latex-mode)
    :custom
    (TeX-auto-save t)
    (TeX-parse-self t)
    (TeX-master nil)
    ))

(main)
