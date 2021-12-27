#lang racket

(require data/heap)
(require "pt1.rkt")

(define max-value 10)

(define (line->number-list given-line)
        (map
            (lambda (curr-char)
                (string->number (string curr-char)))
            (string->list given-line)))

(define (expand-row row n)
    (flatten
        (map
            (lambda (idx)
                (map (lambda (val) (if (> (+ val idx) 9) (+ val idx -9) (+ val idx))) row))
            (range 0 n 1))))

(module+ test
    (require test-engine/racket-tests)

    (define small-cavern (make-cavern-n-times "small.txt" 3))

    (check-expect (cavern-weights-vec small-cavern)
        (vector-immutable
            3 4 6 7  4 5 7 8  5 6 8 9
            2 8 1 2  3 9 2 3  4 1 3 4
            4 5 1 3  5 6 2 4  6 7 3 5

            4 5 7 8  5 6 8 9  6 7 9 1
            3 9 2 3  4 1 3 4  5 2 4 5
            5 6 2 4  6 7 3 5  7 8 4 6

            5 6 8 9  6 7 9 1  7 8 1 2
            4 1 3 4  5 2 4 5  6 3 5 6
            6 7 3 5  7 8 4 6  8 9 5 7
            ))
    (check-expect (cavern-width small-cavern) 12)
    (check-expect (cavern-height small-cavern) 9))


(define (make-cavern-n-times input-file n)
    (let* ([input-lines (file->lines input-file)]
           [height (* n (length input-lines))]
           [width (* n (string-length (first input-lines)))]
           [initial-lines (map line->number-list input-lines)]
           [initial-weights-expanded-widthwise
                (flatten (map (lambda (curr-line) (expand-row curr-line n)) initial-lines))]
            [weights
                (vector->immutable-vector (list->vector
                    (expand-row initial-weights-expanded-widthwise n)))]
            [neighbours
                (vector->immutable-vector
                    (vector-map
                        (lambda (idx)
                            (find-neighbours idx width height))
                        (build-vector (vector-length weights) values)))])
          (cavern neighbours weights width height)))

(struct vertex (vert-num vert-dist))
(define (vertex<=? vert1 vert2)
    (<= (vertex-vert-dist vert1) (vertex-vert-dist vert2)))

(module+ test
    (define test-cavern (make-cavern-n-times "test.txt" 1))
    (define source 0)
    (define dest 99)

    (define shortest (find-shortest-path test-cavern source dest))

    (check-expect (hash-ref (first shortest) dest) 40))

(define (find-shortest-path given-cavern source dest)
    (define (dijkstra dist-map prev-map vertex-queue visited-vertex)
        (cond
            [(equal? (heap-count vertex-queue) 0)
                (list dist-map prev-map)]
            [else
                (let*
                    ([shortest-vertex (vertex-vert-num (heap-min vertex-queue))]
                    [remove-heap (heap-remove-min! vertex-queue)])
                    (cond
                        [(equal? shortest-vertex dest)
                            (list dist-map prev-map)]
                        [(set-member? visited-vertex shortest-vertex)
                            (dijkstra dist-map prev-map vertex-queue visited-vertex)]
                        [else
                            (match-let*
                                ([updated-visited (set-add visited-vertex shortest-vertex)]
                                [(list updated-dist updated-prev)
                                    (foldl
                                        (lambda (neigh curr-data)
                                            (match-let*
                                                ([(list curr-dist curr-prev)
                                                    curr-data]
                                                [alt
                                                    (+
                                                        (hash-ref curr-dist shortest-vertex)
                                                        (vector-ref (cavern-weights-vec given-cavern) neigh))])
                                                (cond
                                                [(< alt (hash-ref curr-dist neigh))
                                                    (heap-add! vertex-queue (vertex neigh alt))
                                                    (list
                                                        (hash-set curr-dist neigh alt)
                                                        (hash-set curr-prev neigh shortest-vertex))]
                                                [else curr-data]

                                                    )))
                                        (list dist-map prev-map)
                                        (vector-ref
                                            (cavern-neighbour-vec given-cavern)
                                            shortest-vertex))])
                                (dijkstra updated-dist updated-prev vertex-queue updated-visited))]))]))

    (define (add-vertex-data curr-vert curr-data)
        (match-let*
            ([(list curr-dist-map curr-prev-map curr-vert-queue) curr-data])
            (cond
                [(equal? curr-vert source)
                    (heap-add! curr-vert-queue (vertex curr-vert 0))
                    (list
                        (hash-set curr-dist-map curr-vert 0)
                        curr-prev-map
                        curr-vert-queue)]
                [else
                    (heap-add! curr-vert-queue (vertex curr-vert very-large-num))
                    (list
                        (hash-set curr-dist-map curr-vert very-large-num)
                        (hash-set curr-prev-map curr-vert -1)
                        curr-vert-queue)])))

    (match-let
        ([(list dist-map prev-map vert-set)
            (foldl add-vertex-data
                (list (hash) (hash) (make-heap vertex<=?))
                (range
                    0
                    (* (cavern-width given-cavern) (cavern-height given-cavern))
                    1))])
        (dijkstra dist-map prev-map vert-set (set))))

(module+ test
    (define bigger-test-cavern (make-cavern-n-times "test.txt" 5))

    (define bigger-shortest
        (find-shortest-path bigger-test-cavern 0 2499))

    (check-expect (hash-ref (first bigger-shortest) 2499) 315))

(module+ test
    (define expanded-cavern (make-cavern "expanded.txt"))

    (check-expect (cavern-weights-vec bigger-test-cavern) (cavern-weights-vec expanded-cavern))

    (define res (find-shortest-path expanded-cavern 0 2499))

    (check-expect (hash-ref (first res) 2499) 315))


(module+ main
    (define problem-input "2021/day15/input.txt")
    (define problem-cavern (make-cavern-n-times problem-input 5))
    (define source 0)
    (define dest (sub1 (* (cavern-height problem-cavern) (cavern-width problem-cavern))))

    (define shortest (find-shortest-path problem-cavern source dest))

    (hash-ref (first shortest) dest)
    )

(module+ test
    (test))
