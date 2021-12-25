#lang racket

(provide
    up left down right
    lava-tube-grid
    create-lava-tub-grid
    lava-tube-grid-width
    lava-tube-grid-height
    lava-tube-grid-pos
    lava-tube-grid-neighbour?
    lava-tube-grid-less-than-dir?
    lava-tube-grid-is-local-min?
    lava-tube-grid-local-mins)

; Enum up, left, down, right
(define up 0)
(define left 1)
(define down 2)
(define right 3)

(define-struct lava-tube-grid (grid width height) #:transparent)

(module+ test
    (require test-engine/racket-tests)

    (define test-grid (create-lava-tub-grid "test.txt"))

    (define expected-grid
        (vector
            (vector 2 1 9 9 9 4 3 2 1 0)
            (vector 3 9 8 7 8 9 4 9 2 1)
            (vector 9 8 5 6 7 8 9 8 9 2)
            (vector 8 7 6 7 8 9 6 7 8 9)
            (vector 9 8 9 9 9 6 5 6 7 8)))

    (check-expect (lava-tube-grid-grid test-grid) expected-grid)
    (check-expect (lava-tube-grid-width test-grid) 10)
    (check-expect (lava-tube-grid-height test-grid) 5))

(define (create-lava-tub-grid grid-file)
    (let (
        [vec-grid
            (list->vector
                (map
                    (lambda (line)
                        (list->vector (map string->number (map string (string->list line)))))
                    (file->lines grid-file)))])
        (make-lava-tube-grid
            vec-grid
            (vector-length (vector-ref vec-grid 0))
            (vector-length vec-grid))))


(module+ test
    (check-expect (lava-tube-grid-pos test-grid 0 0) 2)
    (check-expect (lava-tube-grid-pos test-grid 8 4) 7)
    (check-expect (lava-tube-grid-pos test-grid 2 3) 6))

; Get value at position (x, y). Assumes that coord (x, y) is inside the grid
(define (lava-tube-grid-pos grid x y)
    (vector-ref (vector-ref (lava-tube-grid-grid grid) y) x))


(module+ test
    (check-expect (lava-tube-grid-neighbour? test-grid 1 1 up) #t)
    (check-expect (lava-tube-grid-neighbour? test-grid 0 0 up) #f)

    (check-expect (lava-tube-grid-neighbour? test-grid 0 0 right) #t)
    (check-expect (lava-tube-grid-neighbour? test-grid 9 0 right) #f)

    (check-expect (lava-tube-grid-neighbour? test-grid 0 0 down) #t)
    (check-expect (lava-tube-grid-neighbour? test-grid 0 4 down) #f)

    (check-expect (lava-tube-grid-neighbour? test-grid 2 3 left) #t)
    (check-expect (lava-tube-grid-neighbour? test-grid 0 0 left) #f))

(define (lava-tube-grid-neighbour? grid x y dir)
    (let (
        [width (lava-tube-grid-width grid)]
        [height (lava-tube-grid-height grid)])
        (cond
            [(equal? dir up)
                (let ([y-pos (sub1 y)])
                    (and
                        (<= 0 x)
                        (< x width)
                        (<= 0 y-pos)
                        (< y-pos height)))]
            [(equal? dir left)
                (let ([x-pos (sub1 x)])
                    (and
                        (<= 0 x-pos)
                        (< x-pos width)
                        (<= 0 y)
                        (< y height)))]
            [(equal? dir down)
                (let ([y-pos (add1 y)])
                    (and
                        (<= 0 x)
                        (< x width)
                        (<= 0 y-pos)
                        (< y-pos height)))]
            [(equal? dir right)
                (let ([x-pos (add1 x)])
                    (and
                        (<= 0 x-pos)
                        (< x-pos width)
                        (<= 0 y)
                        (< y height)))])))

(module+ test
    ; Less than due to no neighbour in that direction
    (check-expect (lava-tube-grid-less-than-dir? test-grid 9 0 up) #t)
    (check-expect (lava-tube-grid-less-than-dir? test-grid 0 0 left) #t)
    (check-expect (lava-tube-grid-less-than-dir? test-grid 0 4 down) #t)
    (check-expect (lava-tube-grid-less-than-dir? test-grid 9 4 right) #t)

    ; Actually less than (has neighbour in that direction)
    (check-expect (lava-tube-grid-less-than-dir? test-grid 8 4 up) #t)
    (check-expect (lava-tube-grid-less-than-dir? test-grid 6 1 left) #t)
    (check-expect (lava-tube-grid-less-than-dir? test-grid 9 2 down) #t)
    (check-expect (lava-tube-grid-less-than-dir? test-grid 2 2 right) #t)

    ; Greater than
    (check-expect (lava-tube-grid-less-than-dir? test-grid 5 3 up) #f)
    (check-expect (lava-tube-grid-less-than-dir? test-grid 4 2 left) #f)
    (check-expect (lava-tube-grid-less-than-dir? test-grid 1 2 down) #f)
    (check-expect (lava-tube-grid-less-than-dir? test-grid 4 0 right) #f))

(define (lava-tube-grid-less-than-dir? grid x y dir)
    (cond
        [(lava-tube-grid-neighbour? grid x y dir)
            (cond
                [(equal? dir up)
                    (< (lava-tube-grid-pos grid x y) (lava-tube-grid-pos grid x (sub1 y)))]
                [(equal? dir left)
                    (< (lava-tube-grid-pos grid x y) (lava-tube-grid-pos grid (sub1 x) y))]
                [(equal? dir down)
                    (< (lava-tube-grid-pos grid x y) (lava-tube-grid-pos grid x (add1 y)))]
                [(equal? dir right)
                    (< (lava-tube-grid-pos grid x y) (lava-tube-grid-pos grid (add1 x) y))])]
        [else #t]))

(define (lava-tube-grid-is-local-min? grid x y)
    (and
        (lava-tube-grid-less-than-dir? grid x y up)
        (lava-tube-grid-less-than-dir? grid x y left)
        (lava-tube-grid-less-than-dir? grid x y down)
        (lava-tube-grid-less-than-dir? grid x y right)))

(module+ test
    (define expected-mins (list (list 1 0) (list 9 0) (list 2 2) (list 6 4)))

    (check-expect (list->set(lava-tube-grid-local-mins test-grid)) (list->set expected-mins)))

(define (lava-tube-grid-local-mins grid)
    (filter
        (lambda (pos)
            (lava-tube-grid-is-local-min? grid (first pos) (second pos)))
        (cartesian-product
            (range 0 (lava-tube-grid-width grid) 1)
            (range 0 (lava-tube-grid-height grid) 1))))

(module+ test
    (check-expect (lava-tube-risk-lvl-sum test-grid) 15))

(define (lava-tube-risk-lvl-sum grid)
    (foldl
        (lambda (pos cum-sum)
            (+ (add1 (lava-tube-grid-pos grid (first pos) (last pos))) cum-sum))
        0
        (lava-tube-grid-local-mins grid)))

(module+ main
    (define input-file "2021/day9/input.txt")

    (lava-tube-risk-lvl-sum(create-lava-tub-grid input-file)))

(module+ test
    (test))