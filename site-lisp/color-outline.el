;;; color-outline.el --- Outline w/ color      -*- lexical-binding: t; -*-

;; Author: Yuan Fu <casouri@gmail.com>

;; This file is NOT part of GNU Emacs

;;; Commentary:
;;
;; This package provides a basic version of outshine.el, providing:
;; 
;;   1) Highlight each header level
;;   2) outline folding
;;
;; Usage: M-x color-outline-mode RET
;;
;; Header level is determined by the number of comment characters.
;; The first level header starts from 3 comment characters.
;; For example, in ‘emacs-lisp-mode’:
;;
;;     ;;; Header 1
;;     ;;;; Header 2
;;     ;;;;; Header 3
;;
;; In ‘python-mode’:
;;
;;     ### Header 1
;;     #### Header 2
;;     ##### Header 3
;;
;; To toggle each header, use outline commands.
;;
;; Add support for new major modes by
;;
;;     (color-outline-define-header MODE COMMENT-CHAR COMMENT-BEGIN)
;;
;; COMMENT-CHAR for ‘python-mode’ is “#”, for example. It can be more
;; than one character. COMMENT-BEGIN is the (possibly empty) beginning
;; of the header. For example, in OCaml, comments are (* ... *). Then
;; COMMENT-BEGIN is “(” and COMMENT-CHAR is “*”.
;;
;; You can also just edit ‘color-outline-comment-char-alist’.

;;; Code:
;;

(require 'cl-lib)
(require 'subr-x)

(defvar color-outline-comment-char-alist '((c-mode "/")
                                           (python-mode "#")
                                           (javascript-mode "/")
                                           (css-mode "/")
                                           (tuareg-mode "*" "(")
                                           (shell-script-mode "#")
                                           (sh-mode "#"))
  "Stores custom comment character each major mode.
For some major modes ‘comment-start’ is enough.")

(defvar color-outline-face-list '(outline-1 outline-2 outline-3 outline-4)
  "Face for each level.")

(defvar-local color-outline--keywords nil
  "We store font-lock keywords in this variable.
This is used to remove font-lock rules when ‘color-outline-mode’
is turned off.")

(defvar-local color-outline--imenu-expression nil
  "We store imenu expressions in this variable.
This is used to remove imenu expressions when ‘color-outline-mode’
is turned off.")

(defun color-outline--create-pattern (comment-char comment-begin)
  "Return the header pattern for major mode MODE.
COMMENT-CHAR (string) is the comment character of this mode.
COMMENT-BEGIN is string pattern starting a comment.
The result pattern is

<COMMENT-START><COMMENT-CHAR>{3}<COMMENT-CHAR>*<SPACE><ANYCHAR>*

The first group is the second group of COMMENT-CHARS, the second
group is <ANYCHAR>*.

Return a plist

    (:outline PATTERN :font-lock PATTERN-LIST :imenu PATTERN)

where PATTERN is suitable for `outline-regepx', PATTERN-LIST is suitable
for `font-lock-add-keywords' (a list of specs)."
  (let* ((header-level (length color-outline-face-list))
         (outline-re (rx-to-string `(seq ,comment-begin
                                         (= 3 ,comment-char)
                                         (group (* ,comment-char))
                                         " "
                                         (group (* (not (any ?\t ?\n)))))))
         (re-list (cl-loop
                   for level from 0 to (1- header-level)
                   collect
                   (rx-to-string `(seq bol
                                       ,comment-begin
                                       (= 3 ,comment-char)
                                       (= ,level ,comment-char)
                                       " "
                                       (* (not (any ?\t ?\n)))))))
         (font-lock-list (cl-loop for re in re-list
                                  for face in color-outline-face-list
                                  collect `(,re (0 ',face t t)))))
    (list :outline outline-re :font-lock font-lock-list)))

(defun color-outline-define-header (mode comment-char comment-begin)
  "Define the header pattern for major mode MODE.
COMMENT-CHAR (char) is the comment character of this mode.
COMMENT-BEGIN is string pattern starting a comment."
  (setf (alist-get mode color-outline-comment-char-alist)
        (color-outline--create-pattern comment-char comment-begin)))

(defun color-outline-mode-maybe ()
  "Enable `color-outline-mode' but not in Org Mode."
  (interactive)
  (unless (derived-mode-p 'org-mode)
    (color-outline-mode)))

(define-minor-mode color-outline-mode
  "Color outline."
  :lighter ""
  (if color-outline-mode
      (if-let* ((rule (or (alist-get major-mode
                                     color-outline-comment-char-alist)
                          (list comment-start "")))
                (comment-char (or (car rule) comment-start))
                (comment-begin (or (cadr rule) ""))
                (config (color-outline--create-pattern
                         comment-char comment-begin))
                (outline-re (plist-get config :outline))
                (imenu-expression `("Section" ,outline-re 2))
                (font-lock-keyword-list (plist-get config :font-lock)))
          (progn (setq-local outline-regexp outline-re)
                 (setq-local outline-level
                             (lambda () (1+ (/ (length (match-string 1))
                                               (length comment-char)))))
                 (setq-local imenu-generic-expression
                             (cons imenu-expression
                                   imenu-generic-expression))
                 (font-lock-add-keywords nil font-lock-keyword-list)
                 (setq color-outline--keywords font-lock-keyword-list)
                 (setq color-outline--imenu-expression imenu-expression)
                 (outline-minor-mode))
        (user-error "No color-outline pattern configured for %s"
                    major-mode))
    (kill-local-variable 'outline-regexp)
    (kill-local-variable 'outline-level)
    (font-lock-remove-keywords nil color-outline--keywords)
    (setq-local imenu-generic-expression
                (remove color-outline--imenu-expression
                        imenu-generic-expression))
    (outline-minor-mode -1))
  (jit-lock-refontify))

(provide 'color-outline)

;;; color-outline.el ends here

