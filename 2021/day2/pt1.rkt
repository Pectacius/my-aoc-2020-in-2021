#lang racket

(require racket/match)
(require test-engine/racket-tests)

(define problem-input "2021/day2/input.txt")


(define (parse-input value)
    (let ([val (string-split value)])
        (match (first val)
            ["forward" (list (string->number (second val)) 0)]
            ["down" (list 0 (string->number (second val)))]
            ["up" (list 0 (- (string->number (second val))))])))

(check-expect (sum-pos (list 0 0) (list 0 0)) (list 0 0))
(check-expect (sum-pos (list 1 5) (list -10 35)) (list -9 40))

(define (sum-pos pos-val pos-sum)
    (match-let (
        [(list x-sum y-sum) pos-sum ]
        [(list x-val y-val) pos-val])
        (list (+ x-sum x-val) (+ y-sum y-val))))

(define (compute-sol input)
    (match-let(
        [(list x y) (foldl sum-pos (list 0 0) (map parse-input input))])
        (* x y)))

(test)

(compute-sol (file->lines problem-input))


