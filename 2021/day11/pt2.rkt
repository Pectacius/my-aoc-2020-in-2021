#lang racket

(require "pt1.rkt")

(module+ test
    (require test-engine/racket-tests)

    (define test-grid (create-energy-lvl-grid "test.txt"))

    (check-expect (find-sync-step test-grid) 195)

    (test))

(define (find-sync-step grid)
    (define sync-state
        (vector->immutable-vector
            (make-vector (vector-length (energy-lvl-grid-entries grid)) 0)))
    (define (until-sync curr-grid step-num)
        (match-let (
            [(list new-grid flash-count)
                (energy-lvl-grid-flash curr-grid)]
            [curr-step (add1 step-num)])
            (cond
                [(equal? sync-state (energy-lvl-grid-entries new-grid))
                    curr-step]
                [else (until-sync new-grid curr-step)])))
    (until-sync grid 0))

(module+ main
    (define problem-input "2021/day11/input.txt")
    (find-sync-step (create-energy-lvl-grid problem-input)))