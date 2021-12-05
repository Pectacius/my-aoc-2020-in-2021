#lang racket

(require test-engine/racket-tests)


(define (parse-input file)
    (define (iter file line-list)
        (let ([line (read-line file)])
            (cond
                [(eof-object? line) (map string->number (reverse line-list))]
                [else (iter file (cons line line-list))])))
    (iter file empty))


(check-expect (count-increases empty) 0)
(check-expect (count-increases (list 1)) 0)
(check-expect (count-increases (list 1 2)) 1)
(check-expect (count-increases (list 1 2 3 1 1 2)) 3)

(define (count-increases input-list)
    (define (count-num input count previous isfirst?)
        (cond
            [(empty? input) count]
            [isfirst? (count-num (rest input) count (first input) #f)]
            [else
                (cond
                    [(> (first input) previous)
                        (count-num (rest input) (+ count 1) (first input) #f)]
                    [else
                        (count-num (rest input) count (first input) #f)])]))
    (count-num input-list 0 0 #t))


(test)

(call-with-input-file "2021/day1/input.txt" (lambda (input) (count-increases (parse-input input))))
