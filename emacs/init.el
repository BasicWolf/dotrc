;; After 10+ years of my old .emacs, I have to start from a complete scratch :)
;; The goal is to keep only the necessary stuff in a clean manner.
;; Good luck to me!
;; Inspired by
;; * https://github.com/a13/emacs.d
;; * https://github.com/howardabrams/dot-files


;; GLOBALS
(defvar init-dir (file-name-directory load-file-name))
(defvar var-dir (concat init-dir "var/"))

(defun main()
  (message "Main started")

  (dotemacs/repositories)
  (dotemacs/package-management)
  (dotemacs/ui-ux)
  (dotemacs/ux/highlight)
  (dotemacs/external-behaviour)
  (dotemacs/minibuffer)
  (dotemacs/search)
  (dotemacs/dired)

  ;; Major editor modes
  (dotemacs/elisp)
  (dotemacs/restructured-text)
  t)


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
    ;  from local or remote source code”. No more manual package installation
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

  (use-package use-package-ensure-system-package :ensure t)

  ;; GCMH - the Garbage Collector Magic Hack
  ;; https://gitlab.com/koral/gcmh
  (use-package gcmh
    :ensure t
    :init
    (gcmh-mode 1))

  (use-package paradox
    :ensure t
    :defer 1
    :config
    (paradox-enable))
  t)


(defun dotemacs/external-behaviour ()
  (message "dotemacs/external-behaviour")

  (use-package files
    :hook
    (before-save . delete-trailing-whitespace)
    :custom
    (require-final-newline t)
    ;; backup settings
    (backup-by-copying t)   ;; Copy all files, don't rename them.
    (delete-old-versions t) ;; Don't ask to delete excess backup versions.
    (kept-new-versions 8)   ;; Number of newest versions to keep.
    (kept-old-versions 0)   ;; Number of oldest versions to keep.
    (version-control t)     ;; Use version numbers for backups.d
    (backup-directory-alist
     `((".*" . ,(locate-user-emacs-file "var/backups"))))
    )
  )


(defun dotemacs/ui-ux ()
  (message "dotemacs/ui-ux")

  (use-package emacs
    :init
    (fset 'yes-or-no-p 'y-or-n-p)    ;; replace yes/no questions with y/n
    (toggle-indicate-empty-lines)    ;; show the empty lines at the end (bottom) of the buffer
    (blink-cursor-mode 0)            ;; the blinking cursor is pretty annoying, so disable it.
    (tool-bar-mode 0)                ;; disable toolbar
    (global-prettify-symbols-mode 1) ;; render "lambda" as λ
    :custom
    (show-trailing-whitespace t)     ;; show trailing whitespace in all modes
    (indent-tabs-mode nil)           ;; spaces instead of tabs
    (tab-width 4)                    ;; default tab width
    (frame-title-format
     '("Emacs - " buffer-file-name "%f" ("%b"))) ;; change emacs window title
    (column-number-mode 1)           ;; show the column number
    (transient-mark-mode 0)          ;; don't show region selection
    (global-display-fill-column-indicator-mode 1)  ;; show vertical column indicator ...
    (display-fill-column-indicator-column 80)      ;; ... on 80th column position
    (global-display-line-numbers-mode 1)           ;; show line numbers everywhere

    :bind
    ;; kill current buffer, without prompting
    (("\C-xk" . (lambda () (interactive) (kill-buffer (current-buffer)))))
    )

  ;; Enable shift-arrows switching between windows
  (use-package windmove
    :config
    (windmove-default-keybindings))

  ;; Undo / Redo windowing configuration (C-c left/right)
  (use-package winner
    :config
    (winner-mode 1))

  (use-package tabbar
    :ensure
    :bind
    (("M-<up>" . 'tabbar-backward-tab)
     ("M-<down>" . 'tabbar-forward-tab)
     ("M-S-<up>" . 'tabbar-backward-group)
     ("M-S-<down>" . 'tabbar-forward-group))
    :custom
    (tabbar-mode t)               ;; enable tabbar mode
    (tabbar-use-images nil)       ;; speed up thing displaying characters instead of images in left-top corner
    (tabbar-cycle-scope 'tabs))   ;; cycle through tabs of current group

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
      (desktop-save-mode 1)
      )
    )

  (use-package solarized-theme
    :ensure
    :config
    (load-theme 'solarized-light t)
    :custom
    (solarized-distinct-fringe-background t)

    ;; Determines how to draw underlined text.
    ;; nil - draw it at the baseline level of the font;
    ;; t -   draw the underline at the same height as the font’s descent line.
    (x-underline-at-descent-line t)
    ;; The brightness of the background hint to font renderer.
    (frame-background-mode 'light))
  t)


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
    (ivy-mode t))

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


(defun dotemacs/ux/highlight ()
  (message "dotemacs/ux/highlight")

  (use-package paren
    :config
    (show-paren-mode t))

  ;; Render parens, brackets, and braces according to their depth.
  ;; Each successive level is highlighted a different color.
  (use-package rainbow-delimiters
    :ensure t
    :hook
    (prog-mode . rainbow-delimiters-mode))

  ;; Highlight current cursor line in prog modes
  (use-package hl-line
    :hook
    (prog-mode . hl-line-mode))

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
    (dired-listing-switches "-alh")
    )

   t)


(defun dotemacs/elisp ()
  (message "dotemacs/elisp")

  (use-package lisp
    :init
    (defconst lisp--prettify-symbols-alist
      '(("lambda"  . ?λ)                  ; Shrink this
        ("."       . ?•)))                ; Enlarge this

    :hook
    (after-save . check-parens)) ;; check unbalanced parenthesis in current buffer

  (use-package eros
    :ensure t
    :init
    (add-hook 'emacs-lisp-mode-hook (lambda () (eros-mode 1))))
  t)

(defun dotemacs/restructured-text ()
  (message "dotemacs/restructured-text")

  (use-package rst)

  t)

(defun dotemacs/markdown ()
  (use-package markdown-mode :ensure t)
  t)

(main)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-archives
   '(("gnu" . "https://elpa.gnu.org/packages/")
     ("melpa" . "https://melpa.org/packages/")
     ("org" . "https://orgmode.org/elpa/")))
 '(package-enable-at-startup nil)
 '(package-selected-packages
   '(markdown-mode quelpa-use-package quelpa eros ag ivy-xref ivy tabbar epc use-package-ensure-system-package solarized-theme rainbow-delimiters paradox hl-todo highlight-numbers highlight-escape-sequences gcmh)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(hl-todo ((t (:inherit hl-todo :italic t)))))
