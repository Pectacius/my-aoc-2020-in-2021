#lang racket

(require racket/match)
(require test-engine/racket-tests)

(define problem-input "2021/day2/input.txt")


(define (advance-sub ins state)
    (match-let (
        [(list dir val) (string-split ins)]
        [(list x y aim) state])
        (match dir
            ["forward" (list
                    (+ x (string->number val))
                    (+ y (* aim (string->number val)))
                    aim)]
            ["down" (list
                    x
                    y
                    (+ aim (string->number val)))]
            ["up" (list
                    x
                    y
                    (- aim (string->number val)))])))

(check-expect
    (compute-sol
        (list
            "forward 5"
            "down 5"
            "forward 8"
            "up 3"
            "down 8"
            "forward 2")) 900)

(define (compute-sol input)
    (match-let(
        [(list x y aim) (foldl advance-sub (list 0 0 0) input)])
        (* x y)))


(test)

(compute-sol (file->lines problem-input))