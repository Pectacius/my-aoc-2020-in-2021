#lang racket

(define input-file "2021/day8/input.txt")

(define segment-to-digit (make-hash (list (cons 2 1) (cons 4 4) (cons 3 7) (cons 7 8))))

(define (parse-output-vals input-file-path)
    (define delimiter " | ")
    (map (lambda (str) (string-split (last (string-split str delimiter)))) (file->lines input-file-path)))

(define (count-easy-digits output-list)
    (foldl
        (lambda (curr-output curr-sum)
            (+ curr-sum
                (foldl
                    (lambda (output partial-sum)
                        (cond
                            [(hash-has-key? segment-to-digit (string-length output))
                                (add1 partial-sum )]
                            [else partial-sum]))
                    0
                    curr-output)))
        0
        output-list))

(module+ main
    (count-easy-digits (parse-output-vals input-file)))