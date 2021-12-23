; This file also contains a test suite that can be run via `raco test pt1.rkt`
#lang racket

(provide cell make-cell mark-board check-rows? check-columns? is-winner? sum-unmarked parse-input problem-input)

(require racket/struct)


(define-struct cell (value marked?)
    #:transparent                   ; For equality check
    #:methods gen:custom-write      ; For pretty printing the fields during tests
    [(define write-proc
       (make-constructor-style-printer
        (lambda (obj) "cell")
        (lambda (obj) (list (cell-value obj) (cell-marked? obj)))))])

(module+ test
    (require test-engine/racket-tests))

(module+ test
    (define test-board
    (list
        (list
            (make-cell 70 #f)
            (make-cell 67 #f)
            (make-cell 69 #f))
        (list
            (make-cell 71 #f)
            (make-cell 95 #f)
            (make-cell 17 #f))))

    (check-expect
        (mark-board test-board 95)
            (list
                (list
                    (make-cell 70 #f)
                    (make-cell 67 #f)
                    (make-cell 69 #f))
                (list
                    (make-cell 71 #f)
                    (make-cell 95 #t)
                    (make-cell 17 #f))))
    (check-expect (mark-board test-board 1) test-board))

; attempts to mark the board with the specified number
(define (mark-board board num)
    (define (try-mark-row row)
        (map
            (lambda (curr-cell)
                (cond
                    [(equal? (cell-value curr-cell) num) (make-cell num #t)]
                    [else curr-cell]))
            row))

    (map try-mark-row board))



(module+ test
    (define test-board-almost-row-winner
        (list
            (list
                (make-cell 70 #f)
                (make-cell 67 #f)
                (make-cell 69 #f))
            (list
                (make-cell 71 #t)
                (make-cell 95 #f)
                (make-cell 17 #t))))

    (define test-board-row-winner
        (list
            (list
                (make-cell 70 #f)
                (make-cell 67 #f)
                (make-cell 69 #f))
            (list
                (make-cell 71 #t)
                (make-cell 95 #t)
                (make-cell 17 #t))))

    (check-expect (check-rows? test-board) #f)
    (check-expect (check-rows? test-board-almost-row-winner) #f)
    (check-expect (check-rows? test-board-row-winner) #t))

; Check if there is a marked row
(define (check-rows? board)
    (ormap
        (lambda (row)
            (empty?
                (filter
                    (lambda (curr-cell)
                        (not (cell-marked? curr-cell)))
                    row)))
        board))

(module+ test
    (define test-board-almost-col-winner
        (list
            (list
                (make-cell 70 #t)
                (make-cell 67 #f)
                (make-cell 69 #f))
            (list
                (make-cell 71 #t)
                (make-cell 95 #f)
                (make-cell 17 #t))
            (list
                (make-cell 2  #f)
                (make-cell 89 #f)
                (make-cell 12 #f))))

    (define test-board-col-winner
        (list
            (list
                (make-cell 70 #t)
                (make-cell 67 #f)
                (make-cell 69 #f))
            (list
                (make-cell 71 #t)
                (make-cell 95 #f)
                (make-cell 17 #t))
            (list
                (make-cell 2  #t)
                (make-cell 89 #f)
                (make-cell 12 #f))))

    (check-expect (check-columns? test-board) #f)
    (check-expect (check-columns? test-board-almost-row-winner) #f)
    (check-expect (check-columns? test-board-row-winner) #f)
    (check-expect (check-columns? test-board-almost-col-winner) #f)
    (check-expect (check-columns? test-board-col-winner) #t))


; Check if there is a marked column
; Assumes board has at least one row
(define (check-columns? board)
    (define (check-col-num num)
        (andmap
            (lambda (curr-val)
                (cell-marked? (list-ref curr-val num)))
            board))
    (ormap
        (lambda (idx)
            (check-col-num idx))
        (build-list (length (first board)) values)))

(define (is-winner? board)
    (or (check-columns? board) (check-rows? board)))



(module+ test
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
    (define expected-winner
        (list
            (list
                (make-cell 14 #t) (make-cell 21 #t) (make-cell 17 #t) (make-cell 24 #t) (make-cell 4 #t))
            (list
                (make-cell 10 #f) (make-cell 16 #f) (make-cell 15 #f) (make-cell 9 #t) (make-cell 19 #f))
            (list
                (make-cell 18 #f) (make-cell 8 #f) (make-cell 23 #t) (make-cell 26 #f) (make-cell 20 #f))
            (list
                (make-cell 22 #f) (make-cell 11 #t) (make-cell 13 #f) (make-cell 6 #f) (make-cell 5 #t))
            (list
                (make-cell 2 #t) (make-cell 0 #t) (make-cell 12 #f) (make-cell 3 #f) (make-cell 7 #t))))
    (check-expect (find-winner test-nums-list test-boards-list) (list expected-winner 24)))


; Finds the winning board
(define (find-winner called-numbers board-list)
    (define (call-number numbers-to-call board-state-list)
        (cond
            [(empty? numbers-to-call) empty]
            [else
                (let* (
                    [new-board-state-list
                        (map
                            (lambda (board)
                            (mark-board board (first numbers-to-call)))
                        board-state-list)]
                    [winners-list (filter is-winner? new-board-state-list)])
                    (cond
                        [(empty? winners-list)
                            (call-number
                                (rest numbers-to-call)
                                new-board-state-list)]
                        [else
                            (list (first winners-list) (first numbers-to-call))]))]))
    (call-number called-numbers board-list))

(module+ test
    (check-expect (sum-unmarked expected-winner) 188))

(define (sum-unmarked board)
    (foldl + 0
        (map
            (lambda (row)
                (foldl + 0
                    (map
                        cell-value
                        (filter
                            (lambda (curr-cell)
                                (not (cell-marked? curr-cell)))
                        row))))
        board)))

(module+ test
    (check-expect
        (parse-num-string "4,3,4,5,10" ",")
        (list 4 3 4 5 10))
    (check-expect
        (parse-num-string "4 21 47 5 10")
        (list 4 21 47 5 10))
    (check-expect
        (parse-num-string "76 85 83  4 40" )
        (list 76 85 83 4 40)))


(define (parse-num-string numbers-string [delim #px"\\s+"])
    (map string->number (string-split numbers-string delim)))

(module+ test
    (check-expect (parse-list-of-boards empty) (list empty))
    (check-expect
        (parse-list-of-boards (list "70 67 69" "71 95 17"))
        (list
            (list
                (list
                    (make-cell 70 #f)
                    (make-cell 67 #f)
                    (make-cell 69 #f))
                (list
                    (make-cell 71 #f)
                    (make-cell 95 #f)
                    (make-cell 17 #f)))))
    (check-expect
        (parse-list-of-boards (list "79 67 31" "71 128 11" "" "451 876 1" "90 3 56"))
        (list
            (list
                (list
                    (make-cell 79 #f)
                    (make-cell 67 #f)
                    (make-cell 31 #f))
                (list
                    (make-cell 71 #f)
                    (make-cell 128 #f)
                    (make-cell 11 #f)))
            (list
                (list
                    (make-cell 451 #f)
                    (make-cell 876 #f)
                    (make-cell 1 #f))
                (list
                    (make-cell 90 #f)
                    (make-cell 3 #f)
                    (make-cell 56 #f))))))



(define (parse-list-of-boards list-of-lines)
    (define (parse-list-to-boards lines-list curr-board board-list)
        (cond
            [(empty? lines-list)
                (reverse (cons (reverse curr-board) board-list))]
            [(equal? (first lines-list) "")
                (parse-list-to-boards
                    (rest lines-list)
                    empty
                    (cons (reverse curr-board) board-list))]
            [else
                (parse-list-to-boards
                    (rest lines-list)
                    (cons
                        (map
                            (lambda (value)
                                (make-cell value #f))
                            (parse-num-string (first lines-list)))
                        curr-board)
                    board-list)]))

    (parse-list-to-boards list-of-lines empty empty))

(define (parse-input input-file-name)
    (let ([lines-list (file->lines input-file-name)])
        (list
            (parse-num-string (first lines-list) ",")
            (parse-list-of-boards (rest (rest lines-list))))))



(define problem-input "2021/day4/input.txt")


(module+ main
    (define (solve input)
    (match-let* (
        [(list nums-list board-list) (parse-input input)]
        [(list winning-board winning-num) (find-winner nums-list board-list)])
        (* (sum-unmarked winning-board) winning-num)))
    (solve problem-input))

(module+ test
    (test))

