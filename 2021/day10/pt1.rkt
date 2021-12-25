#lang racket

(provide
    open-paren-1 open-paren-2 open-paren-3 open-paren-4
    close-paren-1 close-paren-2 close-paren-3 close-paren-4
    find-error-cost
    is-closing?
    is-matching-pair?
    parse-input)

(define open-paren-1 "(")
(define open-paren-2 "[")
(define open-paren-3 "{")
(define open-paren-4 "<")

(define close-paren-1 ")")
(define close-paren-2 "]")
(define close-paren-3 "}")
(define close-paren-4 ">")

(define error-costs
    (make-hash
        (list
            (cons close-paren-1 3)
            (cons close-paren-2 57)
            (cons close-paren-3 1197)
            (cons close-paren-4 25137))))

(module+ test
    (require test-engine/racket-tests))

(define (is-closing? token)
    (or
        (equal? token close-paren-1)
        (equal? token close-paren-2)
        (equal? token close-paren-3)
        (equal? token close-paren-4)))

(define (is-matching-pair? open-tok close-tok)
    (or
        (and (equal? open-tok open-paren-1) (equal? close-tok close-paren-1))
        (and (equal? open-tok open-paren-2) (equal? close-tok close-paren-2))
        (and (equal? open-tok open-paren-3) (equal? close-tok close-paren-3))
        (and (equal? open-tok open-paren-4) (equal? close-tok close-paren-4))))

(module+ test
    (check-expect (find-error-cost (map string (string->list "{([(<{}[<>[]}>{[]{[(<()>"))) 1197)

    (check-expect (find-error-cost (map string (string->list "[[<[([]))<([[{}[[()]]]"))) 3)

    (check-expect (find-error-cost (map string (string->list "[{[{({}]{}}([{[{{{}}([]"))) 57)

    (check-expect (find-error-cost (map string (string->list "[<(<(<(<{}))><([]([]()"))) 3)

    (check-expect (find-error-cost (map string (string->list "<{([([[(<>()){}]>(<<{{"))) 25137))

(define (find-error-cost token-list)
    (define (check-paren curr-stack remaining-tokens)
        (cond
            [(empty? remaining-tokens) 0]
            [(is-closing? (first remaining-tokens))
                (cond
                    [(is-matching-pair? (first curr-stack) (first remaining-tokens))
                        (check-paren (rest curr-stack) (rest remaining-tokens))]
                    [else (hash-ref error-costs (first remaining-tokens))])]
            [else
                (check-paren (cons (first remaining-tokens) curr-stack) (rest remaining-tokens))]))
    (check-paren empty token-list))

(define (parse-input input-file)
    (map (lambda (curr-line) (map string (string->list curr-line))) (file->lines input-file)))

(module+ main
    (define input-file "2021/day10/input.txt")
    (foldl + 0 (map find-error-cost (parse-input input-file))))

(module+ test
    (test))