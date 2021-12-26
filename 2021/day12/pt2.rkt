#lang racket

(require "pt1.rkt")

(define start "start")
(define end "end")

(define (is-valid-to-visit? vertex visited-so-far-map)
        (cond
            [(equal? vertex start) (equal? (hash-ref visited-so-far-map vertex) 0)]
            [(equal? vertex end) (equal? (hash-ref visited-so-far-map vertex) 0)]
            [(is-all-lowercase? vertex)
                (let ([times-visited (hash-ref visited-so-far-map vertex)])
                    (cond
                        [(equal? times-visited 0) #t]
                        [(equal? times-visited 1)
                            (andmap
                                (lambda (curr-key) (< (hash-ref visited-so-far-map curr-key) 2))
                                (filter is-all-lowercase? (hash-keys visited-so-far-map)))]
                        [(equal? times-visited 2) #f]))]
            [else #t]))

(define (is-all-lowercase? str)
    (equal? str (string-downcase str)))

(define (build-visited-count-map graph)
    (foldl (lambda (curr-key curr-hash) (hash-set curr-hash curr-key 0)) (hash) (hash-keys graph)))

(define (increase-visit-count visit-count-map vertex)
    (let ([curr-count (hash-ref visit-count-map vertex)])
        (hash-set visit-count-map vertex (add1 curr-count))))

(module+ test

    (require test-engine/racket-tests)


    (define test-graph
        (build-cave-graph
            (list
                "start-A"
                "start-b"
                "A-c"
                "A-b"
                "b-d"
                "A-end"
                "b-end")))

    (check-expect (length (cave-graph-paths-to-exit test-graph)) 36)

    (test))

(define (cave-graph-paths-to-exit graph)
    (define (find-paths vertex path-so-far visited-map)
        (let ([curr-path-so-far (cons vertex path-so-far)]
              [updated-visited (increase-visit-count visited-map vertex)]
              [adj-vert (set->list (hash-ref graph vertex))])
        (cond
            [(equal? vertex end) (list (reverse curr-path-so-far))]
            [(not (is-valid-to-visit? vertex visited-map)) empty]
            [else
                (foldl
                    (lambda (curr-vert valid-paths)
                        (append valid-paths (find-paths curr-vert curr-path-so-far updated-visited)))
                    empty
                    adj-vert)])))
    (find-paths start empty (build-visited-count-map graph)))

(module+ main
    (define input-file "2021/day12/input.txt")
    (define caves (build-cave-graph (file->lines input-file)))

    (length (cave-graph-paths-to-exit caves)))