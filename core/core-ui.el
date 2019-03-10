;; -*- lexical-binding: t -*-

;;
;;; Homepage
;;

(setq inhibit-startup-screen t)
(setq initial-buffer-choice (lambda () (get-buffer-create moon-homepage-buffer)))

(defvar moon-homepage-buffer "HOME"
  "The buffer name of the homepage")

;;
;;; Theme
;;

(defvar moon-load-theme-hook ()
  "Hook ran after `load-theme'")

(defvar moon-current-theme nil
  "The last loaded theme (symbol) in string.")

(defvar moon-toggle-theme-list ()
  "Themes that you can toggle bwtween by `moon/switch-theme'")

(defvar moon-theme-book '(spacemacs-dark spacemacs-light)
  "A list of themes that you can load with `moon/load-theme'.")

(defcustom moon-theme nil
  "The theme used on startup.
This way luanrymacs remembers the theme.
You need to load `moon-theme' somewhere (after loading custom.el)."
  :type 'symbol
  :group 'convenience)

(defcustom moon-font nil
  "Like `moon-theme', used to cache configuration across sessions."
  :type 'string
  :group 'convenience)

(defcustom moon-cjk-font nil
  "Like `moon-font'."
  :type 'string
  :group 'convenience)

(defun moon-set-current-theme (theme &rest _)
  "Adveiced before `load-theme', set `moon-current-theme' to THEME."
  (setq moon-current-theme theme))

(defun moon-run-load-theme-hook (&rest _)
  "Run `moon-load-theme-hook'."
  (run-hook-with-args 'moon-load-theme-hook))

(advice-add #'load-theme :after #'moon-run-load-theme-hook)

(advice-add #'load-theme :before #'moon-set-current-theme)

(defun moon-load-theme (&optional theme no-confirm no-enable)
  "Disable `moon-currnt-theme' and oad THEME.
Set `moon-theme' to THEME."
  (disable-theme moon-current-theme)
  (load-theme (or theme (car moon-toggle-theme-list)) no-confirm no-enable)
  (when theme
    (customize-set-variable 'moon-theme theme)
    (custom-save-all)))

(defun moon/load-font (&optional font-name)
  "Prompt for a font and set it.
Fonts are specified in `moon-font-alist'."
  (interactive (list
                (completing-read "Choose a font: "
                                 (mapcar (lambda (cons) (symbol-name (car cons)))
                                         moon-font-alist))))

  (let* ((arg font-name)
         (font-name (or font-name moon-font))
         (font (apply #'font-spec
                      (if font-name (alist-get (intern font-name)
                                               moon-font-alist)
                        (cdar moon-font-alist)))))
    (set-frame-font font nil t)
    ;; seems that there isn't a good way to get font-object directly
    (add-to-list 'default-frame-alist `(font . ,(face-attribute 'default :font)))
    (when arg (customize-set-variable 'moon-font font-name))
    ;; sync cjk font settings
    (moon/load-cjk-font)))

(defun moon/load-cjk-font (&optional font-name)
  "Prompt for a font and set it.
Fonts are specified in `moon-font-alist'."
  (interactive (list
                (completing-read "Choose a font: "
                                 (mapcar (lambda (cons) (symbol-name (car cons)))
                                         moon-cjk-font-alist))))
  (let* ((arg font-name)
         (font-name (or font-name moon-cjk-font))
         (spec (apply #'font-spec (if font-name
                                      (alist-get (intern font-name)
                                                 moon-cjk-font-alist)
                                    (cdar moon-cjk-font-alist)))))
    (dolist (charset '(kana han cjk-misc))
      (set-fontset-font (frame-parameter nil 'font)
                        charset spec))
    (when arg
      (customize-set-variable 'moon-cjk-font font-name)
      (custom-save-all))))


;;
;;; Font
;;

(defvar moon-font-alist
  '((sf-mono-13 . (:family "SF Mono" :size 13)))
  "An alist of all the fonts you can switch between by `moon/load-font'.
Key is a symbol as the name, value is a plist specifying the font spec.
More info about spec in `font-spec'.")

(defvar moon-cjk-font-alist
  '((soure-han-serif-13 . (:family "Source Han Serif SC"
                                   :size 13)))
  "Similar to `moon-font-alist' but used for CJK scripts.
Use `moon/load-cjk-font' to load them.")


;;
;;; Rmove GUI elements
;;

(when window-system
  (tool-bar-mode -1)
  (scroll-bar-mode -1))
(unless (eq window-system 'ns)
  (menu-bar-mode -1))

;;
;;; Color
;;

(defvar moon-color-book
  '(doom-blue spacemacs-yellow lunary-white
              lunary-dark-pink lunary-pink
              lunary-dark-yellow lunary-yellow
              spacemacs-gray spacemacs-green
              spacemacs-light-purple
              spacemacs-dark-purple
              powerline-blue poweline-green
              poweline-yellow mac-red mac-green
              mac-yellow
              )
  "All prededined colors.")

(defvar doom-blue "#56B0EC"
  "Blue color of doom-emacs.")

(defvar doom-purple "#D86FD9"
  "Blue color of doom-emacs.")

(defvar spacemacs-yellow "DarkGoldenrod2"
  "Yellow color of spacemacs.")

(defvar spacemacs-light-purple "plum3"
  "A light purple used in spacemacs.")

(defvar spacemacs-dark-purple "#5D4E79"
  "Spacemacs purple.")

(defvar spacemacs-gray "#3E3D31"
  "A dark gray.")

(defvar spacemacs-green "chartreuse3"
  "A bright green.")

(defvar lunary-white "#DEDDE3"
  "White color of moon.")

(defvar lunary-light-purple "#61526E"
  "Light purple color of moon.

Can be uesed for hightlight region.")

(defvar lunary-dark-yellow "#F3B700"
  "Dark yellow color of moon.")

(defvar lunary-yellow "#FFD256"
  "Yellow color of moon.")

(defvar lunary-pink "#E8739F"
  "Pink(?) color of moon.")

(defvar lunary-dark-pink "#E83077"
  "Dark pink(?) color of moon.")

(defvar powerline-blue "#289BEC"
  "Bright blue.")

(defvar powerline-green "#AAC306"
  "Bright green.")

(defvar powerline-yellow "#DCA809"
  "Brigh yellow/orange.")

(defvar mac-red "#FA5754"
  "Red color on mac titlebar.")

(defvar mac-green "#36CF4C"
  "Green color on mac titlebar.")

(defvar mac-yellow "#FEC041"
  "Yellow color on mac titlebar.")

;;
;;; Function
;;

(defun moon-quit-window (arg)
  "Quit current window and bury it's buffer.
Unlike `quit-window', this function deletes the window no matter what.
If run with prefix argument (ARG), kill buffer."
  (interactive "p")
  (if (equal major-mode 'dired-mode)
      (while (equal major-mode 'dired-mode)
        (kill-buffer))
    (if (eq arg 4) ; with C-u
        (kill-buffer)
      (bury-buffer)))
  (ignore-errors (delete-window)))


(provide 'core-ui)

