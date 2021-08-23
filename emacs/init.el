;; After 10+ years of my old .emacs, I have to start from a complete scratch :)
;; The goal is to keep only the necessary stuff in a clean manner.
;; Good luck to me!
;; Inspired by
;; * https://github.com/a13/emacs.d



;; GLOBALS
(defvar init-dir (file-name-directory load-file-name))
(defvar var-dir (concat init-dir "var/"))

(defun main()
  (dotemacs/repositories)
  (dotemacs/bootstrap)
  (dotemacs/ui)
  )

(defun dotemacs/repositories ()
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

(defun dotemacs/bootstrap ()
  ;; Use-package installation and setup
  ;; It can’t install itself so we have to bootstrap it
  (unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))

  (eval-when-compile
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


(defun dotemacs/ui ()
  (use-package emacs
    :load-path "secrets"
    :init
    (fset 'yes-or-no-p 'y-or-n-p)  ;; replace yes/no questions with y/n
    (toggle-indicate-empty-lines)  ;; show the empty lines at the end (bottom) of the buffer
    (blink-cursor-mode -1)         ;; the blinking cursor is pretty annoying, so disable it.
    ;:custom
    ;(default-frame-alist '(tool-bar-lines 0))       ;; hide tool bar
    )

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

  ;; Enable shift-arrows switching between windows
  (use-package windmove
    :config
    (windmove-default-keybindings))

  ;; Undo / Redo windowing configuration (C-c left/right)
  (use-package winner
    :config
    (winner-mode 1))

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
    )

  (use-package rst)

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
   '(solarized-theme paradox use-package-ensure-system-package system-packages use-package epc)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
