(require 'pdf-tools)
(pdf-tools-install)
(shell-command "xmodmap ~/nix-config/keyboard.xmodmap")
(shell-command "xmodmap ~/nix-config/keyboard.xmodmap")
(shell-command "xmodmap ~/nix-config/keyboard.xmodmap")
(shell-command "xmodmap ~/nix-config/keyboard.xmodmap")


(define-key (kbd "s-u") (lambda () (shell-command "amixer set Master 10%+")))
(define-key (kbd "s-d") (lambda () (shell-command "amixer set Master 10%-")))
(define-key (kbd "s-m") (lambda () (shell-command "amixer set Master toggle")))
