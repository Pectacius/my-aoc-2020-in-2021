#lang racket

(require "pt1.rkt")

(define (show-letters folded-paper)
    (let* (
        [width (first (argmax first (hash-keys folded-paper)))]
        [height (second (argmax second (hash-keys folded-paper)))])
        (map
        (lambda (y)
            (display (map
                (lambda (x)
                    (if (hash-has-key? folded-paper (list x y))  "\u25A0" "\u25A1"))
                (range 0 (add1 width) 1))) (display "\n"))
        (range 0 (add1 height) 1))))


(module+ main
    (define problem-input "2021/day13/input.txt")
    (define input-str-list (file->lines problem-input))
    (define paper-lines
        (filter
            (lambda (str)
                (and (not (equal? str "")) (not (string-prefix? str "f"))))
            input-str-list))
    (define ins-lines
        (filter
            (lambda (str)
                (string-prefix? str "f"))
            input-str-list))

    (define ins-list (parse-ins ins-lines))
    (define paper (build-paper paper-lines))

    (define folded-paper
        (foldl (lambda (curr-ins curr-paper) (fold-paper curr-paper curr-ins)) paper ins-list))


    (show-letters folded-paper))