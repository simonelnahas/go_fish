(defmodule go-fish
  (export (give-cards 2) (ocean 1) 
          (game-start 0) (example-play 0)
          (player 1)
          (draw-card 1) (make-deck 0)
          (give-me-all-your 3)))

;; an ocean 
;; where we can send it the message drawcard and we will receive back a card
(defun make-deck ()
  (list-comp ((<- suit '(heart spades diamonds clubs))
              (<- value (lists:seq 2 14)))
             (tuple suit value))) ;; TODO shuffle cards

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

(defun get-cards-with-number (asking-value cards)
  (lists:filter (lambda [card] (let (((tuple _suit value) card)) (== value asking-value))) cards))


;; (defun remove-cards-from-cards (cards-to-remove cards)
;;   (lists:filter (lambda (card))
;;                 '(#(heart 2) #(heart 3))))
;; take a card when function is called
;; 1. draw card is sent and received
;; 2. card is sent back and received 
(defun player (hand)
  (lfe_io:format "player has the hand: ~p\n" (list hand))
  (receive ('go-fish
            (! 'ocean (tuple 'draw (self)))
            (player hand))
           ((tuple 'card card)
            (lfe_io:format "player receiving the card: ~p\n" (list card))
            (player (cons card hand)))
           ((tuple 'cards cards)
            (player (++ cards hand)))
           ((tuple 'give-me-all-your taker asking-value)
            (let ((matches (get-cards-with-number asking-value hand)))
              (! taker (tuple 'cards matches))
              (player hand))))); TODO remove matches from hand

(defun draw-card (player)
  (! player 'go-fish))

(defun give-cards (player cards)
  (! player (tuple 'cards cards)))

(defun give-me-all-your  (giver taker asking-value)
  (! giver (tuple 'give-me-all-your taker asking-value)))

(defun game-start ()
  (lfe_io:format "STARTING GAME\n\n" ())
  (register 'ocean (spawn 'go-fish 'ocean (list (make-deck))))
  (register 'player1 (spawn 'go-fish 'player '(())))
  (register 'player2 (spawn 'go-fish 'player '(()))))

(defun example-play ()
  (lfe_io:format "EXAMPLE GAME\n\n" ())
  (lists:foreach
   (lambda (x) (draw-card 'player1))
   (lists:seq 1 50))
  (give-me-all-your 'player1 'player2 2))

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