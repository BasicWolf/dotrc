;; AUTHOR: Zaur Nasibov, http://znasibov.info


;; GLOBALS
(defvar init-dir (file-name-directory load-file-name))
(defvar var-dir (concat init-dir "var/"))

;; CONFIG
(defvar dotemacs-evening-hours 18)
(defvar dotemacs-custom-file-path (concat init-dir "custom.el"))


;; MAIN
(defun main ()
  (message "Main started")
  (dotemacs-init-load-path)
  (dotemacs-init-for-debian)
  (dotemacs-init-package-archives)
  (dotemacs-init-load-packages)
  (dotemacs-init-utils)
  (dotemacs-init-internal-environment)
  (dotemacs-init-external-environment)
  (dotemacs-init-ui)
  (dotemacs-init-editor)
  (dotemacs-init-global-key-bindings)

  ;; programming modes
  (dotemacs-init-cedet)
  (dotemacs-init-compilation)
  (dotemacs-init-elisp)
  (dotemacs-init-python)
  (dotemacs-init-javascript)
  (dotemacs-init-coffeescript)
  (dotemacs-init-plsql)
  (dotemacs-init-rst)
  (dotemacs-init-web)
  (dotemacs-init-xml)
  ; (dotemacs-init-c)
  ; (dotemacs-init-c++)
  (dotemacs-init-rust)
  ; (dotemacs-init-latex)
  ; (dotemacs-init-scala)

  ;; ;; other modes
  (dotemacs-init-dired)
  (dotemacs-init-org)

  ;; (dotemacs-init-overrides)
  (dotemacs-init-local)

  (message "Main complete")
  t)
;; ************************************************************************** ;;
;; ************************************************************************** ;;



;; definitions for byte-compilation without warnings
(defvar c-basic-offset)
(defvar c-default-style)
(defvar coffee-mode-map)
(defvar jedi:complete-on-dot)
(defvar js2-mode-map)
(defvar python-mode-map)
(defvar TeX-auto-save)
(defvar TeX-parse-self)
(defvar TeX-modes)
(defvar TeX-PDF-mode)
(defvar LaTeX-section-hook)
(defvar TeX-output-view-style)
(defvar org-clock-persist)
(defvar web-mode-markup-indent-offset)
(defvar web-mode-code-indent-offset)
(defvar web-mode-css-indent-offset)
(defvar web-mode-script-padding)
(declare-function jedi:setup nil)


