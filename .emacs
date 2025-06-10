;;; Core Package System Setup
(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
(package-initialize)

;;; Visual Settings
;; Theme and Font
(setq inhibit-startup-screen t)
(set-frame-font "JetBrains Mono 16" nil t)
(load-theme 'timu-caribbean t)

;; UI Cleanup
(tool-bar-mode -1)    
(scroll-bar-mode -1)  
(menu-bar-mode -1)
(menu-bar-mode -1)

;; Line Numbers and Margins
(global-display-line-numbers-mode 1)
(setq-default display-line-numbers-width 2
              display-line-numbers-width-start t
              display-line-numbers-spacing 1
              left-margin-width 1)
(set-window-buffer nil (current-buffer))
;; (set-face-attribute 'line-number nil :foreground "#E0E0E0")

(global-set-key (kbd "C-c n n") 'global-display-line-numbers-mode)

(require 'highlight-indent-guides)

;; Enable for programming modes
(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)

;; Choose your preferred style ('character, 'column, 'bitmap)
(setq highlight-indent-guides-method 'bitmap)

;; Frame Settings
(add-to-list 'frameset-filter-alist '(ns-transparent-titlebar . t))
(add-to-list 'frameset-filter-alist '(ns-appearance . dark))
(add-to-list 'default-frame-alist '(width . 144)) 
(add-to-list 'default-frame-alist '(height . 44))

;;; Editor Behavior
(setq-default indent-tabs-mode nil
              tab-width 4)
(electric-pair-mode 1)
(recentf-mode 1)

;;; Terminal Configuration
(use-package vterm
    :ensure t
    :config
    (setq vterm-max-scrollback 10000
          vterm-buffer-name-string "vterm: %s"
          vterm-timer-delay 0.01
          vterm-shell "/bin/zsh")
    :hook (vterm-mode . (lambda ()
                         (hl-line-mode -1)
                         (display-line-numbers-mode -1)))
    :bind (("C-c v" . vterm)
           :map vterm-mode-map
           ("C-y" . vterm-yank)))

;;; Code Formatting
(defun format-code ()
  "Format the current buffer based on major mode using appropriate formatter."
  (when (buffer-file-name)
    (let ((current-point (point))
          (formatter-command
           (pcase major-mode
             ('c-mode "clang-format -style=file")
             ('rust-mode "rustfmt")
             (_ nil)))
          (tmpfile (make-temp-file "fmt")))
      (when formatter-command
        (write-region (point-min) (point-max) tmpfile)
        (if (zerop (shell-command (concat formatter-command " " tmpfile)))
            (progn
              (insert-file-contents tmpfile nil nil nil t)
              (goto-char current-point))
          (message "Formatting failed"))
        (delete-file tmpfile)))))


(add-hook 'before-save-hook
          (lambda ()
            (when (member major-mode '(c-mode rust-mode))
              (format-code))))

;;; Navigation and Search
(require 'avy)
(global-set-key (kbd "C-;") 'avy-goto-char-timer)    
(global-set-key (kbd "C-'") 'avy-goto-word-1)  

;; ;; spellche
;; (dolist (hook '(text-mode-hook))
;;   (add-hook hook (lambda () (flyspell-mode 1))))

;; ;; Enable Flyspell for comments and strings in prog modes
;; (dolist (hook '(rust-mode-hook c-mode-hook))
;;   (add-hook hook (lambda () (flyspell-prog-mode))))

;; Key binding for manual spell check
(global-set-key (kbd "C-c s") 'flyspell-correct-word-before-point)

;;; Version Control
(require 'magit)
(global-set-key (kbd "C-x g") 'magit-status)

;;; Completion Framework
(require 'ivy)
(ivy-mode 1)
(setq ivy-use-virtual-buffers t
      enable-recursive-minibuffers t
      search-default-mode #'char-fold-to-regexp
      ivy-display-style 'fancy)
(global-set-key "\C-s" 'swiper)

(require 'counsel)
(counsel-mode 1)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)

;;; Auto-completion
(require 'company)
(add-hook 'after-init-hook 'global-company-mode)
(setq company-idle-delay 0.2
      company-minimum-prefix-length 1)
(define-key company-active-map (kbd "<tab>") 'company-complete)
(define-key company-active-map (kbd "<return>") 'company-complete)

;;; Language Support

;; Rust
(require 'rust-mode)
(require 'eglot)
(add-to-list 'eglot-server-programs
             '((rust-ts-mode rust-mode) .
               ("rust-analyzer" :initializationOptions (:check (:command "clippy")))))
(add-hook 'rust-mode-hook 'eglot-ensure)
(setq eglot-autoshutdown t
      eglot-confirm-server-initiated-edits nil)

;; ORG MODE

(use-package org-roam
  :ensure t
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory (file-truename "~/notes"))
  :bind
  (("C-c n l" . org-roam-buffer-toggle)
   ("C-c n f" . org-roam-node-find)
   ("C-c n i" . org-roam-node-insert))
  :config
  (org-roam-db-autosync-mode))

(require 'org)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-level-1 ((t (:inherit outline-1 :height 1.2))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.1)))))

(setq org-startup-indented t)           ;; Enable org-indent-mode by default
(setq org-indent-mode-turns-on-hiding-stars t)  ;; Hide leading stars
(setq org-indent-indentation-per-level 2)   

(setq org-preview-latex-default-process 'dvisvgm) ;; Use dvisvgm for better quality
(setq org-format-latex-options 
      (plist-put org-format-latex-options :scale 1.5)) ;; Adjust size of preview

;; Ensure preview works with org-mode
(org-babel-do-load-languages
 'org-babel-load-languages
 '((latex . t)))

(global-set-key (kbd "C-c l") 'org-latex-preview)
(global-set-key (kbd "C-c C-l") 'org-toggle-latex-fragment)


;; Emmet

(require 'emmet-mode)
(add-hook 'sgml-mode-hook 'emmet-mode) ;; Auto-start on any markup modes
(add-hook 'css-mode-hook  'emmet-mode) ;; Enable in CSS
(add-hook 'web-mode-hook  'emmet-mode) ;; Enable in web-mode

;; Yaml
(require 'yaml-pro)
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-pro-mode))
(add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-pro-mode))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("3e628415ed602e64d401c39800c6c0deb60a8d9e47176b10691724885a4fed5e" "18a1d83b4e16993189749494d75e6adb0e15452c80c431aca4a867bcc8890ca9" default))
 '(package-selected-packages
   '(yaml-pro emmet-mode org-roam highlight-indent-guides purp-theme nordless-theme lavenderless-theme solarized-theme vterm timu-caribbean-theme rust-mode magit lsp-mode inkpot-theme highlight-parentheses highlight-operators highlight-numbers highlight-function-calls gruvbox-theme eglot ef-themes counsel company avy)))

