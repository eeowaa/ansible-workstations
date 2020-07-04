((yaml-mode . ((ansible-doc-mode . t)))

 ;; For whatever reason, the following is not working when `evil-mode'
 ;; is enabled on (vanilla) Emacs 26.3.  One workaround is to use
 ;; file-local variables, but I don't want to clutter up my inventory
 ;; files with editor-specific configuration.
 ("inventories" . ((nil . ((mode . conf-unix))))))
