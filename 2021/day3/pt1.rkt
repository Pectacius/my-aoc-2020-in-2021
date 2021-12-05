#lang racket

(require racket/match)
(require test-engine/racket-tests)

(provide get-bit most-common-bit problem-input bits->integer parse-input)

(check-expect (get-bit (list 1 0) 0) 1)
(check-expect (get-bit (list 0 1 1 0 1) 0) 0)
(check-expect (get-bit (list 0 1 1 0 1) 4) 1)
(check-expect (get-bit (list 0 1 1 0 1 3 4 1) 6) 4)

(define (get-bit bit-num idx)
    (cond
        [(equal? idx 0) (first bit-num)]
        [else (get-bit (rest bit-num) (- idx 1))]))

(check-expect (most-common-bit empty 0) 1)
(check-expect (most-common-bit (list (list 1 0)) 0) 1)
(check-expect (most-common-bit (list (list 0 1)) 0) 0)
(check-expect (most-common-bit (list (list 0 1)) 1) 1)
(check-expect (most-common-bit (list (list 1 0)) 1) 0)
(check-expect (most-common-bit (list (list 1 0) (list 1 0) (list 1 1)) 1) 0)
(check-expect (most-common-bit (list
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
    (list 0 1 0 1 0)) 0) 1)


(define (most-common-bit bit-num-list idx)
    (define (most-common zero-count one-count num-list)
        (cond
            [(empty? num-list) (list zero-count one-count)]
            [else
                (let (
                    [bit-val (get-bit (first num-list) idx)])
                    (match bit-val
                        [1 (most-common zero-count (+ one-count 1) (rest num-list))]
                        [0 (most-common (+ zero-count 1) one-count (rest num-list))]))]))
    (match-let (
        [(list zero-count one-count) (most-common 0 0 bit-num-list)])
        (cond
            [(> zero-count one-count) 0]
            [else 1])))

(check-expect (parse-input empty ) empty)
(check-expect (parse-input (list "10101")) (list (list 1 0 1 0 1)))
(check-expect (parse-input (list "10101" "01011")) (list (list 1 0 1 0 1) (list 0 1 0 1 1)))

(define (parse-input input-list)
    (map
        (lambda (bit-str)
            (map
                (lambda (bit-char)
                    (string->number (string bit-char)))
                (string->list bit-str)))
        input-list))

(check-expect (bits->integer empty) 0)
(check-expect (bits->integer (list 1)) 1)
(check-expect (bits->integer (list 1 0)) 2)
(check-expect (bits->integer (list 1 1 1 1 0 0 1)) 121)

(define (bits->integer bits-list)
    (foldl (lambda
        (curr-val accum-val)
        (bitwise-ior (arithmetic-shift accum-val 1) curr-val))
        0
        bits-list))

(check-expect (find-most-least-common (list empty empty) 0) (list empty empty))
(check-expect (find-most-least-common (list (list 1 0) (list 1 0)) 2) (list (list 1 0) (list 0 1)))
(check-expect (find-most-least-common (list
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
    (list 0 1 0 1 0))
    5) (list (list 1 0 1 1 0) (list 0 1 0 0 1)))

(define (find-most-least-common byte-list num-bits)
    (define (find-bytes bit-num least-common most-common)
        (cond
            [(equal? -1 bit-num) (list most-common least-common)]
            [else
                (let
                    ([most (most-common-bit byte-list bit-num)])
                    (match most
                        [1 (find-bytes (- bit-num 1) (cons 0 least-common) (cons 1 most-common))]
                        [0 (find-bytes (- bit-num 1) (cons 1 least-common) (cons 0 most-common))]))]))

    (find-bytes (- num-bits 1) empty empty))

(check-expect (solve (list
    "00100"
    "11110"
    "10110"
    "10111"
    "10101"
    "01111"
    "00111"
    "11100"
    "10000"
    "11001"
    "00010"
    "01010")) 198)

(define (solve input-list)
    (match-let ([(list most least)
        (find-most-least-common
            (parse-input input-list)
            (string-length (first input-list)))])
        (* (bits->integer most) (bits->integer least))))

(define problem-input "2021/day3/input.txt")

(solve (file->lines problem-input))

(test)