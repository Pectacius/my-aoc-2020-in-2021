#lang racket

(require "pt1.rkt")

(module+ test
    (require test-engine/racket-tests)

    (define test-seq-rule (parse-input "test.txt"))
    (define test-seq (first test-seq-rule))
    (define test-rule (second test-seq-rule))
    (define test-pair-map (to-pair-map test-seq))

    (check-expect (hash-ref test-pair-map "NN") 1)
    (check-expect (hash-ref test-pair-map "NC") 1)
    (check-expect (hash-ref test-pair-map "CB") 1)

    (define step-1 (apply-rule test-pair-map test-rule))

    (check-expect (hash-ref step-1 "NC") 1)
    (check-expect (hash-ref step-1 "CN") 1)
    (check-expect (hash-ref step-1 "NB") 1)
    (check-expect (hash-ref step-1 "BC") 1)
    (check-expect (hash-ref step-1 "CH") 1)
    (check-expect (hash-ref step-1 "HB") 1)


    (define step-2 (apply-rule step-1 test-rule))

    (check-expect (hash-ref step-2 "NB") 2)
    (check-expect (hash-ref step-2 "BC") 2)
    (check-expect (hash-ref step-2 "CC") 1)
    (check-expect (hash-ref step-2 "CN") 1)
    (check-expect (hash-ref step-2 "BB") 2)
    (check-expect (hash-ref step-2 "CB") 2)
    (check-expect (hash-ref step-2 "BH") 1)
    (check-expect (hash-ref step-2 "HC") 1)


    (define step-10 (apply-rule-n-times test-pair-map test-rule 10))
    (define max-min-step-10 (find-most-least-freq (to-character-count-map step-10 test-seq)))


    (check-expect (first max-min-step-10) 1749)
    (check-expect (second max-min-step-10) 161)


    (test))

(define (apply-rule pair-map rule-map)
    (foldl
        (lambda (curr-key curr-map)
            (cond
                [(hash-has-key? rule-map curr-key)
                    (let* ([num-occur
                                (hash-ref pair-map curr-key)]
                           [rule-char
                                (hash-ref rule-map curr-key)]
                           [first-new-pair
                                (string-append-immutable
                                    (string (string-ref curr-key 0))
                                    rule-char)]
                           [second-new-pair
                                (string-append-immutable
                                    rule-char
                                    (string (string-ref curr-key 1)))]
                           [first-new-pair-curr-count
                                (if (hash-has-key? curr-map first-new-pair)
                                    (hash-ref curr-map first-new-pair)
                                    0)]
                           [second-new-pair-curr-count
                                (if (hash-has-key? curr-map second-new-pair)
                                    (hash-ref curr-map second-new-pair)
                                    0)])
                        (hash-set* curr-map
                            first-new-pair (+ num-occur first-new-pair-curr-count)
                            second-new-pair (+ num-occur second-new-pair-curr-count)))]
                [else
                    (hash-set curr-map curr-key (hash-ref pair-map curr-key))]))
        (hash)
        (hash-keys pair-map)))

(define (apply-rule-n-times pair-map rule-map times)
    (foldl
        (lambda (curr-idx curr-pair-map)
            (apply-rule curr-pair-map rule-map))
        pair-map
        (range 0 times 1)))

(define (to-character-count-map pair-map orig-seq)
    (let*
        ([initial-map
            (foldl
            (lambda (curr-key curr-char-map)
                (let ([curr-char (string (string-ref curr-key 0))]
                      [curr-count (hash-ref pair-map curr-key)])
                    (cond
                        [(hash-has-key? curr-char-map curr-char)
                            (hash-set curr-char-map
                                curr-char
                                (+ curr-count (hash-ref curr-char-map curr-char)))]
                        [else (hash-set curr-char-map curr-char curr-count)])))
        (hash)
        (hash-keys pair-map))]
        [last-char (vector-ref orig-seq (sub1 (vector-length orig-seq)))]
        [last-char-count (if (hash-has-key? initial-map last-char) (hash-ref initial-map last-char) 0)])
            (hash-set initial-map last-char (add1 last-char-count))))

(define (find-most-least-freq char-count-map)
    (let ([char-count-list (hash-values char-count-map)])
        (list (argmax values char-count-list) (argmin values char-count-list))))

(define (to-pair-map str-seq)
    (foldl
        (lambda (curr-idx curr-map)
            (let ([curr-pair
                    (string-append-immutable
                        (vector-ref str-seq curr-idx)
                        (vector-ref str-seq (add1 curr-idx)))])
                (cond
                    [(hash-has-key? curr-map curr-pair)
                        (hash-set curr-map curr-pair (add1 (hash-ref curr-map curr-pair)))]
                    [else (hash-set curr-map curr-pair 1)])))
        (hash)
        (range 0 (sub1 (vector-length str-seq)) 1)))

(module+ main
    (define input-file "2021/day14/input.txt")

    (define seq-rule (parse-input input-file))
    (define seq (first seq-rule))
    (define rule (second seq-rule))
    (define pair-map (to-pair-map seq))

    (define step-40 (apply-rule-n-times pair-map rule 40))
    (define max-min-step-40 (find-most-least-freq (to-character-count-map step-40 seq)))

    (- (first max-min-step-40) (second max-min-step-40)))
