#lang racket

(provide parse-input)

(module+ test
    (require test-engine/racket-tests)

    (define test-seq-rule (parse-input "test.txt"))
    (define test-seq (first test-seq-rule))
    (define test-rule (second test-seq-rule))

    (define step-1 (apply-rule test-seq test-rule))
    (check-expect
        step-1
        (vector-immutable "N" "C" "N" "B" "C" "H" "B"))

    (define step-2 (apply-rule step-1 test-rule))
    (check-expect
        step-2
        (vector-immutable "N" "B" "C" "C" "N" "B" "B" "B" "C" "B" "H" "C" "B"))

    (define step-3 (apply-rule step-2 test-rule))
    (check-expect
        step-3
        (vector-immutable
            "N" "B" "B" "B" "C" "N" "C" "C" "N" "B" "B" "N"
            "B" "N" "B" "B" "C" "H" "B" "H" "H" "B" "C" "H" "B"))

    (define step-4 (apply-rule step-3 test-rule))
    (check-expect
        step-4
        (vector-immutable
            "N" "B" "B" "N" "B" "N" "B" "B" "C" "C" "N" "B"
            "C" "N" "C" "C" "N" "B" "B" "N" "B" "B" "N" "B"
            "B" "B" "N" "B" "B" "N" "B" "B" "C" "B" "H" "C"
            "B" "H" "H" "N" "H" "C" "B" "B" "C" "B" "H" "C" "B"))


    (define step-10 (apply-rule-n test-seq test-rule 10))
    (define max-min-step-10 (find-most-least-freq step-10))

    (check-expect (vector-length step-10) 3073)
    (check-expect (first max-min-step-10) 1749)
    (check-expect (second max-min-step-10) 161)

    (test))

(define (apply-rule str-seq rule-map)
    (define (insert-pattern curr-seq idx)
        (cond
            [(>= idx (sub1 (vector-length curr-seq))) curr-seq] ; No more possible places to match
            [else
                (let
                    ([curr-pat
                        (string-append-immutable
                            (vector-ref curr-seq idx)
                            (vector-ref curr-seq (add1 idx)))])
                    (cond
                        [(hash-has-key? rule-map curr-pat)
                            (let
                                ([front (vector-take curr-seq (add1 idx))]
                                [back (vector-drop curr-seq (add1 idx))])
                                (insert-pattern
                                    (vector-append front (vector-immutable (hash-ref rule-map curr-pat)) back)
                                    (+ 2 idx)))]
                        [else (insert-pattern curr-seq (add1 idx))]))]))

    (insert-pattern str-seq 0))

(define (apply-rule-n str-seq rule-map n)
    (foldl
        (lambda (iter-count curr-str-seq) (apply-rule curr-str-seq rule-map))
        str-seq
        (range 0 n)))

(define (find-most-least-freq str-seq)
    (let* ([char-count-map
        (foldl
            (lambda (curr-char curr-map)
                (let ([new-amount
                    (if (hash-has-key? curr-map curr-char)
                        (add1 (hash-ref curr-map curr-char)) 1)])
                        (hash-set curr-map curr-char new-amount)))
            (hash)
            (vector->list str-seq))]
            [char-count-list (hash-values char-count-map)])
            (list (argmax values char-count-list) (argmin values char-count-list))))

(define (parse-input file-name)
    (let* ([all-lines (file->lines file-name)]
        [str-seq
            (vector->immutable-vector (list->vector (map string (string->list (first all-lines)))))])
        (list
            str-seq
            (foldl
                (lambda (curr-line curr-map)
                    (match-let ([(list rule res) (string-split curr-line " -> ")])
                        (hash-set curr-map rule res)))
                (hash)
                (rest (rest all-lines))))))

(module+ main
    (define input-file "2021/day14/input.txt")

    (define seq-rule (parse-input input-file))
    (define seq (first seq-rule))
    (define rule (second seq-rule))

    (define step-10 (apply-rule-n seq rule 10))
    (define max-min-step-10 (find-most-least-freq step-10))

    (- (first max-min-step-10) (second max-min-step-10)))