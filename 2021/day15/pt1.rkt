#lang racket

(provide
    very-large-num
    find-neighbours
    make-cavern
    cavern cavern-width cavern-height cavern-weights-vec cavern-neighbour-vec)

(module+ test
    (require test-engine/racket-tests))

(define very-large-num (sub1 (expt 2 63)))

(struct cavern (neighbour-vec weights-vec width height))

; Test make-cavern
(module+ test
    (define small-cavern (make-cavern "small.txt"))

    (check-expect (cavern-weights-vec small-cavern)
        (vector-immutable 3 4 6 7 2 8 1 2 4 5 1 3))
    (check-expect (cavern-width small-cavern) 4)
    (check-expect (cavern-height small-cavern) 3)

    (check-expect (vector-ref (cavern-neighbour-vec small-cavern) 0) (list 4 1))
    (check-expect (vector-ref (cavern-neighbour-vec small-cavern) 1) (list 0 5 2))
    (check-expect (vector-ref (cavern-neighbour-vec small-cavern) 2) (list 1 6 3))
    (check-expect (vector-ref (cavern-neighbour-vec small-cavern) 3) (list 2 7))
    (check-expect (vector-ref (cavern-neighbour-vec small-cavern) 4) (list 8 5 0))
    (check-expect (vector-ref (cavern-neighbour-vec small-cavern) 5) (list 4 9 6 1))
    (check-expect (vector-ref (cavern-neighbour-vec small-cavern) 6) (list 5 10 7 2))
    (check-expect (vector-ref (cavern-neighbour-vec small-cavern) 7) (list 6 11 3))
    (check-expect (vector-ref (cavern-neighbour-vec small-cavern) 8) (list 9 4))
    (check-expect (vector-ref (cavern-neighbour-vec small-cavern) 9) (list 8 10 5))
    (check-expect (vector-ref (cavern-neighbour-vec small-cavern) 10) (list 9 11 6))
    (check-expect (vector-ref (cavern-neighbour-vec small-cavern) 11) (list 10 7)))

(define (make-cavern input-file)
    (let* ([input-lines (file->lines input-file)]
           [height (length input-lines)]
           [width (string-length (first input-lines))]
           [weights
                (vector->immutable-vector (list->vector
                    (flatten (map
                        (lambda (curr-line)
                            (map
                                (lambda (curr-char)
                                    (string->number(string curr-char)))
                                (string->list curr-line)))
                        input-lines))))]
            [neighbours
                (vector->immutable-vector
                    (vector-map
                        (lambda (idx)
                            (find-neighbours idx width height))
                        (build-vector (vector-length weights) values)))])
          (cavern neighbours weights width height)))

(define (find-neighbours idx width height)
    (let ([x-pos (modulo idx width)]
          [y-pos (exact-floor(/ idx width))])
        (foldl
            (lambda (curr-pos curr-neighbours)
                (match-let ([(list x y) curr-pos])
                    (cond
                        [(and (<= 0 x) (< x width) (<= 0 y) (< y height))
                            (cons (+ (* width y) x) curr-neighbours)]
                        [else curr-neighbours])))
            empty
            (list
                (list x-pos (sub1 y-pos))
                (list (add1 x-pos) y-pos)
                (list x-pos (add1 y-pos))
                (list (sub1 x-pos) y-pos)))))

(module+ test
    (check-expect (find-smallest-vertex (hash 21 3 34 1 2 56 9 8) (set 34 2 9)) 34)
    (check-expect (find-smallest-vertex (hash 1 2 3 4 5 6 7 8 9 0) (set 3 5 1)) 1))

(define (find-smallest-vertex dist-map vertex-set)
    (argmin
        (lambda (curr-elem)
            (hash-ref dist-map curr-elem))
        (set->list vertex-set)))

