(defmodule gofish
  (export (ocean 1) (initial-state 0) (start 0)))

;; an ocean 
;; where we can send it the message drawcard and we will receive back a card
(defun initial-state () '('heart1 'heart2 'spades3)) ;TODO replace with cards
(defun ocean
  ([()] (receive 
         ((tuple 'draw caller-pid) 
          (! caller-pid 'no-cards-left)
          (ocean ()))))
  ([(cons card deck)] ; take the card in front
  ;;  (lfe_io:format "ocean: waiting\n" ())
   (receive
    ((tuple 'draw caller-pid)
     (lfe_io:format "OCEAN: send card: ~p - to pid: ~p\n" (list card caller-pid))
     (! caller-pid (tuple 'card card))
     (ocean deck)))))

;; we want a to send a message to the deck an receive back a card.
;; Current status:
;;    1. it sends the message 
;;    2. it receives the message
;;    3. we do receive the card back
;;    4. we 

(defun receiver ()
  (receive ((tuple 'card card)
            (lfe_io:format "START: received the card: ~p\n" (list card))
            (receiver))
           ('no-cards-left 
            (lfe_io:format "START: no cards left\n" ()))))

(defun start ()
  (let ((ocean-pid (spawn 'gofish 'ocean (list (initial-state)))))
    (lfe_io:format "PLAYING:\n\n" ())
    (! ocean-pid (tuple 'draw (self)))
    (! ocean-pid (tuple 'draw (self)))
    (! ocean-pid (tuple 'draw (self)))
    (! ocean-pid (tuple 'draw (self)))
    (! ocean-pid (tuple 'draw (self))))
  (receiver))

;;; example code from the LFE docs:
(defmodule tut20
  (export (start 0) (ping 1) (pong 0)))

(defun ping
  ((0)
   (! 'pong 'finished)
   (lfe_io:format "Ping finished~n" ()))
  ((n)
   (! 'pong (tuple 'ping (self)))
   (receive
    ('pong (lfe_io:format "Ping received pong~n" ())))
   (ping (- n 1))))

(defun pong ()
  (receive
   ('finished
    (lfe_io:format "Pong finished~n" ()))
   ((tuple 'ping ping-pid)
    (lfe_io:format "Pong received ping~n" ())
    (! ping-pid 'pong)
    (pong))))

(defun start ()
  (let ((pong-pid (spawn 'tut20 'pong ())))
    (register 'pong pong-pid)
    (spawn 'tut20 'ping '(3))))