;; SHORTCUTS

;; cc q: toggles autofillmode

;; c-x c toggles c-mode. Sometimes autopair doesn't work in c-mode,
;; but works again with cx c.

;; c-m-k clears search highlights. C-S C-G also works.

(add-to-list 'load-path "~/.emacs.d/")

;; AUTOPAIR
;; comment if autopair.el is in standard load path_
(require 'autopair)
(autopair-global-mode) ;; enable autopair in all buffers_

;;
;; INDENTATION
;;

;; 4-space tab
(setq-default c-basic-offset 4)

;; remove trailing whitespace on save
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; This function and its key binding is oddly integrated with
;; ~/emacs/autopair.el. See my-python-default-handle-action in that
;; file for details.
(defun my-newline-and-indent-relative-maybe()
  (interactive)
  (end-of-line)
  (newline)
  (indent-relative-maybe))

(defun my-hard-newline-and-indent-relative-maybe()
  (interactive)
  (newline)
  (indent-relative-maybe)
  )

(defun my-eol-newline()
  (interactive)
  (end-of-line)
  (newline))

(defun back-to-indentation-or-beginning ()
  (interactive)
  (if (= (point) (save-excursion (back-to-indentation) (point)))
      (beginning-of-line)
    (back-to-indentation)))

(defun end-of-code-or-line ()
  "Move to EOL. If already there, to EOL sans comments.
    That is, the end of the code, ignoring any trailing comment
    or whitespace.  Note this does not handle 2 character
    comment starters like // or /*.  Such will not be skipped."
  (interactive)
  (if (not (eolp))
      (end-of-line)
    (skip-chars-backward " \t")
    (let ((pt (point))
          (lbp (line-beginning-position))
          (lim))
      (when (re-search-backward "\\s<" lbp t)
        (setq lim (point))
        (if (re-search-forward "\\s>" (1- pt) t)
            (goto-char pt)
          (goto-char lim)               ;; test here ->
          (while (looking-back "\\s<" (1- (point)))
            (backward-char))
          (skip-chars-backward " \t"))))))

;; moving text up and down
(defun move-text-internal (arg)
  (cond
   ((and mark-active transient-mark-mode)
    (if (> (point) (mark))
        (exchange-point-and-mark))
    (let ((column (current-column))
          (text (delete-and-extract-region (point) (mark))))
      (forward-line arg)
      (move-to-column column t)
      (set-mark (point))
      (insert text)
      (exchange-point-and-mark)
      (setq deactivate-mark nil)))
   (t
    (let ((column (current-column)))
      (beginning-of-line)
      (when (or (> arg 0) (not (bobp)))
        (forward-line)
        (when (or (< arg 0) (not (eobp)))
          (transpose-lines arg))
        (forward-line -1))
      (move-to-column column t)))))
(defun move-text-down (arg)
  "Move region (transient-mark-mode active) or current line
  arg lines down."
  (interactive "*p")
  (move-text-internal arg))
(defun move-text-up (arg)
  "Move region (transient-mark-mode active) or current line
  arg lines up."
  (interactive "*p")
  (move-text-internal (- arg)))

;; duplicate region
(defun duplicate-current-line-or-region (arg)
  "Duplicates the current line or region ARG times.
If there's no region, the current line will be duplicated. However, if
there's a region, all lines that region covers will be duplicated."
  (interactive "p")
  (let (beg end (origin (point)))
    (if (and mark-active (> (point) (mark)))
        (exchange-point-and-mark))
    (setq beg (line-beginning-position))
    (if mark-active
        (exchange-point-and-mark))
    (setq end (line-end-position))
    (let ((region (buffer-substring-no-properties beg end)))
      (dotimes (i arg)
        (goto-char end)
        (newline)
        (insert region)
        (setq end (point)))
      (goto-char (+ origin (* (length region) arg) arg)))))

;; Don't need this anymore.
;; ;; Toggles c-mode, because sometimes autopair doesn't work in
;; ;; c-mode. This seems to fix it each time.
;; (global-set-key [?\C-x ?c] 'c-mode)

;; Line wraps like Notepad
;; (global-visual-line-mode)
;;
;; Do this for individual file types, because it doesn't work well
;; with some, e.g. [i]buffers.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;                                                      TEXT MODES
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-hook
 'text-mode-hook
 (function
  (lambda()
    (turn-on-auto-fill) ;; fix paragraph
    (visual-line-mode 1)
    )))

(add-hook
 'c-mode-hook
 (function
  (lambda()
    (setq indent-tabs-mode nil)
    (setq c-indent-level 4)
    )
  )
 )
;; (add-hook 'org-mode-hook 'turn-on-auto-fill)
;; (add-hook 'LaTeX-mode (lambda()
;;			(auto-fill-mode nul)))

(defun my-latex-hook ()
  (local-set-key (kbd "C-c m") 'insert-mathinline)
  (local-set-key (kbd "C-c M") 'insert-mathdisplay)
  (local-set-key (kbd "C-c f") 'insert-frac)
  (local-set-key (kbd "C-c e") 'insert-emph)
  (local-set-key (kbd "C-c C-b C-b") 'insert-mathbb)
  )
(add-hook 'latex-mode-hook 'my-latex-hook)

(defun my-html-hook ()
  (toggle-truncate-lines)
  (setq indent-tabs-mode nil)
  (setq sgml-basic-offset 4)
  ;; (setq autopair-dont-activate t)
  (auto-fill-mode 0) ;; 0 turns a mode off, 1 on, not nil / t
  (local-set-key (kbd "C-]") 'insert-braces-percents) ;; The actual key is C-5
  (local-set-key (kbd "M-{") 'insert-double-braces)
  (local-set-key (kbd "RET") 'my-html-enter)
  (local-set-key (kbd "C-M-j") 'my-js-braces-newline-semicolon)
  (local-set-key (kbd "C-c RET") 'insert-p-tag)
  (local-set-key (kbd "C-c C-l") 'insert-li)
  (local-set-key (kbd "C-c C-i") 'insert-italics)
  (local-set-key (kbd "C-c C-o") 'insert-olist)
  (local-set-key (kbd "C-c C-a") 'insert-href)
  (local-set-key (kbd "C-c C-d") 'insert-div)
  (local-set-key (kbd "C-c C-k") 'my-html-insert-class)
  (local-set-key (kbd "C-c /") 'sgml-close-tag) ;; actually cc c/
  )
(add-hook 'html-mode-hook 'my-html-hook)

(defun my-css-hook()
  (local-set-key (kbd "C-c C-b") 'my-css-insert-background-color)
  (local-set-key (kbd "C-c C-c") 'my-css-insert-color)
  )
(add-hook 'css-mode-hook 'my-css-hook)

(add-hook
 'c++-mode-hook
 (function
  (lambda ()
    (setq indent-tabs-mode nil)
    (setq c-indent-level 4)
    (local-set-key (kbd "M-'") 'my-insert-pointer)
    (local-set-key (kbd "C-j") 'my-c++-semicolon-newline)
    (local-set-key (kbd "M-j") 'my-c++-braces-newline)
    )))

(add-hook
 'c-mode-hook
 (function
  (lambda ()
    (setq indent-tabs-mode nil)
    (setq c-indent-level 4)
    (local-set-key (kbd "M-'") 'my-insert-pointer)
    (local-set-key (kbd "M-j") 'my-c++-braces-newline)
    )))

(add-hook
 'php-mode-hook
 (function
  (lambda ()
    (setq indent-tabs-mode nil)
    (setq c-indent-level 4)
    (local-set-key (kbd "C-c C-p") 'my-php)
    (local-set-key (kbd "C-c C-_") 'my-php-inline)
    (local-set-key (kbd "C-c C-j") 'my-php-json-encode)
    (local-set-key (kbd "M-'") 'my-insert-pointer)
    (local-set-key (kbd "M-\"") 'my-insert-array-pointer)
    (local-set-key (kbd "C-j") 'my-c++-semicolon-newline)
    (local-set-key (kbd "M-j") 'my-c++-braces-newline)
    )))

(add-hook
 'python-mode-hook
 (function
  (lambda()
    (local-set-key (kbd "TAB") 'my-indent-region)
    (local-set-key (kbd "M-'") 'my-python-insert-doc-string)
    (local-set-key (kbd "C-j") 'my-newline-and-indent-relative-maybe)
    (local-set-key (kbd "M-j") 'my-python-end-colon-newline)
    (local-set-key (kbd "C-c C-h") 'python-insert-httpresponseredirect)
    )))

(add-hook
 'js-mode-hook
 (function
  (lambda()
    (local-set-key (kbd "C-j") 'my-c++-semicolon-newline)
    (local-set-key (kbd "M-j") 'my-c++-braces-newline)
    )))

(add-hook
 'emacs-lisp-mode-hook
 (function
  (lambda()
    (visual-line-mode 1)
    (local-set-key (kbd "C-j") 'my-emacs-lisp-paranthesis-newline)
    (local-set-key (kbd "M-j") 'my-emacs-lisp-function-newline)
    (local-set-key (kbd "C-c C-d") 'my-emacs-lisp-defun)
    (local-set-key (kbd "C-c C-i") 'elisp-insert-interactive)
    )
  )
 )

(add-hook
 'sh-mode-hook
 (function
  (lambda()
    (auto-fill-mode 0)
    (visual-line-mode 1)
    )))

;; Show line numbers on left margin
(global-linum-mode 1)

;; Delete selection
(delete-selection-mode 1)
(put 'autopair-insert-opening 'delete-selection t)
(put 'autopair-skip-close-maybe 'delete-selection t)
(put 'autopair-insert-or-skip-quote 'delete-selection t)
(put 'autopair-extra-insert-opening 'delete-selection t)
(put 'autopair-extra-skip-close-maybe 'delete-selection t)
(put 'autopair-backspace 'delete-selection 'supersede)
(put 'autopair-newline 'delete-selection t)

;; See if this fixes the autopair problem: sometimes delims don't close
(defun my-find-file-hook()
  (let ((fn (buffer-file-name)))
    (when (string-match "\\.c$" fn)
      (c-mode))
    (when (string-match "\\.js$" fn)
      (js-mode))
    ))
(add-hook 'find-file-hooks 'my-find-file-hook)

;;; Final version: while
(defun wc (beginning end)
  "Print number of words in the region."
  (interactive "r")
  (message "Counting words in region ... ")
  ;;; 1. Set up appropriate conditions.
  (save-excursion
    (let ((count 0))
      (goto-char beginning)
      ;;; 2. Run the while loop.
      (while (and (< (point) end)
                  (re-search-forward "\\w+\\W*" end t))
        (setq count (1+ count)))
      ;;; 3. Send a message to the user.
      (cond ((zerop count)
             (message
              "The region does NOT have any words."))
            ((= 1 count)
             (message
              "The region has 1 word."))
            (t
             (message
              "The region has %d words." count))))))

(setq scroll-step 1) ;; keyboard scroll one line at a time

(setq lazy-highlight-cleanup nil)
;; (global-set-key (kbd "C-M-k") 'lazy-highlight-cleanup) ;; can be
;; done with cs cg, i.e. start and cancel another search. Who knew
;; giving up can be so useful!

;; Kill from cursor to beginning of line.
;; Overrides numerical /universal-argument/ command cu
(defun my-kill-backwards (arg)
  (interactive "p")
  (if (= (point) (line-beginning-position))
      (backward-delete-char arg)
    (delete-region (point) (progn (back-to-indentation-or-beginning) (point)))))

(defun my-kill-eol (arg)
  (interactive "p")
  (if (= (point) (line-end-position))
      (delete-char 1)
    (delete-region (point) (progn (end-of-code-or-line) (point)))))

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;                                               setting variables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; opens file to last position
(require 'saveplace)
(setq-default save-place t)
(setq save-place-file "~/.emacs.d/saved-places")

;; open recent files
(require 'recentf)
(recentf-mode 1)

(global-auto-revert-mode 1) ;; auto reloads file if changed on disk

;; DEBUG. This guy saves odd stuff in your session, e.g. if you enable
;; global-visual-line mode, it'll stay that way forever. Or that's
;; what appeared to happen to me.
;;
;; TODO. Uncomment this.
;;
;; open files from last session
(desktop-save-mode 1)

(setq-default truncate-lines 1)

;; ;; Cool parentheses
;; (show-paren-mode 1)
;; (setq show-paren-style 'expression)

;; 4-space tabs in text mode, probably fundamental mode too
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq tab-stop-list (number-sequence 4 200 4))
(setq indent-line-function 'insert-tab)

;; ;; not using bookmark anymore
;; ;; save bookmark on set
;; (setq bookmark-save-flag 1)

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(desktop-path (quote ("~/.emacs.d/"))))

(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(lazy-highlight ((((class color) (min-colors 8)) (:background "blue"))))
 '(org-level-1 ((t (:background "blue" :foreground "white"))))
 '(org-level-2 ((t (:foreground "yellow"))))
 '(org-level-3 ((t (:foreground "cyan"))))
 '(show-paren-match ((((class color) (background light)) (:background "blue")))))

(defvar my-keys-minor-mode-map (make-keymap) "my-keys-minor-mode keymap.")

(define-minor-mode my-keys-minor-mode
  "A minor mode so that my key settings override annoying major modes."
  t " my-keys" 'my-keys-minor-mode-map)
(my-keys-minor-mode 1)

(defun my-minibuffer-setup-hook ()
  (my-keys-minor-mode 0))
(add-hook 'minibuffer-setup-hook 'my-minibuffer-setup-hook)

;;
;; django functions
;;
(defun insert-braces-percents ()
  (interactive)
  (insert "{%  %}")
  (backward-char 3))
(defun insert-double-braces ()
  (interactive)
  (insert "{{  }}")
  (backward-char 3))

;;
;; HTML functions
;;
(defun insert-p-tag ()
  ;; Insert HTML paragraph.
  (interactive)
  (insert "<p></p>")
  (backward-char 4)
  )

(defun insert-italics ()
  ;; Insert HTML italics.
  (interactive)
  (insert "<i></i>")
  (backward-char 4)
  )

(defun insert-olist ()
  ;; Insert HTML ordered list
  (interactive)
  (insert "<ol></ol>")
  (backward-char 5)
  )

(defun insert-li ()
  ;; Insert HTML list item.
  (interactive)
  (insert "<li></li>")
  (backward-char 5)
  )

(defun insert-href()
  ;; Insert HTML links
  (interactive)
  (insert "<a href=\"\">")
  (backward-char 2)
  )

(defun insert-div()
  ;; Insert HTML links
  (interactive)
  (insert "<div >")
  (backward-char 1)
  )

;;
;; latex functions
;;
(defun insert-mathinline ()
  ;; Insert HTML math inline.
  (interactive)
  (insert "\\(\\)")
  (backward-char 2)
  )
(defun insert-mathdisplay ()
  ;; Insert HTML math inline.
  (interactive)
  (insert "\\[\\]")
  (backward-char 2)
  )
(defun insert-emph ()
  ;; Insert LaTeX emph.
  (interactive)
  (insert "\\emph{}")
  (backward-char 1))
(defun insert-mathbb ()
  ;; Insert LaTeX blackboard font, e.g. for the set of real numbers R.
  (interactive)
  (insert "\\mathbb{}")
  (backward-char 1))
(defun insert-frac ()
  ;; Insert LaTeX emph.
  (interactive)
  (insert "\\frac{}{}")
  (backward-char 3))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;                                         global function dump here
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my-html-insert-class()
  (interactive)
  (insert "class=\"\"")
  (backward-char 1)
  )

(defun my-php()
  (interactive)
  (insert "<?php\n\n?>")
  (previous-line)
  )

(defun my-php-inline()
  (interactive)
  (insert "<?php  ?>")
  (backward-char 3)
  )

(defun my-php-json-encode()
  (interactive)
  (insert "json_encode()")
  (backward-char 1)
  )

(defun python-insert-httpresponseredirect()
  (interactive)
  (insert "return HttpResponseRedirect(reverse(''))")
  (backward-char 3)
  )

(defun my-js-console-log()
  (interactive)
  (insert "console.log()")
  (backward-char 1)
  )

(defun my-js-insert-json-stringify()
  (interactive)
  (insert "JSON.stringify(, 0, 2)")
  (backward-char 7)
  )

(defun my-js-new-function()
  (interactive)
  (insert "function")
  )

(defun my-js-async-waterfall()
  (interactive)
  (indent-according-to-mode)
  (insert "async.waterfall([")
  (newline 1)
  (insert "function(done){")
  (indent-according-to-mode)
  (newline 2)
  (insert "},")
  (indent-according-to-mode)
  (newline 1)
  (insert "], function(er){")
  (indent-according-to-mode)
  (newline 1)
  (indent-according-to-mode)
  (newline 1)
  (insert "})")
  (indent-according-to-mode)
  (previous-line 4)
  (indent-according-to-mode)
  )

(defun my-js-new-function-done()
  (interactive)
  (indent-according-to-mode)
  (insert "function(done){")
  (newline 2)
  (insert "}")
  (indent-according-to-mode)
  (previous-line 1)
  (indent-according-to-mode)
  )

(defun my-js-braces-newline-semicolon()
  (interactive)
  (end-of-code-or-line)
  (backward-delete-char 1)
  (insert "{")
  (newline)
  (indent-relative-maybe)
  (insert "});")
  (previous-line)
  (end-of-code-or-line)
  (newline-and-indent)
  )

(defun xm-insert-delay()
  (interactive)
  (insert "Delay 1")
  )

(defun xm-insert-key()
  (interactive)
  (insert "KeyStrPress \nKeyStrRelease ")
  (previous-line)
  (end-of-line)
  )

(defun my-save-all-no-question()
  (interactive)
  (save-some-buffers 1)
  )

(defun my-emacs-lisp-defun()
  (interactive)
  (if (> (length (thing-at-point 'line)) 1)
      (my-delete-line)
  )
  (beginning-of-line)
  (insert "(defun )")
  (backward-char)
  )

(defun elisp-insert-interactive()
  (interactive)
  (insert "(interactive)")
  (backward-char)
)

(defun my-emacs-lisp-function-newline()
  (interactive)
  (end-of-code-or-line)
  (backward-char)
  (newline-and-indent)
  (newline-and-indent)
  (previous-line)
  (indent-for-tab-command)
  )

(defun my-emacs-lisp-paranthesis-newline()
  (interactive)
  (end-of-code-or-line)
  (newline-and-indent))

(defun my-kill-buffer()
  (interactive)
  (kill-buffer nil))

(defun my-set-register()
  (interactive)
  (set-register (read-char-exclusive "type a char . . . ") (append '(file) (buffer-file-name))))

;; ;; Original idea from
;; ;; http://www.opensubscriber.com/message/emacs-devel@gnu.org/10971693.html
(defun my-comment-dwim-line (&optional arg)
  "Replacement for the comment-dwim command. If no region
  selected and current line is not blank and we are not at the
  end of the line, then comment current line.  Replaces default
  behaviour of comment-dwim, when it inserts comment at the end
  of the line."
  (interactive "*P")
  (if mark-active
      (comment-dwim arg)
    (comment-or-uncomment-region
     (line-beginning-position) (line-end-position))))

(defun my-c++-semicolon-newline()
  (interactive)
  (end-of-code-or-line)
  (insert ";")
  (newline-and-indent)
  )



(defun my-c++-braces-newline()
  (interactive)
  (end-of-code-or-line)
  (insert "{")
  (newline)
  (indent-relative-maybe)
  (insert "}")
  (previous-line)
  (end-of-code-or-line)
  (newline-and-indent))

(defun my-python-end-colon-newline()
  (interactive)
  (end-of-code-or-line)
  (insert ":")
  (my-newline-and-indent-relative-maybe)
  (indent-by-adding-4-spaces))

(defun my-select-line()
  (interactive)
  (back-to-indentation-or-beginning)
  (set-mark-command nil)
  (end-of-code-or-line)
  )

(defun my-open-line(N)
  (interactive "p")
  (save-excursion
    (end-of-code-or-line)
    (open-line N))
  )

(defun my-backward-delete-word (arg)
  "Delete characters backward until encountering the beginning of a word.
With argument ARG, do this that many times."
  (interactive "p")
  (delete-region (point) (progn (backward-word arg) (point))))

(defun my-forward-delete-word (arg)
  "Delete characters forward until encountering the beginning of a word.
With argument ARG, do this that many times."
  (interactive "p")
  (delete-region (point) (progn (forward-word arg) (point))))

(defun rigid-indent-region (N)
  (indent-rigidly (min (mark) (point)) (max (mark) (point)) (* N 4))
  (setq deactivate-mark nil))

(defun my-indent-region (N)
  (interactive "p")
  (if mark-active
      (rigid-indent-region N)
    (tab-to-tab-stop)))

(defun indent-by-adding-4-spaces ()
  "Adds 4 spaces to beginning of of line"
  (interactive)
  (if (eobp)         ;; check end of buffer
      (open-line 1)) ;; otw insert won't work
  (if (= (length (thing-at-point 'line)) 1) ;; line empty (contains only EOL)
      (insert "    ")
    (save-excursion
      ;; (save-match-data
      (beginning-of-line)
      (insert "    "))
    )
  ) ;;)

(defun my-indent-region-or-line (N)
  (interactive "p")
  (if mark-active
      (rigid-indent-region N)
    (indent-by-adding-4-spaces)))

(defun un-indent-by-removing-4-spaces ()
  "remove 4 spaces from beginning of of line"
  (interactive)
  (save-excursion
    (save-match-data
      (beginning-of-line)
      ;; get rid of tabs at beginning of line
      (when (looking-at "^\\s-+")
        (untabify (match-beginning 0) (match-end 0)))
      (when (looking-at "    ") ; (concat "^" (make-string tab-width ?\ )))
        (replace-match "")))))

(defun my-unindent-region (N)
  (interactive "p")
  (if mark-active
      (progn (indent-rigidly (min (mark) (point)) (max (mark) (point)) (* N -4))
             (setq deactivate-mark nil))
    (un-indent-by-removing-4-spaces)))

(defun my-copy-line ()
  (end-of-code-or-line)
  (back-to-indentation-or-beginning)
  (kill-ring-save (point) (progn (end-of-code-or-line) (point))))

(defun my-copy-region-or-line ()
  (interactive)
  (if mark-active
      (progn (kill-ring-save (min (mark) (point)) (max (mark) (point)))
             (setq deactivate-mark t))
    (my-copy-line)))

(defun my-kill-line ()
  (interactive)
  (end-of-code-or-line)
  (back-to-indentation-or-beginning)
  (kill-region (point) (progn (end-of-code-or-line) (point)))
  )

(defun my-kill-region-or-line ()
  (interactive)
  (if mark-active
      (progn (kill-region (min (mark) (point)) (max (mark) (point)))
             (setq deactivate-mark t))
    ;; delete line with new line
    (progn (my-kill-line)
           (end-of-line)
           (delete-region (point) (progn (beginning-of-line) (point)))
           (delete-char 1)
           )))

(defun my-delete-line ()
  (interactive)
  (end-of-line)
  (if (= (length (thing-at-point 'line)) 1) ;; line empty (contains only EOL)
      (delete-char 1))
  (delete-region (point) (progn (beginning-of-line) (point))))

(defun my-delete-line-or-region ()
  (interactive)
  (if mark-active
      (progn (delete-region (min (mark) (point)) (max (mark) (point)))
             (setq deactivate-mark t))
    (my-delete-line)))

(defun timestamp ()
  (interactive)
  (insert (format-time-string "%y%m%d%a")))

(defun my-insert-pointer()
  (interactive)
  (insert "->"))

(defun my-insert-array-pointer()
  (interactive)
  (insert "=>")
  )

(defun my-hline()
  (interactive)
  (insert-char ?- 77))

(defun my-python-insert-doc-string()
  (interactive)
  (insert "''''''")
  (backward-char 3))

(defun my-html-enter()
  (interactive)
  (newline)
  (indent-relative-maybe)
  )

(defun my-css-insert-background-color()
  (interactive)
  (insert "background-color: "))

(defun my-css-insert-color()
  (interactive)
  (insert "color: "))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;                                             GLOBAL KEY BINDINGS
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(global-set-key (kbd "C--") 'undo)
(global-set-key (kbd "<f8>") 'toggle-truncate-lines)

(global-set-key "\M-;" 'my-comment-dwim-line)

(define-key my-keys-minor-mode-map [M-up] 'move-text-up)
(define-key my-keys-minor-mode-map [M-down] 'move-text-down)
(global-set-key (kbd "RET") 'my-hard-newline-and-indent-relative-maybe)
(global-set-key (kbd "C-j") 'my-eol-newline)
(global-set-key (kbd "M-j") 'my-newline-and-indent-relative-maybe)

(define-key text-mode-map (kbd "TAB") 'my-indent-region)
(define-key my-keys-minor-mode-map (kbd "<backtab>") 'my-unindent-region)
(define-key my-keys-minor-mode-map (kbd "M-.") 'my-indent-region-or-line)
(define-key my-keys-minor-mode-map (kbd "M-,") 'my-unindent-region)

(define-key my-keys-minor-mode-map (kbd "C-d") 'my-delete-line-or-region)
(define-key my-keys-minor-mode-map (kbd "<M-delete>") 'kill-word)
(define-key my-keys-minor-mode-map (kbd "M-DEL") 'my-backward-delete-word)
(define-key my-keys-minor-mode-map (kbd "<C-delete>") 'my-forward-delete-word)
(define-key my-keys-minor-mode-map (kbd "M-d") 'my-forward-delete-word)
(define-key my-keys-minor-mode-map (kbd "M-w") 'my-copy-region-or-line)
(define-key my-keys-minor-mode-map (kbd "C-w") 'my-kill-region-or-line)
(define-key my-keys-minor-mode-map (kbd "C-v") 'forward-paragraph)
(define-key my-keys-minor-mode-map (kbd "M-v") 'backward-paragraph)
(define-key my-keys-minor-mode-map (kbd "C-k") 'delete-char)
(define-key my-keys-minor-mode-map (kbd "M-k") 'my-kill-eol) ;; kill-visual-line)
(define-key my-keys-minor-mode-map (kbd "C-u") 'my-kill-backwards)
(define-key my-keys-minor-mode-map (kbd "M-\\") 'comment-dwim)

;;
;; NAVIGATION
;;

;; open recent files
(global-set-key (kbd "C-x f") 'recentf-open-files)
(setq recentf-max-saved-items 111)

;; switching buffers
(global-set-key (kbd "<f12>") 'jump-to-register)
(global-set-key (kbd "<f9>") 'my-set-register)

(global-set-key (kbd "<home>") 'back-to-indentation-or-beginning)
(global-set-key (kbd "<end>") 'end-of-code-or-line)
(global-set-key (kbd "C-a") 'back-to-indentation-or-beginning)
(global-set-key (kbd "C-e") 'end-of-code-or-line)
;(define-key my-keys-minor-mode-map (kbd "C-p") 'previous-line) ; Default
;(define-key my-keys-minor-mode-map (kbd "C-n") 'next-line) ; Default
;(define-key my-keys-minor-mode-map (kbd "M-f") 'forward-word) ; Default
;(define-key my-keys-minor-mode-map (kbd "M-b") 'backward-word) ; Default
(define-key my-keys-minor-mode-map (kbd "M-a") 'backward-paragraph)
(define-key my-keys-minor-mode-map (kbd "M-e") 'forward-paragraph)

(global-set-key (kbd "C-c q") 'auto-fill-mode)
(global-set-key (kbd "C-c d") 'duplicate-current-line-or-region)
(global-set-key "\C-x\C-b" 'buffer-menu) ;; instead of 'ibuffer
(global-set-key (kbd "C-;") 'buffer-menu) ;; instead of 'ibuffer
;; (autoload 'ibuffer "ibuffer" "list buffers" t)
(global-set-key (kbd "M-i") 'universal-argument)
(global-set-key (kbd "M-/") 'dabbrev-expand)
(global-set-key (kbd "C-t") 'timestamp)

; DECOR
(global-set-key (kbd "C-h C-l") 'my-hline)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;                                       modding standard commands
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(global-set-key (kbd "C-<left>") 'previous-buffer)
(global-set-key (kbd "C-<right>") 'next-buffer)
(global-set-key (kbd "C-x k") 'my-kill-buffer)
(global-set-key (kbd "C-x s") 'my-save-all-no-question)

;; (defadvice autopair-newline ;my-hard-newline-and-indent-relative-maybe
;;   (after newline-clear-screen last ())
;;   "asdfasdf jalskdjf s"
;;   (redraw-display)
;;   )
;; (ad-activate 'autopair-newline);my-hard-newline-and-indent-relative-maybe)

;; save file on buffer switch
(defadvice switch-to-buffer (before save-buffer-now activate)
  (when buffer-file-name (progn (basic-save-buffer) (message nil))))

;; save on kill
(defadvice my-kill-buffer
  (before save-buffer-on-kill ())
  "asdfasdf jalskdjf s"
  (basic-save-buffer)
  )
(ad-activate 'my-kill-buffer)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;                                                    CUSTOM MODES
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'generic-x)

(define-generic-mode 'xm-mode
  '("#") ;; Comments. Not sure .xm scripts have comments. Putting this
         ;; here just for define-generic-mode syntax, just to be safe.
  '("MotionNotify"
    "ButtonPress" "ButtonRelease"
    "KeyStrPress" "KeyStrRelease"
    "Delay") ;; keywords
  '() ;; some syntax defs, none in .xm
  '("\\.xm$") ;; file extension
  nil
  )
(add-hook
 'xm-mode-hook
 (function
  (lambda()
    (local-set-key (kbd "C-c C-d") 'xm-insert-delay)
    (local-set-key (kbd "C-c C-k") 'xm-insert-key)
    )))

;; Use this function to replace a builtin generic mode you don't like,
;; e.g. javascript-generic-mode, with one you do like.

(defun replace-alist-mode (alist oldmode newmode)
  (if (eq (cdr (car alist)) oldmode)
      (setcdr (car alist) newmode))
  (if (not (eq (cdr alist) nil))
      (replace-alist-mode (cdr alist) oldmode newmode)))

;; Remove dumb javascript-generic mode
(replace-alist-mode auto-mode-alist 'javascript-generic-mode 'js-mode)
(add-hook
 'js-mode-hook
 (function
  (lambda()
    (local-set-key (kbd "M-j") 'my-c++-braces-newline)
    (local-set-key (kbd "C-c C-w") 'my-js-async-waterfall)
    (local-set-key (kbd "C-c C-d") 'my-js-new-function)
    (local-set-key (kbd "C-c C-s") 'my-js-new-function-done)
    (local-set-key (kbd "C-c C-l") 'my-js-console-log)
    (local-set-key (kbd "C-c C-j") 'my-js-insert-json-stringify)
    )))

;; Bug fix for greasemonkey meta block confusing js-mode highlighting
(eval-after-load 'js
  '(progn
     (setq js--regexp-literal-fix  "[^=][=(,:]\\(?:\\s-\\|\n\\)*\\(/\\)\\(?:\\\\.\\|[^/*\\]\\)\\(?:\\\\.\\|[^/\\]\\)*\\(/\\)")
     (setq js-font-lock-syntactic-keywords-fix
           ;; "|" means generic string fence
           `((,js--regexp-literal-fix (1 "|") (2 "|"))))
     (setq js-font-lock-syntactic-keywords js-font-lock-syntactic-keywords-fix)))

;; Personal dictionary for ispell-checking
(setq ispell-personal-dictionary (expand-file-name "~/.emacs.d/.ispell.dict"))

;; ;; really auto-save, not emacs default auto-save
;; (setq auto-save-default nil)
;; (require 'real-auto-save)
;; (add-hook 'find-file-hooks 'turn-on-real-auto-save)
;; (setq real-auto-save-interval 300) ;; in seconds

;; copy to clipboard
(setq x-select-enable-clipboard t)

;; EMACS CUSTOMIZATION
(load-theme 'deeper-blue)
(tool-bar-mode -1) ;; no tool bar at top in emacs window
(cond
 ((member "Inconsolata" (font-family-list))
  (set-face-attribute 'default nil :family "Inconsolata" :height 160 :weight 'bold))
 ((member "Consolas" (font-family-list))
  (set-face-attribute 'default nil :font "Consolas" :height 200 :weight 'light))
 ((member "Courier New" (font-family-list))
  (set-face-attribute 'default nil :font "Courier New" :height 200 :weight 'light))
 ((member "Arial" (font-family-list))
  (set-face-attribute 'default nil :font "Arial" :height 220))
 ((member "Times New Roman" (font-family-list))
  (set-face-attribute 'default nil :font "Times New Roman" :height 220))
 ((member "Courier" (font-family-list))
  (set-face-attribute 'default nil :font "Courier" :height 180 :weight 'light))
 ((member "CMU Typewriter Text" (font-family-list))
  (set-face-attribute 'default nil :font "CMU Typewriter Text" :height 200))
 (set-face-attribute 'default nil :height 200))

;; for working on windows emacs, which messes up line endings
;; (set-default buffer-file-coding-system 'utf-8-unix)
(set-default-coding-systems 'utf-8-unix)
(prefer-coding-system 'utf-8-unix)
(set-default default-buffer-file-coding-system 'utf-8-unix)

(setq visible-bell 1)
