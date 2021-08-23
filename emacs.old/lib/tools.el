(defun ido-goto-symbol (&optional symbol-list)
 "Refresh imenu and jump to a place in the buffer using Ido."
 (interactive)
 (unless (featurep 'imenu)
    (require 'imenu nil t))
 (cond
  ((not symbol-list)
   (let ((ido-mode ido-mode)
         (ido-enable-flex-matching
          (if (boundp 'ido-enable-flex-matching)
               ido-enable-flex-matching t))
          name-and-pos symbol-names position)
      (unless ido-mode
        (ido-mode 1)
        (setq ido-enable-flex-matching t))
      (while (progn
               (imenu--cleanup)
               (setq imenu--index-alist nil)
               (ido-goto-symbol (imenu--make-index-alist))
               (setq selected-symbol
                     (ido-completing-read "Symbol? " symbol-names))
               (string= (car imenu--rescan-item) selected-symbol)))
      (unless (and (boundp 'mark-active) mark-active)
          (push-mark nil t nil))
         (setq position (cdr (assoc selected-symbol name-and-pos)))
         (cond
          ((overlayp position)
           (goto-char (overlay-start position)))
          (t
           (goto-char position)))))
   ((listp symbol-list)
    (dolist (symbol symbol-list)
     (let (name position)
      (cond
       ((and (listp symbol) (imenu--subalist-p symbol))
        (ido-goto-symbol symbol))
       ((listp symbol)
        (setq name (car symbol))
        (setq position (cdr symbol)))
       ((stringp symbol)
        (setq name symbol)
        (setq position
         (get-text-property 1 'org-imenu-marker symbol))))
        (unless (or (null position) (null name)
                    (string= (car imenu--rescan-item) name))
          (add-to-list 'symbol-names name)
         (add-to-list 'name-and-pos (cons name position))))))))


(defun ido-jump-to-window ()
  (interactive)
  (let* ((swap (lambda (l)
                 (if (cdr l)
                     (cons (cadr l) (cons (car l) (cddr l)))
                   l)))
         ;; Swaps the current buffer name with the next one along.
         (visible-buffers (swap (mapcar '(lambda (window) (buffer-name (window-buffer window))) (window-list))))
         (buffer-name (ido-completing-read "Window: " visible-buffers))
         window-of-buffer)
    (if (not (member buffer-name visible-buffers))
        (error "'%s' does not have a visible window" buffer-name)
      (setq window-of-buffer
                (delq nil (mapcar '(lambda (window)
                                       (if (equal buffer-name (buffer-name (window-buffer window)))
                                           window
                                         nil))
                                  (window-list))))
      (select-window (car window-of-buffer)))))


(defun global-disable-mode (mode-fn)
  "Disable `MODE-FN' in ALL buffers."
  (interactive "a")
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (funcall mode-fn -1))))