(module+ test
    (define initialize-top-left (initialize-dikjstra small-cavern 0))
    (define top-left-dist (first initialize-top-left))
    (define top-left-prev (second initialize-top-left))
    (define top-left-vert (third initialize-top-left))

    (check-expect
        top-left-dist
        (hash
            0  0
            1  very-large-num
            2  very-large-num
            3  very-large-num
            4  very-large-num
            5  very-large-num
            6  very-large-num
            7  very-large-num
            8  very-large-num
            9  very-large-num
            10 very-large-num
            11 very-large-num))

    (check-expect
        top-left-prev
        (hash
            0  -1
            1  -1
            2  -1
            3  -1
            4  -1
            5  -1
            6  -1
            7  -1
            8  -1
            9  -1
            10 -1
            11 -1))

    (check-expect top-left-vert (set 0 1 2 3 4 5 6 7 8 9 10 11))

    (define initialize-bottom-right (initialize-dikjstra small-cavern 11))
    (define bot-right-dist (first initialize-bottom-right))
    (define bot-right-prev (second initialize-bottom-right))
    (define bot-right-vert (third initialize-bottom-right))

    (check-expect
        bot-right-dist
        (hash
            0  very-large-num
            1  very-large-num
            2  very-large-num
            3  very-large-num
            4  very-large-num
            5  very-large-num
            6  very-large-num
            7  very-large-num
            8  very-large-num
            9  very-large-num
            10 very-large-num
            11 0))

    (check-expect
        bot-right-prev
        (hash
            0  -1
            1  -1
            2  -1
            3  -1
            4  -1
            5  -1
            6  -1
            7  -1
            8  -1
            9  -1
            10 -1
            11 -1))

    (check-expect bot-right-vert (set 0 1 2 3 4 5 6 7 8 9 10 11)))

(define (initialize-dikjstra given-cavern source)
    (match-let (
        [(list dist-map prev-map vert-set)
            (foldl
                (lambda (curr-vert curr-data)
                    (match-let
                        ([(list curr-dist-map curr-prev-map curr-vert-set) curr-data])
                        (list
                            (hash-set curr-dist-map curr-vert very-large-num)
                            (hash-set curr-prev-map curr-vert -1)
                            (set-add curr-vert-set curr-vert))))
                    (list (hash) (hash) (set))
                    (range
                        0
                        (* (cavern-width given-cavern) (cavern-height given-cavern))
                        1))])
        (list (hash-set dist-map source 0) prev-map vert-set)))

(module+ test
    (define test-cavern (make-cavern "test.txt"))
    (define source 0)
    (define dest 99)

    (define shortest (find-shortest-path test-cavern source dest))

    (check-expect (hash-ref (first shortest) dest) 40))

(define (find-shortest-path given-cavern source dest)

    (define (dikjstra dist-map prev-map vertex-set)
        (cond
            [(set-empty? vertex-set)
                (list dist-map prev-map)]
            [else
                (let* (
                    [shortest-vertex (find-smallest-vertex dist-map vertex-set)]
                    [updated-vertex-set (set-remove vertex-set shortest-vertex)])
                    (cond
                        [(equal? shortest-vertex dest) (list dist-map prev-map)]
                        [else
                            (match-let
                                ([(list updated-dist updated-prev)
                                    (foldl
                                        (lambda (neigh curr-data)
                                            (match-let*
                                                ([(list curr-dist curr-prev)
                                                    curr-data]
                                                 [alt
                                                    (+ (hash-ref curr-dist shortest-vertex) (vector-ref (cavern-weights-vec given-cavern) neigh))])
                                                (if (< alt (hash-ref curr-dist neigh)) (list (hash-set curr-dist neigh alt) (hash-set curr-prev neigh shortest-vertex)) curr-data)))
                                        (list dist-map prev-map)
                                        (filter
                                            (lambda (curr-neighbour)
                                                (set-member?
                                                    updated-vertex-set
                                                    curr-neighbour))
                                            (vector-ref
                                                (cavern-neighbour-vec given-cavern)
                                                shortest-vertex)))])
                                (dikjstra updated-dist updated-prev updated-vertex-set))]))]))

    (match-let
        ([(list dist-map prev-map vert-set) (initialize-dikjstra given-cavern source)])
        (dikjstra dist-map prev-map vert-set)))

(module+ test
    (test))

(module+ main
    (define problem-input "2021/day15/input.txt")
    (define problem-cavern (make-cavern problem-input))
    (define source 0)
    (define dest (sub1 (* (cavern-height problem-cavern) (cavern-width problem-cavern))))

    (define shortest (find-shortest-path problem-cavern source dest))

    (hash-ref (first shortest) dest))