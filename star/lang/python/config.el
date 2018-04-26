;;; -*- lexical-binding: t -*-


;;
;; Config
;;

(use-package| lsp-python
  :init
  (add-hook 'python-mode-hook #'lsp-python-enable)
  (add-hook 'python-mode-hook #'setup-lsp))


(use-package| pyvenv
  :commands pyvenv-activate
  )

(use-package| quickrun
  :commands (quickrun
             quickrun-region
             quickrun-with-arg
             quickrun-shell
             quickrun-compile-only
             quickrun-replace-region
             quickrun-autorun-mode
             )
  ;; from evil-collection
  :config (when (featurep 'evil)
            (evil-define-key 'normal quickrun--mode-map
              "q" 'quit-window)))

(use-package| ein
  :commands (ein:notebooklist-open
             ein:notebooklist-new-notebook
             ein:notebooklist-open-notebook-global
             ein:notebooklist-login
             ein:junk-new)
  :config
  (setq ein:worksheet-enable-undo 'yes)
  (load (concat
         moon-emacs-d-dir
         "star/lang/python/jpnb-state/jpnb-state.el")))

(post-config| general
  (after-load| ein
    (default-leader
      :keymaps '(ein:notebook-mode-map
                 ein:notebook-multilang-mode-map
                 ein:notebook-python-mode-map
                 ein:notebook-plain-mode-map
                 )
      "jj" #'evil-jpnb-state
      ))
  )