;; HELPERS
(defun require-or-install (package-name)
  (unless (require (quote package-name) nil 'noerror)
    (package-install package-name)
    (require package-name)))


(defun string-from-file (file-path)
  "Return file-paths's file content."
      (with-temp-buffer
        (insert-file-contents file-path)
        (buffer-string)))

(defun process-name (pid)
  "Return process name found by pid"
  (let ((proc-name-with-args (cdr (assq 'args (process-attributes pid)))))
    (if proc-name-with-args
        (car (split-string proc-name-with-args))
      nil)))


;; INITIALIZERS
(defun dotemacs-init-load-path ()
  (add-to-list 'load-path "/usr/share/emacs24/site-lisp/emacs-goodies-el/")
  (add-to-list 'load-path "/usr/share/emacs/site-lisp/")
  (add-to-list 'load-path (concat init-dir "lib/"))
  t)

(defun dotemacs-init-for-debian ()
  (defconst debian-emacs-flavor 'emacs24
    "A symbol representing the particular debian flavor of emacs running.
 Something like 'emacs20, 'xemacs20, etc.")
  t)


(defun dotemacs-init-package-archives ()
  (require 'package)
  (package-initialize)
  ; (add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
  (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))
  t)

(defun dotemacs-init-load-packages ()
  (require-or-install 'feature-mode)
  t)

(defun dotemacs-init-utils ()
  (load "tools.el")
  t)

(defun dotemacs-init-overrides ()
  (load "overrides.el")
  t)

(defun dotemacs-init-internal-environment ()
  (add-to-list 'backup-directory-alist (cons "." (concat var-dir "backups/")))
  ; (setq tramp-backup-directory-alist backup-directory-alist)

  (setq custom-file dotemacs-custom-file-path)
  (setq kept-new-versions 6)   ;; Number of newest versions to keep.
  (setq kept-old-versions 2)   ;; Number of oldest versions to keep.
  (setq version-control t)     ;; Use version numbers for backups.
  (setq delete-old-versions t) ;; Don't ask to delete excess backup versions.
  (setq backup-by-copying t)   ;; Copy all files, don't rename them.
  (setq gc-cons-threshold 20000000)
  t)


(defun dotemacs-init-external-environment ()
  (setq select-enable-clipboard t) ;; enable X-clipboard to work with emacs clipboard

  ;; Emacs Desktop
  (setq desktop-dirname             var-dir
        desktop-base-file-name      "emacs.desktop"
        desktop-base-lock-name      "lock"
        desktop-path                (list desktop-dirname)
        desktop-save                t
        desktop-files-not-to-save   "^$" ;reload tramp paths
        desktop-load-locked-desktop nil)

  (setq desktop-lock-path (concat desktop-dirname desktop-base-lock-name))

  (when (file-exists-p desktop-lock-path)
    (let* ((lock-pid-s (string-from-file desktop-lock-path))
           (lock-pid (string-to-number lock-pid-s))
           (lock-ps-name (process-name lock-pid))
           (emacs-ps-name (process-name (emacs-pid))))

      (when (not (string= emacs-ps-name lock-ps-name))
        (delete-file desktop-lock-path))))

  (desktop-save-mode 1)

  (add-to-list 'desktop-modes-not-to-save 'dired-mode)
  t)


(defun dotemacs-init-ui ()
  ;; theme
  ;; solarized
  (setq solarized-distinct-fringe-background t)
  (setq solarized-use-variable-pitch nil)
  (setq solarized-use-less-bold t)
  (setq solarized-scale-org-headlines nil)
  (setq x-underline-at-descent-line t)
  (setq frame-background-mode 'light)
  (load-theme 'solarized-light t)

  (menu-bar-mode 1)
  (tool-bar-mode 0)
  ; (scroll-bar-mode -1)
  (setq inhibit-startup-message t)        ;; hide startup message (splash screen)
  (setq overflow-newline-into-fringe 1)   ;; enable horizontal line overflow
  (winner-mode)                           ;; More convenient windowing mode
  (windmove-default-keybindings)          ;; enable shift-arrows switching between windows

  (setq frame-title-format '(buffer-file-name "%f" ("%b"))) ;; change emacs window title

  ;; tabbar tabs in emacs (global)
  (require 'tabbar)
  (tabbar-mode t)
  (global-set-key (kbd "M-<up>")       'tabbar-backward-tab)
  (global-set-key (kbd "M-<down>")     'tabbar-forward-tab)
  (global-set-key (kbd "M-S-<up>")     'tabbar-backward-group)
  (global-set-key (kbd "M-S-<down>")   'tabbar-forward-group)
  (setq tabbar-use-images nil)
  (setq tabbar-cycling-scope 'tabs)
  t)


(defun dotemacs-init-editor ()
  ;; set UTF-8 encoding
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)
  (prefer-coding-system 'utf-8)
  (setq tab-stop-list (number-sequence 4 200 4))  ;; tab stop every four characters
  (setq-default show-trailing-whitespace t)       ;; show trailing whitespace in all modes
  (setq-default require-final-newline t)
  (setq-default indent-tabs-mode nil)     ;; spaces instead of tabs
  (setq-default tab-width 4)              ;; default tab width
  (show-paren-mode)                       ;; highlight brackets and parethesis
  (global-hl-line-mode 1)                 ;; highlight current line
  (column-number-mode t)                  ;; show the column number
  (fset 'yes-or-no-p 'y-or-n-p)           ;; make all "yes or no" prompts show "y or n"
  (transient-mark-mode 0)                 ;; don't show region selection
  (put 'narrow-to-region 'disabled nil)   ;; enable narrowing

  ;; kill current buffer, without prompting
  (global-set-key
   "\C-xk"
   '(lambda () (interactive) (kill-buffer (current-buffer))))

  ;; advanced buffer menu
  (global-set-key (kbd "C-x C-b") 'ibuffer)
  (autoload 'ibuffer "ibuffer" "List buffers." t)

  ;; default grep command
  (setq grep-command "grep -nHr -e ")

  ;; fci mode 80 columns indicator
  ;; (require 'fill-column-indicator)
  ;; (setq fci-style 'rule)
  ;; (setq fci-rule-width 1)
  ;; (setq fci-rule-color "darkblue")
  ;; (setq-default fill-column 80)
  ;; (global-set-key "\C-x\M-f" 'fci-mode)

  ;; flyspell mode
  (setq flyspell-issue-welcome-flag nil) ;; improve flyspell performance
  (add-to-list 'auto-mode-alist '("\\.txt$" . flyspell-mode))

  ;; bury *scratch* buffer instead of kill it
  (defadvice kill-buffer (around kill-buffer-around-advice activate)
    (let ((buffer-to-kill (ad-get-arg 0)))
      (if (equal buffer-to-kill "*scratch*")
          (bury-buffer)
        ad-do-it)))

  ;; lines' numbers (!requres nlinum from ELPA)
  ;; !!! nlinum is currently broken, using linum
  ;(require-or-install 'nlinum)
  ;(global-nlinum-mode 1)
  (global-linum-mode)

  ;; !requires smartparens from ELPA
  (require-or-install 'smartparens)
  (require 'smartparens-config)
  (sp-pair "'" "'" :wrap "C-'")
  (sp-pair "\"" "\"" :wrap "C-\"")

  ;; Fonts
  (add-to-list 'default-frame-alist '(font . "Hack 13"))
  (set-face-attribute 'default nil :font "Hack 13")
  (set-face-attribute 'font-lock-comment-face nil :font "Ubuntu Mono 12" :foreground "Firebrick")

  ;; smart minibuffer: either ido or icicles
  (require-or-install 'flx-ido)
  (ido-mode)
  (ido-everywhere 1)
  (flx-ido-mode 1)
  ;; disable ido faces to see flx highlights.
  (setq ido-use-faces nil)
  (setq ido-enable-flex-matching t)
  (setq ido-default-buffer-method 'selected-window)

  ;; projectile
  (require-or-install 'projectile)
  (projectile-mode)
  (setq projectile-enable-caching t)
  (setq projectile-cache-file (expand-file-name "projectile.cache" var-dir))
  (setq projectile-known-projects-file (expand-file-name "projectile-bookmarks.eld" var-dir))
  (setq projectile-globally-ignored-directories (append '(".node_modules") projectile-globally-ignored-directories))

  (setq projectile-globally-ignored-directories
        (append '(".git" ".hg")
                projectile-globally-ignored-directories))

  (setq projectile-globally-ignored-files
        (append '("*.gz" "*.pyc" "*.pyo" "*.jar" "*.tar.gz" "*.tgz" "*.zip")
                projectile-globally-ignored-files))

  ; temporal projectile workaround for slow-rendering buffers
  (setq projectile-mode-line
        '(:eval (format " Projectile[%s]"
                        (projectile-project-name))))

  ;; flycheck
  (require-or-install 'flycheck)
  (add-hook 'after-init-hook #'global-flycheck-mode)

  ;; i-search
  (setq case-fold-search 1)
  t)


(defun dotemacs-init-global-key-bindings ()
  (global-set-key (kbd "C-?") 'help-command)
  (global-set-key (kbd "C-h") 'delete-backward-char)

  (global-set-key (kbd "C-x w d") 'delete-trailing-whitespace)
  (global-set-key (kbd "C-c c") 'comment-region)
  (global-set-key (kbd "C-c u") 'uncomment-region)
  (global-set-key (kbd "C-x C-M-r") 'revert-buffer)
  (global-set-key (kbd "C-c i") 'ido-goto-symbol)

  (global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)

  (global-set-key [f6] 'compile)
  (global-set-key [f10] 'next-error)
  (global-set-key [f11] 'previous-error)

  (add-hook
   'isearch-mode-hook
   (function
    (lambda ()
      (define-key isearch-mode-map "\C-h" 'isearch-mode-help)
      (define-key isearch-mode-map "\C-t" 'isearch-toggle-regexp)
      (define-key isearch-mode-map "\C-c" 'isearch-toggle-case-fold)
      (define-key isearch-mode-map "\C-j" 'isearch-edit-string))))
  t)


(defun dotemacs-init-cedet ()
  ;; Semantic
  (semantic-mode 1)
  (global-ede-mode 1)

  (global-semantic-idle-completions-mode)
  (global-semantic-idle-summary-mode)
  (global-semantic-idle-scheduler-mode)
  (global-semantic-highlight-func-mode)
  (global-semantic-decoration-mode 0)

  (setq semantic-idle-scheduler-idle-time 60)

  (which-function-mode 1)

  ;; solves problems with tabbar after excessive code helpers
  (global-semantic-stickyfunc-mode -1)

  (require 'semantic/util)
  (require 'eassist)

  (setq semanticdb-default-save-directory (concat var-dir "semanticdb"))1
  t)


(defun dotemacs-init-compilation ()
  (require 'compile)
  (setq mode-compile-always-save-buffer-p t)
  (setq compilation-scroll-output t)

  ;; TODO: put this somewhere else
  (setq compilation-finish-functions
        (lambda (buf str)
          ;; we don't want to close "grep" automatically
          (unless (string-equal "*grep*" (buffer-name buf))
            (unless (string-match "exited abnormally" str)
              ;; no errors, make the compilation window go away in a few seconds
              (run-at-time
               "1 sec" nil 'winner-undo) ;; uses winner-mode
              (message "No Compilation Errors!")))))
  t)


(defun dotemacs-init-dired ()
  (setq-default diredp-hide-details-initially-flag nil)
  (require 'dired+)
  (toggle-diredp-find-file-reuse-dir 1)
  (setq dired-dwim-target t)
  (setq dired-recursive-copies 'top)
  (setq dired-recursive-deletes 'top)
  (setq diredp-hide-details-initially-flag nil)
  (setq dired-listing-switches "-alh")
  (add-to-list 'dired-compress-file-suffixes
               '("\\.zip\\'" ".zip" "unzip"))
  t)


(defun dotemacs-init-elisp ()
  ;; display “lambda” as “λ”
  (global-prettify-symbols-mode 1)

  (define-key lisp-mode-shared-map (kbd "M-m") 'eassist-list-methods)

  ;; auto-compile *.el files
  (defun autocompile nil
    (interactive)
    (require 'bytecomp)
    (if (and (numberp (string-match "\\.el" buffer-file-name)) (not (numberp (string-match "init.el" buffer-file-name))))
        (byte-compile-file (buffer-file-name))))
  (add-hook 'after-save-hook 'autocompile)

  (defun my-elisp-mode-hook ()
    (smartparens-mode))

  (add-hook 'elisp-mode-hook 'my-elisp-mode-hook)
  t)


(defun dotemacs-init-python ()
  (declare-function python-shell-calculate-exec-path "python")

  (defalias 'workon 'pyvenv-workon)

  (defun flycheck-virtualenv-executable-find (executable)
    "Find an EXECUTABLE in the current virtualenv if any."
    (if (bound-and-true-p python-shell-virtualenv-root)
        (let ((exec-path (python-shell-calculate-exec-path)))
          (executable-find executable))
      (executable-find executable)))

  (defun flycheck-virtualenv-setup ()
    "Setup Flycheck for the current virtualenv."
    (setq-local flycheck-executable-find #'flycheck-virtualenv-executable-find))

  (defun my-python-mode-hook ()
    (flycheck-virtualenv-setup)

    (which-function-mode t)
    ;; spell check only strings/comments when in Python mode:
    (flyspell-prog-mode)

    (require 'smartparens-python)
    (smartparens-mode)

    (define-key python-mode-map (kbd "M-m") 'eassist-list-methods)

    (setq jedi:complete-on-dot t)
    (jedi:setup)
    (ac-flyspell-workaround)

    (define-key python-mode-map (kbd "C-<return>") 'jedi:complete)
    (define-key python-mode-map (kbd "C-c .") 'jedi:goto-definition)
    (define-key python-mode-map (kbd "C-c d") 'python-toggle-pudb)
    t)

  (defun python-toggle-pudb()
    "Insert import pudb; pu.db at cursor point."
    (interactive)
    (insert "import pudb; pu.db"))

  (add-hook 'python-mode-hook 'my-python-mode-hook)
  t)


(defun dotemacs-init-javascript ()
  (defun js-toggle-debugger()
      "Insert `debugger` at cursor point."
      (interactive)
      (insert "debugger;"))

  (defun my-js2-mode-hook ()
    (smartparens-mode)
    (define-key js2-mode-map (kbd "C-c d") 'js-toggle-debugger)
    (setq js2-strict-trailing-comma-warning nil)
    )

  (add-to-list 'auto-mode-alist '("\\.js" . js2-mode))
  (add-to-list 'auto-mode-alist '("\\.json" . json-mode))

  (add-hook 'js2-mode-hook 'my-js2-mode-hook)
  t)


(defun dotemacs-init-coffeescript ()
  (defun coffee-toggle-debugger()
    "Insert `debugger` at cursor point."
    (interactive)
    (insert "debugger"))

  (defun my-coffee-mode-hook ()
    (smartparens-mode)
    (define-key coffee-mode-map (kbd "C-c d") 'coffee-toggle-debugger))

  (add-hook 'coffee-mode-hook 'my-coffee-mode-hook)
  t)


(defun dotemacs-init-rust ()
  (require-or-install 'company-racer)
  (require-or-install 'racer)
  (require-or-install 'flycheck-rust)
  (require-or-install 'rust-mode)

  (setq company-racer-executable (f-expand "~/.cargo/bin/racer"))
  (unless (getenv "RUST_SRC_PATH")
    (setenv "RUST_SRC_PATH" (f-expand "~/.local/all/rust-src/src")))

  (defun my-rust-mode-hook ()
    (require 'smartparens-rust)
    (smartparens-mode)

    (company-mode)
    (cargo-minor-mode)

    (racer-mode)
    (eldoc-mode)
    (add-hook 'flycheck-mode-hook #'flycheck-rust-setup)
    (set (make-local-variable 'company-backends) '(company-racer))
    (local-set-key (kbd "M-.") 'racer-find-definition))

  (add-hook 'rust-mode-hook 'my-rust-mode-hook)

  (defun my-toml-mode-hook ()
    (if (equal (file-name-nondirectory buffer-file-name) "Cargo.toml")
        (cargo-minor-mode)))
  (add-hook 'toml-mode-hook 'my-toml-mode-hook)
  t)


(defun dotemacs-init-c ()
  (setq c-basic-offset 4)

  (defun my-c-mode-hook-binds ()
    (defvar c-mode-base-map)
    (define-key c-mode-base-map (kbd "M-o") 'eassist-switch-h-cpp)
    (define-key c-mode-base-map (kbd "M-m") 'eassist-list-methods)
    (define-key c-mode-base-map (kbd "M-h") 'mark-defun))
  (add-hook 'c-mode-common-hook 'my-c-mode-hook-binds)
  t)


(defun dotemacs-init-c++ ()
  (add-to-list 'auto-mode-alist '("\\.h" . c++-mode))
  (setq c-default-style "stroustrup")
  (setq c-basic-offset 4)

  (defun my-c++-mode-hook ()
    (c-set-offset 'innamespace 0))

  (add-hook 'c++-mode-hook 'my-c++-mode-hook)
  t)


(defun dotemacs-init-latex ()
  (load "auctex.el")
  (load "preview-latex.el")
  ;(load "cdlatex.el")
  ;(autoload 'cdlatex-mode "cdlatex" "CDLaTeX Mode" t)

  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq tex-dvi-view-command "xgdvi")
  (setq TeX-modes (quote (latex-mode)))
  (setq TeX-PDF-mode t) ; set pdf-mode to be active by default

  (setq LaTeX-section-hook
        '(LaTeX-section-heading
          LaTeX-section-title
          LaTeX-section-toc
          LaTeX-section-section
          LaTeX-section-label))

  (defun my-latex-mode-hook ()
    ;(turn-on-cdlatex t)
    (reftex-mode)
    (flyspell-mode)
    (add-to-list 'TeX-output-view-style '("^pdf$" . "evince %o %(outpage)")))
  (add-hook 'LaTeX-mode-hook 'my-latex-mode-hook t)
  t)

(defun dotemacs-init-scala ()
  (require 'ensime)
  (add-hook 'scala-mode-hook 'ensime-scala-mode-hook)
  t)

(defun dotemacs-init-plsql ()
  (load "indent_sql.el")
  (require-or-install 'plsql)

  (defun my-plsql-mode-hook ()
    (setq indent-line-function 'ig-indent-sql))
  (add-hook 'plsql-mode-hook 'my-plsql-mode-hook)

  (setq auto-mode-alist
        (append
         '(("\\.\\(p\\(?:k[bg]\\|ls\\)\\|sql\\)\\'" . plsql-mode))
         auto-mode-alist))
  t)

(defun dotemacs-init-rst ()
  (defun my-rst-mode-hook ()
    (flyspell-mode)
    (local-set-key (kbd "<return>") 'electric-newline-and-maybe-indent)
    (local-set-key (kbd "<S-return>") 'newline))

  (add-hook 'rst-mode-hook 'my-rst-mode-hook)
  t)

(defun dotemacs-init-web ()
  (defun my-web-mode-hook ()
    (setq web-mode-engines-alist
          '(("handlebars"    . "\\.hbs\\'")
            ("django"    . ".*templates/.*html\\'")
            ("django"    . "\\.djhtml\\'")
          ))

    (setq web-mode-markup-indent-offset 2)
    (setq web-mode-css-indent-offset 2)
    (setq web-mode-code-indent-offset 4)
    (setq web-mode-script-padding 0)
    (local-set-key (kbd "C-c c") 'web-mode-comment-or-uncomment))

  (add-hook 'web-mode-hook  'my-web-mode-hook)
  (add-to-list 'auto-mode-alist '("\\.html" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.handlebars" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.hbs" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.djhtml" . web-mode))
  t)

(defun dotemacs-init-xml ()
  (setq nxml-child-indent 4 nxml-attribute-indent 4)
  t)

(defun dotemacs-init-org ()
  (setq org-todo-keywords
        '((sequence "TODO(t)" "WAIT(w@/!)" "IN PROGRESS(p!)" "|" "DONE(d!)" "CANCELED(c@)")))

  (defun my-org-mode-hook ()
    (setq org-log-done t)

    (setq org-clock-persist 'history)
    (org-clock-persistence-insinuate)

    (org-indent-mode t)
    (global-set-key (kbd "<C-c l>") 'org-store-link)
    (global-set-key (kbd "<C-c a>") 'org-agenda)
    t)
  (add-hook 'org-mode-hook  'my-org-mode-hook)
  t)

(defun dotemacs-init-local ()
  (let ((local-el (concat init-dir "local.el")))
    (if (file-exists-p local-el)
        (load-file local-el)))
  t)

(main)
