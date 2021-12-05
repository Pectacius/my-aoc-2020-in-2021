#lang racket

(require racket/match)
(require test-engine/racket-tests)
(require "pt1.rkt")


(check-expect (chosen-bit 0 #t) 0)
(check-expect (chosen-bit 1 #t) 1)
(check-expect (chosen-bit 0 #f) 1)
(check-expect (chosen-bit 1 #f) 0)

(define (chosen-bit val most?)
    (cond
        [most? val]
        [else
            (match val
                [1 0]
                [0 1])]))

(define (eliminate-non-matching bits-list bit-val idx)
    (filter
        (lambda (val)
            (equal? (get-bit val idx) bit-val))
        bits-list))

(define (frequent-column input-data-list most?)
    (define (check-column idx data-list)
        (cond
            [(equal? (length data-list) 1) (first data-list)]
            [else
                (check-column
                    (+ idx 1)
                    (eliminate-non-matching
                        data-list
                        (chosen-bit
                            (most-common-bit data-list idx)
                            most?)
                        idx))]))
    (check-column 0 input-data-list))

(check-expect (find-oxygen (list
    (list 0 0 1 0 0)
    (list 1 1 1 1 0)
    (list 1 0 1 1 0)
    (list 1 0 1 1 1)
    (list 1 0 1 0 1)
    (list 0 1 1 1 1)
    (list 0 0 1 1 1)
    (list 1 1 1 0 0)
    (list 1 0 0 0 0)
    (list 1 1 0 0 1)
    (list 0 0 0 1 0)
    (list 0 1 0 1 0)))
    23)

(define (find-oxygen input-data-list)
    (bits->integer(frequent-column input-data-list #t)))

(check-expect (find-co2 (list
    (list 0 0 1 0 0)
    (list 1 1 1 1 0)
    (list 1 0 1 1 0)
    (list 1 0 1 1 1)
    (list 1 0 1 0 1)
    (list 0 1 1 1 1)
    (list 0 0 1 1 1)
    (list 1 1 1 0 0)
    (list 1 0 0 0 0)
    (list 1 1 0 0 1)
    (list 0 0 0 1 0)
    (list 0 1 0 1 0)))
    10)
(define (find-co2 input-data-list)
    (bits->integer(frequent-column input-data-list #f)))

(define (solve input)
    (let ([data-list (parse-input input)])
        (* (find-co2 data-list) (find-oxygen data-list))))

(solve (file->lines problem-input))

(test)