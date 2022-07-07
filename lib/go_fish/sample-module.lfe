(defmodule sample-module
  (export all))

(defun my-sum (start stop)
    (let ((my-list (lists:seq start stop)))
      (* 2 (lists:foldl
             (lambda (n acc)
               (+ n acc))
             0 my-list))))