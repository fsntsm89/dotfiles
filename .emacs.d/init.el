; -*- Mode: Emacs-Lisp ; Coding: utf-8 -*-
; ------------------------------------------------------------------------
;; @ load-path

;; load-pathの追加関数
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
	      (expand-file-name (concat user-emacs-directory path))))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
            (normal-top-level-add-subdirs-to-load-path))))))

;; load-pathに追加するフォルダ
;; 2つ以上フォルダを指定する場合の引数 => (add-to-load-path "elisp" "xxx" "xxx")
(add-to-load-path "elisp")

;; Cask
(require 'cask)
(cask-initialize)

;; ------------------------------------------------------------------------
;; @ general

;; common lisp
(require 'cl)

;; 文字コード
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)

;; フォントをRictyに指定
(add-to-list 'default-frame-alist '(font . "ricty-13.5"))
(custom-set-faces
 '(fixed-pitch ((t (:family "Ricty"))))
 '(variable-pitch ((t (:family "Ricty")))))

;; 行番号表示
(global-linum-mode)
(set-face-attribute 'linum nil
                    :height 0.9)

;; 現在の行をハイライト
(global-hl-line-mode 1)

;; ビープ音・画面フラッシュ無効
(setq ring-bellfunction 'ignore)

;; 括弧の範囲内を強調表示
(show-paren-mode t)
(setq show-paren-delay 0)
(setq show-paren-style 'expression)

;; 括弧の範囲色
(set-face-background 'show-paren-match-face "#002b36")

;; 行末の空白を強調表示
(setq-default show-trailing-whitespace t)
(set-face-background 'trailing-whitespace "#b58900")

;; タブをスペースで扱う
(setq-default indent-tabs-mode nil)

;; タブ幅
(setq default-tab-width 2)

;; yes or noをy or n
(fset 'yes-or-no-p 'y-or-n-p)

;; 自動保存を無効にする
(setq auto-save-default nil)

;; 変更ファイルのバックアップを残さない
(setq make-backup-files nil)

;; 変更ファイルの番号つきバックアップを残さない
(setq version-control nil)

;; 編集中ファイルのバックアップを残さない
(setq auto-save-list-file-name nil)
(setq auto-save-list-file-prefix nil)

;; 最近使ったファイルをメニューに表示
(recentf-mode t)

;; 最近使ったファイルの表示数
(setq recentf-max-menu-items 5)

;; 行間
(setq-default line-spacing 0)

;; ツールバー非表示
(tool-bar-mode -1)

;; フレームの透明度
(set-frame-parameter nil 'alpha '(0.9))

;; モードラインに行番号表示
(line-number-mode t)

;; モードラインに列番号表示
(column-number-mode t)

;; スタートアップ非表示
(setq inhibit-startup-screen t)

;; ファイルのフルパスをタイトルバーに表示
(setq frame-title-format (format "%%f"))

;; 時計表示
(setq display-time-string-forms '((format "%s/%s %s:%s" month day
                                          24-hours minutes)))
(display-time)

;; scratchの初期メッセージ消去
(setq initial-scratch-message "")

;; 行の先頭でC-kを一回押すだけで行全体を消す
(setq kill-whole-line t)

;; 一行が80字以上になったら改行する
(setq fill-column 80)
(setq-default auto-fill-mode t)

;; Homeでバッファの先頭に
(global-set-key (kbd "<home>") 'move-beginning-of-line)

;; Endでバッファの最後に
(global-set-key (kbd "<end>") 'move-end-of-line)

;; アクティブでないウィンドウのカーソルを非表示
(setq cursor-in-non-selected-windows nil)

;; C-wで単語を削除
(defun kill-region-or-backward-kill-word ()
  (interactive)
  (if (region-active-p)
      (kill-region (point) (mark))
    (backward-kill-word 1)))
(global-set-key (kbd "C-w") 'kill-region-or-backward-kill-word)

;; 新しいフレームでも同様に透過
(defun my-set-display-for-windowed-frames (frame)
  "Set display parameters for the current frame the way I like them."
  (select-frame frame)
  (set-frame-parameter nil 'alpha '(0.9)))
(add-hook 'after-make-frame-functions 'my-set-display-for-windowed-frames)
(my-set-display-for-windowed-frames (selected-frame))

;; trampの設定
(require 'tramp)
(setq tramp-default-method "ssh")

;; ------------------------------------------------------------------------
;; @ initial frame maximize

;; 起動時にウィンドウサイズを調整
(setq default-frame-alist
      (append
       '(
         (width . 80)
         (height . 50))
       default-frame-alist))
(setq initial-frame-alist default-frame-alist)

;; ------------------------------------------------------------------------
;; @ sudo
;; 他のユーザーが所有しているファイルをsudoで開き直すか聞く
(defun file-root-p (filename)
  "Return t if file FILENAME created by root."
  (eq 0 (nth 2 (file-attributes filename))))

(defun th-rename-tramp-buffer ()
  (when (file-remote-p (buffer-file-name))
    (rename-buffer
     (format "%s:%s"
             (file-remote-p (buffer-file-name) 'method)
             (buffer-name)))))

(add-hook 'find-file-hook
          'th-rename-tramp-buffer)

(defadvice find-file (around th-find-file activate)
  "Open FILENAME using tramp's sudo method if it's read-only."
  (if (and (file-root-p (ad-get-arg 0))
           (not (file-writable-p (ad-get-arg 0)))
           (y-or-n-p (concat "File "
                             (ad-get-arg 0)
                             " is read-only.  Open it as root? ")))
      (th-find-file-sudo (ad-get-arg 0))
    ad-do-it))

(defun th-find-file-sudo (file)
  "Opens FILE with root privileges."
  (interactive "F")
  (set-buffer (find-file (concat "/sudo::" file))))
;; ------------------------------------------------------------------------
;; @ auto-save
;; 指定のアイドル秒で保存
(setq auto-save-buffers-enhanced-interval 2)
;; バージョン管理システムのみ有効
(auto-save-buffers-enhanced-include-only-checkout-path t)
(auto-save-buffers-enhanced t)
;; trampを使用している時は除外する
(setq auto-save-buffers-enhanced-exclude-regexps '("^/ssh:" "/sudo:" "/multi:"))
;; C-x a sでauto-save-buffers-enhancedの有効・無効をトグル
(global-set-key "\C-xas" 'auto-save-buffers-enhanced-toggle-activity)
;; ------------------------------------------------------------------------
;; @ key bind
;; C-zをundoに割り当てる
(define-key global-map "\C-z" 'undo)

;; M-2で新しいウィンドウを開く
(define-key global-map "\M-2" 'make-frame)

;; M-0でウィンドウを閉じる
(define-key global-map "\M-0" 'delete-frame)

;; ------------------------------------------------------------------------
;; @ auto-install.el
;; パッケージのインストールを自動化
;; http://www.emacswiki.org/emacs/auto-install.el

;;起動時の更新に時間がかかるためコメントアウト
;(when (require 'auto-install nil t)
;  (setq auto-install-directory "~/.emacs.d/elisp/")
;  (auto-install-update-emacswiki-package-name t)
;  (auto-install-compatibility-setup))

;; package
(require 'package)
(add-to-list 'package-archives
             '("marmalade" .
               "http://marmalade-repo.org/packages/"))
(package-initialize)

;; ------------------------------------------------------------------------
;; @  color-theme.el
;; Emacsのカラーテーマ(solarized)
(load-theme 'solarized-dark t)

;; ------------------------------------------------------------------------
;; Objective-C用の関連付け
(add-to-list 'magic-mode-alist '("\\(.\\|\n\\)*\n@implementation" . objc-mode))
(add-to-list 'magic-mode-alist '("\\(.\\|\n\\)*\n@interface" . objc-mode))
(add-to-list 'magic-mode-alist '("\\(.\\|\n\\)*\n@protocol" . objc-mode))

;; ------------------------------------------------------------------------
;; Coffeescript
(require 'coffee-mode)
(defun coffee-custom ()
  "coffee-mode-hook"
  (and (set (make-local-variable 'tab-width) 2)
       (set (make-local-variable 'coffee-tab-width) 2))
  )

(add-hook 'coffee-mode-hook
  '(lambda() (coffee-custom)))

;; ------------------------------------------------------------------------
;; 自動補完の設定
;; auto-complete
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories
             "~/.emacs.d/.cask/24.4.1/elpa/auto-complete-20140824.1658/dict")
(ac-config-default)
(setq ac-use-menu-map t)

;;; 適用するメジャーモードを足す
(add-to-list 'ac-modes 'scss-mode)
(add-to-list 'ac-modes 'web-mode)
(add-to-list 'ac-modes 'coffee-mode)

;;; ベースとなるソースを指定
(defvar my-ac-sources
              '(ac-source-yasnippet
                ac-source-abbrev
                ac-source-dictionary
                ac-source-words-in-same-mode-buffers))

;;; 個別にソースを指定
(defun ac-scss-mode-setup ()
  (setq-default ac-sources (append '(ac-source-css-property) my-ac-sources)))
(defun ac-web-mode-setup ()
  (setq-default ac-sources my-ac-sources))
(defun ac-coffee-mode-setup ()
  (setq-default ac-sources my-ac-sources))
(add-hook 'scss-mode-hook 'ac-scss-mode-setup)
(add-hook 'web-mode-hook 'ac-web-mode-setup)
(add-hook 'coffee-mode-hook 'ac-coffee-mode-setup)

(global-auto-complete-mode t)

;;; C-n / C-p で選択
(setq ac-use-menu-map t)

;;; yasnippetのbindingを指定するとエラーが出るので回避する方法。
(setf (symbol-function 'yas-active-keys)
      (lambda ()
        (remove-duplicates (mapcan #'yas--table-all-keys (yas--get-snippet-tables)))))

;; ------------------------------------------------------------------------
;; yasnippet
(require 'yasnippet)
(setq yas-snippet-dirs
      '("~/.emacs.d/snippets"
        "~/.emacs.d/elisp/yasnippet/snippets"))
(yas-global-mode 1)

;; 単語展開キーバインド

;; 既存スニペットを挿入する
(define-key yas-minor-mode-map (kbd "C-x i i") 'yas-insert-snippet)
;; 新規スニペットを作成するバッファを用意する
(define-key yas-minor-mode-map (kbd "C-x i n") 'yas-new-snippet)
;; 既存スニペットを閲覧・編集する
(define-key yas-minor-mode-map (kbd "C-x i v") 'yas-visit-snippet-file)

;; ------------------------------------------------------------------------
;; Anything
(defvar org-directory "")
(require 'anything)
(require 'anything-config)
(require 'anything-match-plugin)
(require 'anything-complete)
(anything-read-string-mode 1)
(require 'anything-show-completion)
(global-set-key "\C-x\C-b" 'anything-filelist+)
(global-set-key "\M-y" 'anything-show-kill-ring)
(anything-read-string-mode '(string variable command))

;; anything interface
(eval-after-load "anything-config"
  '(progn
     (defun my-yas/prompt (prompt choices &optional display-fn)
       (let* ((names (loop for choice in choices
                           collect (or (and display-fn
                                            (funcall display-fn choice))
                                       choice)))
              (selected (anything-other-buffer
                         `(((name . ,(format "%s" prompt))
                            (candidates . names)
                            (action . (("Insert snippet" . (lambda (arg) arg))))))
                         "*anything yas/prompt*")))
         (if selected
             (let ((n (position selected names :test 'equal)))
               (nth n choices))
           (signal 'quit "user quit!"))))
     (custom-set-variables '(yas/prompt-functions '(my-yas/prompt)))
     (define-key anything-command-map (kbd "y") 'yas/insert-snippet)))

;; snippet-mode for *.yasnippet files
(add-to-list 'auto-mode-alist '("\\.yasnippet$" . snippet-mode))

;; --------------------------------------------------
;; ruby-mode
;; http://shibayu36.hatenablog.com/entry/2013/03/18/192651
;; --------------------------------------------------
(autoload 'ruby-mode "ruby-mode"
  "Mode for editing ruby source files" t)
(add-to-list 'auto-mode-alist '("\\.rb$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Capfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile$" . ruby-mode))
(add-to-list 'interpreter-mode-alist '("ruby" . ruby-mode)) ;; shebangがrubyの場合、ruby-modeを開く

;; ruby-modeのインデントを改良する
(setq ruby-deep-indent-paren-style nil)
(defadvice ruby-indent-line (after unindent-closing-paren activate)
  (let ((column (current-column))
        indent offset)
    (save-excursion
      (back-to-indentation)
      (let ((state (syntax-ppss)))
        (setq offset (- column (current-column)))
        (when (and (eq (char-after) ?\))
                   (not (zerop (car state))))
          (goto-char (cadr state))
          (setq indent (current-indentation)))))
    (when indent
      (indent-line-to indent)
      (when (> offset 0) (forward-char offset)))))

;; --------------------------------------------------
;; ruby-end
;; endや括弧などを自動挿入する
;; http://blog.livedoor.jp/ooboofo3/archives/53748087.html
;; --------------------------------------------------
(require 'ruby-end)
(add-hook 'ruby-mode-hook
  '(lambda ()
    (abbrev-mode 1)
    (electric-pair-mode t)
    (electric-indent-mode t)
    (electric-layout-mode t)))

;; --------------------------------------------------
;; ruby-block
;; endにカーソルを合わせると、そのendに対応する行をハイライトする
;; --------------------------------------------------
(require 'ruby-block)
(ruby-block-mode t)
(setq ruby-block-highlight-toggle t)

;; ------------------------------------------------------------------------
;; rst-mode
;; Sphinxの書式設定
(require 'rst)
(setq auto-mode-alist
      (append '(("\\.rst$" . rst-mode)
                ("\\.rest$" . rst-mode)) auto-mode-alist))
;; 背景が黒い場合に見やすくする
(setq frame-background-mode 'dark)
;; スペースでのインデント
(add-hook 'rst-mode-hook '(lambda() (setq-default indent-tabs-mode nil)))

;; ------------------------------------------------------------------------
;; hiwin-mode
;; アクティブwindowを可視化する
;(require'hiwin)
;(hiwin-mode)

;; erlang-mode
(setq load-path (cons "/usr/local/Cellar/erlang/17.3/lib/erlang/lib/tools-2.7/emacs" load-path))
(setq erlang-root-dir "/usr/local/Cellar/erlang/17.3/lib/erlang/lib")
(setq exec-path (cons "/usr/local/Cellar/erlang/17.3/lib/erlang/bin" exec-path))
(require 'erlang-start)

;; ------------------------------------------------------------------------
;; 通知センター
(defvar notification-center-title "Emacs")

(defun notification-center (msg)
  (let ((tmpfile (make-temp-file "notification-center")))
   (with-temp-file tmpfile
     (insert
      (format "display notification \"%s\" with title \"%s\""
              msg notification-center-title)))
   (unless (zerop (call-process "osascript" tmpfile))
     (message "Failed: Call AppleScript"))
   (delete-file tmpfile)))

;; ------------------------------------------------------------------------
;; Pomodoro
(require 'pomodoro)
;; 作業時間終了後に開くファイル。デフォルトでは "~/.emacs.d/pomodoro.org"
;(setq pomodoro:file "~/.emacs.d/mywork.txt")

;; アイコンの変更
(setq pomodoro:mode-line-rest-sign "■")
(setq pomodoro:mode-line-long-rest-sign "■")

;; カラーの変更
(set-face-foreground 'pomodoro:work-face "blue")
(set-face-foreground 'pomodoro:rest-face "red")
(set-face-foreground 'pomodoro:long-rest-face "red")

(setq pomodoro:propertize-mode-line nil)

;; 作業時間関連(分)
(setq pomodoro:work-time 25
      pomodoro:rest-time 5
      pomodoro:long-rest-time 30)

(defun start/pomodoro-notification ()
  (notification-center "Work is Finish"))

(defun finish/pomodoro-notification ()
  (notification-center "Break time is finished"))

(add-hook 'pomodoro:finish-work-hook 'start/pomodoro-notification)
(add-hook 'pomodoro:finish-rest-hook 'finish/pomodoro-notification)
(add-hook 'pomodoro:long-rest-hook 'finish/pomodoro-notification)

