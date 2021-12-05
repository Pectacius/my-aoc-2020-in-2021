#lang racket

(require test-engine/racket-tests)


(define (parse-input file)
    (define (iter file line-list)
        (let ([line (read-line file)])
            (cond
                [(eof-object? line) (map string->number (reverse line-list))]
                [else (iter file (cons line line-list))])))
    (iter file empty))

(check-expect (count-window empty) 0)
(check-expect (count-window (list 1)) 0)
(check-expect (count-window (list 1 2)) 0)
(check-expect (count-window (list 1 2 3)) 0)
(check-expect (count-window (list 1 2 3 4)) 1)
(check-expect (count-window
    (list 199 200 208 210 200 207 240 269 260 263)) 5)


(define (count-window input-list)
    (define (count-window-iter input-list prev-val total-sum is-first?)
        (cond
            [(empty? input-list) total-sum]
            [(< (length input-list) 3) total-sum]
            [else
                (let
                    ([win
                        (+ (first input-list) (second input-list) (third input-list))])
                        (cond
                            [(or is-first? (<= win prev-val))
                                (count-window-iter (rest input-list)
                                win total-sum #f)]
                            [else
                                (count-window-iter (rest input-list)
                                win (+ total-sum 1) #f)]))]))
    (count-window-iter input-list 0 0 #t))

(test)

(call-with-input-file "2021/day1/input.txt" (lambda (input) (count-window (parse-input input))))