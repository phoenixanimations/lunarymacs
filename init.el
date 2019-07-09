;;; -*- lexical-binding: t -*-

;;; Init

(setq-default lexical-binding t)

(add-to-list 'load-path (expand-file-name "site-lisp" user-emacs-directory))
(setq package-user-dir (expand-file-name "package" user-emacs-directory))
(require 'lunary)
(require 'cowboy)

;;;; Loadpath

(cowboy-add-load-path)

;;;; Startup setting

(add-hook 'after-init-hook
          ;; make it closure
          (let ()
            (lambda ()
              (setq file-name-handler-alist file-name-handler-alist
                    gc-cons-threshold 800000
                    gc-cons-percentage 0.1)
              (garbage-collect))) t)

(setq package-enable-at-startup nil
      file-name-handler-alist nil
      message-log-max 16384
      gc-cons-threshold 402653184
      gc-cons-percentage 0.6
      auto-window-vscroll nil)

;;; Package

(setq luna-lsp 'eglot)

(add-to-list 'luna-package-list 'use-package)

(ignore-errors (require 'use-package))
(luna-load-relative "star/other.el")
(luna-load-relative "star/key.el")
(luna-load-relative "star/recipe.el")
(luna-load-relative "star/core-edit.el")
(luna-load-relative "star/core-ui.el")
(luna-load-relative "star/angel.el")
(luna-load-relative "star/ui.el")
(luna-load-relative "star/edit.el")
(luna-load-relative "star/homepage.el")
(luna-load-relative "star/helm.el")
(luna-load-relative "star/checker.el")
(luna-load-relative "star/company.el")
(luna-load-relative "star/eglot.el")
(luna-load-relative "star/python.el")
(luna-load-relative "star/elisp.el")
(luna-load-relative "star/git.el")
(luna-load-relative "star/dir.el")
(luna-load-relative "star/org.el")
(luna-load-relative "star/tex.el")
(luna-load-relative "star/shell.el")
(luna-load-relative "star/simple-mode.el")


;;; Customize

;;;; Custom

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(luna-load-or-create custom-file)
(add-hook 'kill-emacs-hook #'customize-save-customized)

;;;; theme
(setq doom-cyberpunk-dark-mode-line nil)
(luna-load-theme nil t)

;;;; Faster long lines
(setq-default bidi-display-reordering nil)

;;;; format on save
(setq luna-format-on-save t)

;;;; scroll margin
(setq scroll-margin 4)

 ;;;; Font
(luna-load-font)
(luna-load-cjk-font)

;;;;; Chinese

;; WenYue GuDianMingChaoTi (Non-Commercial Use) W5
;; WenYue XHGuYaSong (Non-Commercial Use)
;; WenyueType GutiFangsong (Non-Commercial Use)
;; SiaoyiWangMingBold
;; FZQingKeBenYueSongS-R-GB
;; FZSongKeBenXiuKaiS-R-GB

;; | 对齐 |
;; | good |

(when luna-font
  (add-to-list 'face-font-rescale-alist
               (cons (plist-get (alist-get (intern luna-cjk-font)
                                           luna-cjk-font-alist)
                                :family)
                     1.3)))

 ;;;;; Emoji
;; (set-fontset-font t 'symbol (font-spec :family "Apple Color Emoji")
;;                   nil 'prepend)

 ;;;; nyan
;; (nyan-lite-mode)
;; (setq nyan-wavy-trail t)
;; enabling this makes highlight on buttons blink
;; (nyan-start-animation)

;;;; winner
(run-with-idle-timer 2 nil (lambda () (winner-mode)))

;;;; Max
(toggle-frame-maximized)
