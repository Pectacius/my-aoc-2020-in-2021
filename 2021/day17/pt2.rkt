#lang racket

(require "pt1.rkt")

(define (num-valid-initial-conditions targ)
    (define (find-valid-initial-given-x x-vel)
        (foldl
            (lambda (curr-y-vel curr-valid-count)
                (match-let
                    ([(list hit? apogee)
                        (probe-traj-apogee
                            targ
                            initial-x-pos initial-y-pos
                            x-vel curr-y-vel 0)])
                        (if hit? (add1 curr-valid-count) curr-valid-count)))
            0 (range -1000 1000 1) ))

    (define min-x-vel (exact-floor (/ (sub1 (sqrt (add1 (* 8 (target-left-x targ))))) 2)))
    (define max-x-vel (target-right-x targ))
    (define min-y-vel 1)
    (foldl
        (lambda (curr-x-vel curr-valid-count)
            (+ curr-valid-count (find-valid-initial-given-x curr-x-vel)))
        0
        (range min-x-vel (add1 max-x-vel) 1)))

(module+ main
    (define problem-input "2021/day17/input.txt")
    (num-valid-initial-conditions (target 201 230 -99 -65)))