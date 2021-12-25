#lang racket

(require "pt1.rkt")

(define max-val 9)

(module+ test
    (require test-engine/racket-tests)

    (define test-grid (create-lava-tub-grid "test.txt")))

(module+ test
    (check-expect (lava-tube-grid-get-neighbour 1 2 up) (list 1 1))
    (check-expect (lava-tube-grid-get-neighbour 3 4 left) (list 2 4))
    (check-expect (lava-tube-grid-get-neighbour 2 7 down) (list 2 8))
    (check-expect (lava-tube-grid-get-neighbour 4 10 right) (list 5 10)))

; Gets the coordinate of neighbour of the specified point in the specified direction.
; Assumes that the neigbhour in the direction exists
(define (lava-tube-grid-get-neighbour x y dir)
    (cond
        [(equal? dir up) (list x (sub1 y))]
        [(equal? dir left) (list (sub1 x) y)]
        [(equal? dir down) (list x (add1 y))]
        [(equal? dir right) (list (add1 x) y)]))


(module+ test
    (check-expect (lava-tube-grid-valid-visit-pos test-grid 1 0 up (set)) empty)
    (check-expect (lava-tube-grid-valid-visit-pos test-grid 1 0 right (set)) empty)
    (check-expect (lava-tube-grid-valid-visit-pos test-grid 1 0 left (set)) (list 0 0))
    (check-expect (lava-tube-grid-valid-visit-pos test-grid 1 0 up (set (list 0 0))) empty)
    (check-expect (lava-tube-grid-valid-visit-pos test-grid 0 0 down (set)) (list 0 1)))

; Determines coordinate of neighbour in the specified direction.
; Will return empty if neighbour is not a valid position to visit
(define (lava-tube-grid-valid-visit-pos grid x y dir visited)
    (define (is-valid? pos)
        ; Value cannot be max-val or be already visited
        (and
            (not (equal? (lava-tube-grid-pos grid (first pos) (last pos)) max-val))
            (not (set-member? visited pos))))
    (cond
        [(lava-tube-grid-neighbour? grid x y dir)
            (let ([neighbour (lava-tube-grid-get-neighbour x y dir)])
                (cond
                    [(is-valid? neighbour) neighbour]
                    [else empty]))]
        [else empty]))

(module+ test
    (check-expect (lava-tube-grid-to-visit test-grid 1 0 (set)) (list (list 0 0)))
    (check-expect
        (lava-tube-grid-to-visit test-grid 8 0 (set (list 9 0)))
        (list (list 7 0) (list 8 1)))
    (check-expect (lava-tube-grid-to-visit test-grid 5 4 (set (list 6 4))) empty))

; Determines all the neighbours to visit
(define (lava-tube-grid-to-visit grid x y visited)
    (filter-not empty?
        (list
            (lava-tube-grid-valid-visit-pos grid x y up visited)
            (lava-tube-grid-valid-visit-pos grid x y left visited)
            (lava-tube-grid-valid-visit-pos grid x y down visited)
            (lava-tube-grid-valid-visit-pos grid x y right visited))))

(module+ test
    (check-expect (lava-tube-grid-basin-size test-grid (list 1 0)) 3)
    (check-expect (lava-tube-grid-basin-size test-grid (list 9 0)) 9)
    (check-expect (lava-tube-grid-basin-size test-grid (list 2 2)) 14)
    (check-expect (lava-tube-grid-basin-size test-grid (list 6 4)) 9))

; Does a BFS
(define (lava-tube-grid-basin-size grid local-min)
    (define (BFS to-visit visited total-size)
        (cond
            [(empty? to-visit) total-size]
            [(set-member? visited (first to-visit))
                (BFS (rest to-visit) visited total-size)]
            [else ;(display (first to-visit))
                (BFS
                    (append
                        (rest to-visit)
                        (lava-tube-grid-to-visit
                            grid
                            (first (first to-visit))
                            (last (first to-visit))
                            visited))
                    (set-add visited (first to-visit))
                    (add1 total-size))]))
    (BFS (list local-min) (set) 0))

(module+ test
    (test))

(module+ main
    (define input-file "2021/day9/input.txt")
    (define grid (create-lava-tub-grid input-file))
    (define ordered-basins
        (sort
            (map
                (lambda (local-min)
                    (lava-tube-grid-basin-size grid local-min))
                (lava-tube-grid-local-mins grid))
            >))

    (* (first ordered-basins) (second ordered-basins) (third ordered-basins)))