;; (defun tabbar-add-tab (tabset object &optional append_ignored)
;;   "Add to TABSET a tab with value OBJECT if there isn't one there yet.
;;  If the tab is added, it is added at the beginning of the tab list,
;;  unless the optional argument APPEND is non-nil, in which case it is
;;  added at the end."
;;   (let ((tabs (tabbar-tabs tabset)))
;;     (if (tabbar-get-tab object tabset)
;;         tabs
;;       (let ((tab (tabbar-make-tab object tabset)))
;;         (tabbar-set-template tabset nil)
;;         (set tabset (sort (cons tab tabs)
;;                           (lambda (a b) (string< (buffer-name (car a)) (buffer-name (car b))))))))))
