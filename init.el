;; install straight
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t)


(use-package general
  :config
  (general-create-definer spc
    :states '(normal visual insert emacs motion)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "M-SPC")
  
  (general-create-definer spc-m
    :states '(normal visual insert emacs motion)
    :keymaps 'override
    :prefix "SPC m"
    :global-prefix "M-,")

  (spc
    ""    '(nil :wk "leader")
    "a"   '(:ignore t :wk)
    "b"   '(:ignore t :wk "buffer")
    "c"   '(:ignore t :wk "config")
    "d"   '(:ignore t :wk)
    "e"   '(:ignore t :wk)
    "f"   '(:ignore t :wk "file")
    "g"   '(:ignore t :wk)
    ;"h"  used
    "i"   '(:ignore t :wk )
    ;"j"  used
    ;"k"  used
    ;"l"  used
    "m"   '(:ignore t :wk)
    "n"   '(:ignore t :wk)
    "o"   '(:ignore t :wk)
    "p"   '(:ignore t :wk)
    "q"   '(:ignore t :wk)
    "r"   '(:ignore t :wk)
    "s"   '(:ignore t :wk)
    "t"   '(:ignore t :wk)
    ;"u"  used
    "v"   '(:ignore t :wk)
    "w"   '(:ignore t :wk)
    "x"   '(:ignore t :wk)
    "y"   '(:ignore t :wk)
    "z"   '(:ignore t :wk)
    )

  (spc-m
    ""    '(nil :wk "local leader")))


(use-package evil
  :init
  (setq evil-want-C-u-scroll t)
  (setq evil-want-keybinding nil) ; for evil-collection
  (setq evil-want-integration t)


  :config
  (evil-mode 1)

  :general
  (spc
    :no-autoload t
    "k" '(evil-window-up :wk)
    "j" '(evil-window-down :wk)
    "h" '(evil-window-left :wk)
    "l" '(evil-window-right :wk)
    "wk" '(evil-window-up :wk)
    "wj" '(evil-window-down :wk)
    "wh" '(evil-window-left :wk)
    "wl" '(evil-window-right :wk)
    "bp" '(evil-prev-buffer :wk)
    "bn" '(evil-next-buffer :wk)))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package magit
  :config
  ; hack - see https://github.com/emacs-evil/evil-collection/issues/637
  ; fixes (overrides) incorrect evil keys in magit help
  ; remove this if fixed
  (transient-suffix-put 'magit-dispatch "O" :key "\"")
  (transient-suffix-put 'magit-dispatch "X" :key "O")
  (transient-suffix-put 'magit-dispatch "k" :key "x"))

;; vertico and vertico-related
;; completions in minibuffer
(use-package vertico
  :init
  (vertico-mode))

(use-package savehist
  :init
  (savehist-mode))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless basic)
	completion-category-defaults nil
	completion-category-overrides '((file (styles partial-completion)))))

(use-package emacs
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; Display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
		  (replace-regexp-in-string
		   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
		   crm-separator)
		  (car args))
	  (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
	'(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t)

  :preface
  (defun switch-to-scratch () (interactive) (switch-to-buffer "*scratch*"))
  (defun find-init-el () (interactive) (find-file (concat user-emacs-directory "init.el")))

  :general
  (spc
    "bs" '(switch-to-scratch :wk)
    "bd" '(kill-this-buffer :wk)
    "fc" '(find-init-el :wk)
    "cf" '(find-init-el :wk)
    "fs" '(save-buffer :wk)
    "ff" '(find-file :wk)
    "u" '(universal-argument :wk)
    "wd" '(delete-window)))

(use-package eshell
  :preface
  (defalias 'eshell/f 'find-file)
  
  :config
  ;;(add-hook 'eshell-post-command-hook 'post-test)
  :general
  (spc
    :no-autoload t
    "e" '(eshell :wk)))

;; Enable richer annotations using the Marginalia package
(use-package marginalia
  :init
  (marginalia-mode))

(use-package consult
  :general
  (spc
    "bb" '(consult-buffer :wk "switch to buffer")
    "wb" '(consult-buffer-other-window :wk "open buffer in other window")))

(use-package lsp-mode
  :init
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
	 (rust-mode . lsp)
	 ;; if you want which-key integration
	 (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

(use-package envrc
  :init
  (envrc-global-mode))

(use-package rust-mode)

(use-package which-key
  :config
  (which-key-mode))

(use-package dracula-theme
  :config
  (load-theme 'dracula t))

(progn
  (menu-bar-mode -1)
  (scroll-bar-mode -1)
  (tool-bar-mode -1))

(setq inhibit-splash-screen t
      initial-buffer-choice #'eshell
      eshell-banner-message "")

(use-package eshell-up
  :config
  (defun eshell/.. (&optional arg) (eshell-up arg)))


