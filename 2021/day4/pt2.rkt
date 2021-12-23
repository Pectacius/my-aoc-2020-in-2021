#lang racket

(require "pt1.rkt")

(module+ test
    (require "pt1.rkt")
    (require test-engine/racket-tests)

    (define test-nums-list
        (list 7 4 9 5 11 17 23 2 0 14 21 24 10 16 13 6 15 25 12 22 18 20 8 19 3 26 1))
    (define test-boards-list
        (map (lambda (board) (map (lambda (row) (map (lambda (val) (make-cell val #f)) row)) board))
            (list
                (list
                    (list 22 13 17 11  0)
                    (list  8  2 23  4 24)
                    (list 21  9 14 16  7)
                    (list  6 10  3 18  5)
                    (list  1 12 20 15 19))
                (list
                    (list  3 15  0  2 22)
                    (list  9 18 13 17  5)
                    (list 19  8  7 25 23)
                    (list 20 11 10 24  4)
                    (list 14 21 16 12  6))
                (list
                    (list 14 21 17 24  4)
                    (list 10 16 15  9 19)
                    (list 18  8 23 26 20)
                    (list 22 11 13  6  5)
                    (list  2  0 12  3  7)))))
    (define last-winner
            (list
                (list (make-cell 3 #f) (make-cell 15 #f) (make-cell 0 #t) (make-cell 2 #t) (make-cell 22 #f))
                (list (make-cell 9 #t) (make-cell 18 #f) (make-cell 13 #t) (make-cell 17 #t) (make-cell 5 #t))
                (list (make-cell 19 #f) (make-cell 8 #f) (make-cell 7 #t) (make-cell 25 #f) (make-cell 23 #t))
                (list (make-cell 20 #f) (make-cell 11 #t) (make-cell 10 #t) (make-cell 24 #t) (make-cell 4 #t))
                (list (make-cell 14 #t) (make-cell 21 #t) (make-cell 16 #t) (make-cell 12 #f) (make-cell 6 #f))))

    (check-expect (is-winner? last-winner) #t)
    (check-expect
        (find-last-winner test-nums-list test-boards-list)

        (list last-winner 13))
    (test))

(define (find-last-winner numbers-to-call boards-list)
    (define (call-number nums-to-call board-states)
        (let* (
            [new-board-state-list
                (map
                    (lambda (board)
                        (mark-board board (first nums-to-call)))
                    board-states)]
            [non-winners-list (filter (lambda (curr-board)(not (is-winner? curr-board))) new-board-state-list)])
            (
                cond
                [(and (equal? (length new-board-state-list) 1) (is-winner? (first new-board-state-list)))
                    (list (first new-board-state-list) (first nums-to-call))]
                [else
                    (call-number
                        (rest nums-to-call)
                        non-winners-list)])))
    (call-number numbers-to-call boards-list))

(module+ main
    (define (solve input)
    (match-let* (
        [(list nums-list board-list) (parse-input input)]
        [(list winning-board winning-num) (find-last-winner nums-list board-list)])
        (* (sum-unmarked winning-board) winning-num)))
    (solve problem-input))
