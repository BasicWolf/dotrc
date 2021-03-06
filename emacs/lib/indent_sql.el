;; FROM gist.github.com/stuntgoat/8912558

(defun ig-get-previous-indentation ()
  "Get the column of the previous indented line"
  (interactive)
  (save-excursion
    (progn
      (move-beginning-of-line nil)
	  (skip-chars-backward "\n \t")
      (back-to-indentation))
    (current-column)))

(defun ig-get-current-indentation ()
  "Return column at current indentation"
  (interactive)
  (save-excursion
    (progn
      (back-to-indentation)
      (current-column))))

(defun ig-point-at-current-indentation ()
  "Return point at current indentation"
  (interactive)
  (save-excursion
    (progn
	  (move-to-column (ig-get-current-indentation))
      (point))))

(defun ig-point-at-column-on-line (col)
  "Returns the point at `col` on the current line"
  (interactive)
  (save-excursion
    (progn
      (move-to-column col)
      (point))))

(defun ig-move-line-to-column (col)
  "Move the line to col; fill with all spaces if moveing forward"
  (interactive "p")
  (let ((point-at-cur-indent (ig-point-at-current-indentation))
		(col-at-cur-indent (ig-get-current-indentation)))
    (cond (
		   (= col 0)
		   ;; delete to beginning of line or do nothing
		   (if (= col-at-cur-indent 0)
			   nil
			 (delete-region point-at-cur-indent (ig-point-at-column-on-line 0))))
		  (
           (< col col-at-cur-indent)
           ;; delete from our current point BACK to col
           (delete-region (ig-point-at-column-on-line col) point-at-cur-indent))
		  (
		   (> col col-at-cur-indent)
		   ;; delete all text from indent to beginning of line
		   (progn
			 (delete-region point-at-cur-indent (ig-point-at-column-on-line 0))
			 (move-beginning-of-line nil)
			 ;; add spaces forward
			 (insert (make-string col ?\s)))))))

(defun ig-indent-sql ()
  "Indent by `tab-width` at most 1 time greater than the previously indented line otherwise go to the beginning of the line indent forward by `tab-width`"
  (let ((previous (ig-get-previous-indentation))
        (current (ig-get-current-indentation)))
    (cond ( ;; exactly at previous line's indentation
           (= previous current)
		   (ig-move-line-to-column (+ current tab-width)))

          ( ;; current is greater than previous
           (> current previous)
           ;; exactly at one indentation forward from previous lines indent
           (if (= tab-width (- current previous))
               ;; move line to beginning
               (ig-move-line-to-column 0)
             ;; go back to previous indentation level
             (ig-move-line-to-column previous)))

          (t
           (ig-move-line-to-column (+ current tab-width))))))
