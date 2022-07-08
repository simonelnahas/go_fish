(defmodule go-fish
  (export (give-cards 1) (ocean 1) (initial-state 0) (game-start 0) (player 1) (start-player 0)
          (draw-card 1)))

;; an ocean 
;; where we can send it the message drawcard and we will receive back a card
(defun initial-state () '('heart1 'heart2 'spades3)) ;TODO replace with deck of 52 cards
(defun ocean
  ([()] ;; no more cards left
   (receive
    ((tuple 'draw caller-pid)
     (! caller-pid 'no-cards-left)
     (ocean ()))))
  ([(cons card deck)] ; take the card in front
   (receive
    ((tuple 'draw caller-pid)
     (lfe_io:format "OCEAN: send card: ~p - to pid: ~p\n" (list card caller-pid))
     (! caller-pid (tuple 'card card))
     (ocean deck)))))

;; TODO change to card record. (make-card suit 'heart value 2)
(defun get-cards-with-number (number cards)
  (lists:filter (lambda (x) ()))
  ([(number cards)]))

;; take a card when function is called
;; 1. draw card is sent and received
;; 2. card is sent back and received 
(defun player (deck)
  (lfe_io:format "player1 has the deck: ~p\n" (list deck))
  (receive ('go-fish
            (! 'ocean (tuple 'draw (self)))
            (player deck))
           ((tuple 'card card)
            (player (cons card deck)))
           ((tuple 'cards cards)
            (player (++ cards deck)))
           ((tuple 'give-me-all-your number to)
            (let ((matches) ())))))

(defun draw-card (player)
  (! player 'go-fish))

(defun give-cards (player cards)
  (! player (tuple 'cards cards)))

;;TODO
(defun give-me-all-your (from to number)
  (! to (tuple 'give-me-all-your number to)))

(defun game-start ()
  (lfe_io:format "STARTING GAME\n\n" ())
  (register 'ocean (spawn 'go-fish 'ocean (list (initial-state))))
  (register 'player1 (spawn 'go-fish 'player '(())))
  (register 'player2 (spawn 'go-fish 'player '(()))))

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