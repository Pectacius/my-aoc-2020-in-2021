#lang racket

(provide build-cave-graph)

(module+ test
    (require test-engine/racket-tests))

(module+ test
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

    (check-expect (hash-ref test-graph "start") (set "A" "b"))
    (check-expect (hash-ref test-graph "A") (set "start" "b" "c" "end"))
    (check-expect (hash-ref test-graph "b") (set "start" "A" "d" "end"))
    (check-expect (hash-ref test-graph "c") (set "A"))
    (check-expect (hash-ref test-graph "d") (set "b"))
    (check-expect (hash-ref test-graph "end") (set "A" "b")))

; Each edge is given as a string in the form of vertA-vertB. The - character seperates the names
; of the two verticies
(define (build-cave-graph edges-list)
    (define (add-edge graph vert1 vert2)
        (let* (
            [vert1-dirs (if (hash-has-key? graph vert1) (hash-ref graph vert1) (set))]
            [vert2-dirs (if (hash-has-key? graph vert2) (hash-ref graph vert2) (set))]
            [new-vert1-dirs (set-add vert1-dirs vert2)]
            [new-vert2-dirs (set-add vert2-dirs vert1)])
            (hash-set* graph vert1 new-vert1-dirs vert2 new-vert2-dirs)))

    (foldl
        (lambda (curr-edge curr-graph)
            (match-let (
                [(list vert1 vert2) (string-split curr-edge "-")])
                (add-edge curr-graph
                    (string->immutable-string vert1)
                    (string->immutable-string vert2))))
        (hash)
        edges-list))

(module+ test
    (define expected-paths
        (list
            (list "start" "A" "b" "A" "c" "A" "end")
            (list "start" "A" "b" "A" "end")
            (list "start" "A" "b" "end")
            (list "start" "A" "c" "A" "b" "A" "end")
            (list "start" "A" "c" "A" "b" "end")
            (list "start" "A" "c" "A" "end")
            (list "start" "A" "end")
            (list "start" "b" "A" "c" "A" "end")
            (list "start" "b" "A" "end")
            (list "start" "b" "end")))

    (check-expect (list->set(cave-graph-paths-to-exit test-graph)) (list->set expected-paths))

    (define small-expected-paths (list (list "start" "end")))
    (define small-graph (build-cave-graph (list "start-end")))

    (check-expect (cave-graph-paths-to-exit small-graph) small-expected-paths)

    (define med-graph (build-cave-graph (list "start-A" "start-b" "A-b" "A-end" "b-end")))
    (define med-expected-paths
        (list
            (list "start" "A" "end")
            (list "start" "b" "end")
            (list "start" "b" "A" "end")
            (list "start" "A" "b" "end")
            (list "start" "A" "b" "A" "end")))

    (check-expect (list->set(cave-graph-paths-to-exit med-graph)) (list->set med-expected-paths)))

(define (cave-graph-paths-to-exit graph)
    (define start "start")
    (define end "end")

    (define (is-valid-to-visit? vertex visited-so-far)
        (not (and (equal? (string-downcase vertex) vertex) (set-member? visited-so-far vertex))))

    (define (find-paths vertex path-so-far visited-set)
        (let ([curr-path-so-far (cons vertex path-so-far)]
              [updated-visited (set-add visited-set vertex)]
              [adj-vert (set->list (hash-ref graph vertex))])
        (cond
            [(equal? vertex end) (list (reverse curr-path-so-far))]
            [(not (is-valid-to-visit? vertex visited-set)) empty]
            [else
                (foldl
                    (lambda (curr-vert valid-paths)
                        (append valid-paths (find-paths curr-vert curr-path-so-far updated-visited)))
                    empty
                    adj-vert)])))
    (find-paths start empty (set)))


(module+ test
    (test))

(module+ main
    (define input-file "2021/day12/input.txt")
    (define caves (build-cave-graph (file->lines input-file)))

    (length (cave-graph-paths-to-exit caves)))