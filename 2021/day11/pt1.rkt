#lang racket

(provide
    excited-state ground-state
    energy-lvl-grid create-energy-lvl-grid energy-lvl-grid-entries
    energy-lvl-grid-propogate-to-steady-state energy-lvl-grid-flash)

(define excited-state 9)
(define ground-state 0)

(module+ test
    (require test-engine/racket-tests)

    (define test-grid (create-energy-lvl-grid "test.txt"))
    (define med-test-grid (create-energy-lvl-grid "med-test.txt"))
    (define small-test-grid (create-energy-lvl-grid "small-test.txt")))

(struct energy-lvl-grid (entries width) #:transparent)

(define (create-energy-lvl-grid file-name)
    (let* (
        [all-lines (file->lines file-name)]
        [width (string-length (first all-lines))]
        [parsed-entries
            (flatten
                (map
                    (lambda (curr-line)
                        (map
                            (lambda (curr-char)
                                (string->number (string curr-char)))
                            (string->list curr-line)))
                all-lines))])
        (energy-lvl-grid (vector->immutable-vector (list->vector parsed-entries)) width)))

(module+ test
    (check-expect (energy-lvl-grid-get-pos test-grid 1 1) 7)
    (check-expect (energy-lvl-grid-get-pos test-grid 9 9) 6)
    (check-expect (energy-lvl-grid-get-pos test-grid 2 3) 4))

; Assumes that coordinate (x, y) is in bounds
(define (energy-lvl-grid-get-pos grid x y)
    (vector-ref (energy-lvl-grid-entries grid) (+ (* (energy-lvl-grid-width grid) y) x)))

(module+ test
    (check-expect (energy-lvl-grid-idx->pos small-test-grid 0) (list 0 0))
    (check-expect (energy-lvl-grid-idx->pos small-test-grid 1) (list 1 0))
    (check-expect (energy-lvl-grid-idx->pos small-test-grid 2) (list 2 0))
    (check-expect (energy-lvl-grid-idx->pos small-test-grid 3) (list 0 1))
    (check-expect (energy-lvl-grid-idx->pos small-test-grid 4) (list 1 1))
    (check-expect (energy-lvl-grid-idx->pos small-test-grid 5) (list 2 1))
    (check-expect (energy-lvl-grid-idx->pos small-test-grid 6) (list 0 2))
    (check-expect (energy-lvl-grid-idx->pos small-test-grid 7) (list 1 2))
    (check-expect (energy-lvl-grid-idx->pos small-test-grid 8) (list 2 2)))

(define (energy-lvl-grid-idx->pos grid idx)
    (let* (
        [width (energy-lvl-grid-width grid)]
        [x (modulo idx width)]
        [y (exact-floor(/ idx width))])
        (list x y)))

(module+ test
    (check-expect (energy-lvl-grid-pos->idx small-test-grid (list 0 0)) 0)
    (check-expect (energy-lvl-grid-pos->idx small-test-grid (list 1 0)) 1)
    (check-expect (energy-lvl-grid-pos->idx small-test-grid (list 2 0)) 2)
    (check-expect (energy-lvl-grid-pos->idx small-test-grid (list 0 1)) 3)
    (check-expect (energy-lvl-grid-pos->idx small-test-grid (list 1 1)) 4)
    (check-expect (energy-lvl-grid-pos->idx small-test-grid (list 2 1)) 5)
    (check-expect (energy-lvl-grid-pos->idx small-test-grid (list 0 2)) 6)
    (check-expect (energy-lvl-grid-pos->idx small-test-grid (list 1 2)) 7)
    (check-expect (energy-lvl-grid-pos->idx small-test-grid (list 2 2)) 8))

(define (energy-lvl-grid-pos->idx grid pos)
    (let (
        [x (first pos)]
        [y (last pos)])
        (+ (* (energy-lvl-grid-width grid) y) x)))

(module+ test
    (define new-small-test (energy-lvl-grid-set-pos small-test-grid 2 1 9))

    (check-expect (energy-lvl-grid-get-pos new-small-test 0 0) 1)
    (check-expect (energy-lvl-grid-get-pos new-small-test 1 0) 2)
    (check-expect (energy-lvl-grid-get-pos new-small-test 2 0) 6)
    (check-expect (energy-lvl-grid-get-pos new-small-test 0 1) 3)
    (check-expect (energy-lvl-grid-get-pos new-small-test 1 1) 6)
    (check-expect (energy-lvl-grid-get-pos new-small-test 2 1) 9)
    (check-expect (energy-lvl-grid-get-pos new-small-test 0 2) 7)
    (check-expect (energy-lvl-grid-get-pos new-small-test 1 2) 8)
    (check-expect (energy-lvl-grid-get-pos new-small-test 2 2) 5)

    (check-expect (energy-lvl-grid-width new-small-test) (energy-lvl-grid-width small-test-grid)))

; New grid where index is at specified val
(define (energy-lvl-grid-set-pos grid x y val)
    (let* (
        [total-len (vector-length (energy-lvl-grid-entries grid))]
        [target-idx (+ (* (energy-lvl-grid-width grid) y) x)]
        [new-entries
            (map
                (lambda (idx)
                    (if (equal? idx target-idx) val (vector-ref (energy-lvl-grid-entries grid) idx)))
                (range 0 total-len 1))])
        (energy-lvl-grid
            (vector->immutable-vector (list->vector new-entries))
            (energy-lvl-grid-width grid))))

(module+ test
    (define increase-small-test (energy-lvl-grid-increase-state small-test-grid))

    (check-expect (energy-lvl-grid-get-pos increase-small-test 0 0) 2)
    (check-expect (energy-lvl-grid-get-pos increase-small-test 1 0) 3)
    (check-expect (energy-lvl-grid-get-pos increase-small-test 2 0) 7)
    (check-expect (energy-lvl-grid-get-pos increase-small-test 0 1) 4)
    (check-expect (energy-lvl-grid-get-pos increase-small-test 1 1) 7)
    (check-expect (energy-lvl-grid-get-pos increase-small-test 2 1) 1)
    (check-expect (energy-lvl-grid-get-pos increase-small-test 0 2) 8)
    (check-expect (energy-lvl-grid-get-pos increase-small-test 1 2) 9)
    (check-expect (energy-lvl-grid-get-pos increase-small-test 2 2) 6)

    (check-expect (energy-lvl-grid-width increase-small-test) (energy-lvl-grid-width small-test-grid)))

(define (energy-lvl-grid-increase-state grid)
    (struct-copy
        energy-lvl-grid
        grid
        [entries
            (vector->immutable-vector (vector-map add1 (energy-lvl-grid-entries grid)))]))

(module+ test
    (define reseted-grid
        (energy-lvl-grid-reset-excited (energy-lvl-grid-increase-state increase-small-test)))

    (check-expect (energy-lvl-grid-get-pos reseted-grid 0 0) 3)
    (check-expect (energy-lvl-grid-get-pos reseted-grid 1 0) 4)
    (check-expect (energy-lvl-grid-get-pos reseted-grid 2 0) 8)
    (check-expect (energy-lvl-grid-get-pos reseted-grid 0 1) 5)
    (check-expect (energy-lvl-grid-get-pos reseted-grid 1 1) 8)
    (check-expect (energy-lvl-grid-get-pos reseted-grid 2 1) 2)
    (check-expect (energy-lvl-grid-get-pos reseted-grid 0 2) 9)
    (check-expect (energy-lvl-grid-get-pos reseted-grid 1 2) 0)
    (check-expect (energy-lvl-grid-get-pos reseted-grid 2 2) 7)

    (check-expect (energy-lvl-grid-width reseted-grid) (energy-lvl-grid-width small-test-grid)))

(define (energy-lvl-grid-reset-excited grid)
    (struct-copy
        energy-lvl-grid
        grid
        [entries
            (vector->immutable-vector
                (vector-map
                    (lambda (val) (if (> val excited-state) ground-state val))
                    (energy-lvl-grid-entries grid)))]))

(module+ test
    (check-expect
        (energy-lvl-grid-neighbours small-test-grid 0)
        (list 1 4 3))
    (check-expect
        (energy-lvl-grid-neighbours small-test-grid 1)
        (list 2 5 4 3 0))
    (check-expect
        (energy-lvl-grid-neighbours small-test-grid 2)
        (list 5 4 1))
    (check-expect
        (energy-lvl-grid-neighbours small-test-grid 3)
        (list 0 1 4 7 6))
    (check-expect
        (energy-lvl-grid-neighbours small-test-grid 4)
        (list 1 2 5 8 7 6 3 0))
    (check-expect
        (energy-lvl-grid-neighbours small-test-grid 5)
        (list 2 8 7 4 1))
    (check-expect
        (energy-lvl-grid-neighbours small-test-grid 6)
        (list 3 4 7))
    (check-expect
        (energy-lvl-grid-neighbours small-test-grid 7)
        (list 4 5 8 6 3))
    (check-expect
        (energy-lvl-grid-neighbours small-test-grid 8)
        (list 5 7 4)))

(define (energy-lvl-grid-neighbours grid idx)
    (define (valid-pos x y)
        (let (
            [height
                (/ (vector-length (energy-lvl-grid-entries grid)) (energy-lvl-grid-width grid))])
            (if (and (<= 0 x) (< x (energy-lvl-grid-width grid)) (<= 0 y) (< y height))
                (list x y)
                empty)))

    (match-let
        ([(list x y) (energy-lvl-grid-idx->pos grid idx)])
        (map
            (lambda (pos)
                (energy-lvl-grid-pos->idx grid pos))
            (filter-not empty?
                (list
                    (valid-pos x (sub1 y))                  ; N
                    (valid-pos (add1 x) (sub1 y))           ; NE
                    (valid-pos (add1 x) y)                  ; E
                    (valid-pos (add1 x) (add1 y))           ; SE
                    (valid-pos x (add1 y))                  ; S
                    (valid-pos (sub1 x) (add1 y))           ; SW
                    (valid-pos (sub1 x) y)                  ; W
                    (valid-pos (sub1 x) (sub1 y)))))))      ; NW

(module+ test
    (check-expect
        (energy-lvl-grid-entries (energy-lvl-grid-propogate med-test-grid empty))
        (energy-lvl-grid-entries med-test-grid))
    (check-expect
        (energy-lvl-grid-entries
            (energy-lvl-grid-propogate
                med-test-grid
                (list 2 5 3 21 9 2 1 3)))
        (vector-immutable 1 2 3 3 1 2 9 9 9 2 1 9 1 9 1 1 9 9 9 1 1 2 1 1 1)))

(define (energy-lvl-grid-propogate grid prop-idx-list)
    (let ([data (energy-lvl-grid-entries grid)])
        (struct-copy
            energy-lvl-grid
            grid
            [entries
                (foldl
                    (lambda (idx curr-grid)
                        (vector->immutable-vector
                            (vector-map
                                (lambda (curr-idx)
                                    (if (equal? curr-idx idx)
                                        (add1 (vector-ref curr-grid curr-idx))
                                        (vector-ref curr-grid curr-idx)))
                                (build-vector (vector-length curr-grid) values))))
                data
                prop-idx-list)])))

(module+ test
    (check-expect
        (to-flash-idx (energy-lvl-grid-increase-state med-test-grid) (set))
        (list 6 7 8 11 13 16 17 18))
    (check-expect
        (to-flash-idx (energy-lvl-grid-increase-state med-test-grid) (set 1 3 6 8 18))
        (list 7 11 13 16 17)))

(define (to-flash-idx grid flashed-idx-set)
    (filter
        (lambda (idx)
            (and
                (> (vector-ref (energy-lvl-grid-entries grid) idx) excited-state)
                (not (set-member? flashed-idx-set idx))))
        (range 0 (vector-length (energy-lvl-grid-entries grid)) 1)))

(define (energy-lvl-grid-propogate-to-steady-state grid prop-idx-list flashed-idx-set flash-sum)
    (let* (
        [prop-grid (energy-lvl-grid-propogate grid prop-idx-list)]
        [to-flash-idx-list (to-flash-idx prop-grid flashed-idx-set)]
        [new-prop-idx-set ; Indicies to propogate next. Note not (x, y) coordinate
            (foldl
                (lambda (idx curr-neighbours)
                        (append curr-neighbours (energy-lvl-grid-neighbours prop-grid idx)))
                empty
                to-flash-idx-list)]
        [new-flashed-idx-set (set-union (list->set to-flash-idx-list) flashed-idx-set)])
        (cond
            [(empty? to-flash-idx-list) (list prop-grid flash-sum flashed-idx-set)]
            [else
                (energy-lvl-grid-propogate-to-steady-state
                    prop-grid
                    new-prop-idx-set
                    new-flashed-idx-set
                    (+ (length to-flash-idx-list) flash-sum))])))

(module+ test
    (define single-med-flash (energy-lvl-grid-flash med-test-grid))
    (check-expect (second single-med-flash) 9)
    (check-expect
        (energy-lvl-grid-entries (first single-med-flash))
        (vector-immutable 3 4 5 4 3 4 0 0 0 4 5 0 0 0 5 4 0 0 0 4 3 4 5 4 3))


    (define flash-1 (energy-lvl-grid-flash test-grid))
    (check-expect (second flash-1) 0))

(define (energy-lvl-grid-flash grid)
    (match-let
        ([(list new-grid total-flash flashed-set)
            (energy-lvl-grid-propogate-to-steady-state
                (energy-lvl-grid-increase-state grid)
                empty
                (set)
                0)])
        (list (energy-lvl-grid-reset-excited new-grid) total-flash)))

(module+ test
    (define flash-10 (energy-lvl-grid-flash-n-times test-grid 10))
    (check-expect (second flash-10) 204)
    (check-expect
        (energy-lvl-grid-entries (first flash-10))
        (vector-immutable
            0 4 8 1 1 1 2 9 7 6
            0 0 3 1 1 1 2 0 0 9
            0 0 4 1 1 1 2 5 0 4
            0 0 8 1 1 1 1 4 0 6
            0 0 9 9 1 1 1 3 0 6
            0 0 9 3 5 1 1 2 3 3
            0 4 4 2 3 6 1 1 3 0
            5 5 3 2 2 5 2 3 5 0
            0 5 3 2 2 5 0 6 0 0
            0 0 3 2 2 4 0 0 0 0)))

(define (energy-lvl-grid-flash-n-times grid n)
    (foldl
        (lambda (iter-num curr-val)
            (match-let* (
                [(list curr-grid curr-flash) curr-val]
                [(list update-grid flash-count) (energy-lvl-grid-flash curr-grid)])
                (list update-grid (+ curr-flash flash-count))))
        (list grid 0)
        (range 0 n 1)))

(module+ main
    (define problem-input "2021/day11/input.txt")
    (second (energy-lvl-grid-flash-n-times (create-energy-lvl-grid problem-input) 100)))

(module+ test
    (test))