#lang racket

(require "pt1.rkt")

(define cost-map
    (make-hash
        (list
            (cons close-paren-1 1)
            (cons close-paren-2 2)
            (cons close-paren-3 3)
            (cons close-paren-4 4))))

(define (matching-closing-cost token)
    (cond
        [(equal? token open-paren-1) (hash-ref cost-map close-paren-1)]
        [(equal? token open-paren-2) (hash-ref cost-map close-paren-2)]
        [(equal? token open-paren-3) (hash-ref cost-map close-paren-3)]
        [(equal? token open-paren-4) (hash-ref cost-map close-paren-4)]))

(define (remove-matching token-list)
    (define (reduce-paren curr-stack remaining-tokens)
        (cond
            [(empty? remaining-tokens) curr-stack]
            [(is-closing? (first remaining-tokens))
                (cond
                    [(is-matching-pair? (first curr-stack) (first remaining-tokens))
                        (reduce-paren (rest curr-stack) (rest remaining-tokens))]
                    [else empty])] ; This branch should technically never be hit
            [else
                (reduce-paren (cons (first remaining-tokens) curr-stack) (rest remaining-tokens))]))
    (reduce-paren empty token-list))

(module+ test
    (require test-engine/racket-tests)

    (check-expect (completion-cost (map string (string->list "[({(<(())[]>[[{[]{<()<>>"))) 288957)

    (check-expect (completion-cost (map string (string->list "[(()[<>])]({[<{<<[]>>("))) 5566)

    (check-expect (completion-cost (map string (string->list "(((({<>}<{<{<>}{[]{[]{}"))) 1480781)

    (check-expect (completion-cost (map string (string->list "{<[[]]>}<{[{[{[]{()[[[]"))) 995444)

    (check-expect (completion-cost (map string (string->list "<{([{{}}[<[[[<>{}]]]>[]]"))) 294)

    (test))

(define (completion-cost token-list)
    (define scaling-const 5)
    (foldl
        (lambda (curr-val cum-sum) (+ (* scaling-const cum-sum) curr-val))
        0
        (map matching-closing-cost (remove-matching token-list))))

(define (find-imcomplete lines-list)
    (filter (lambda (curr-line) (equal? (find-error-cost curr-line) 0)) lines-list))

(module+ main
    (define input-file "2021/day10/input.txt")
    (define completion-cost-list
        (sort (map completion-cost (find-imcomplete (parse-input input-file))) <))

    (list-ref completion-cost-list (sub1 (/ (add1 (length completion-cost-list)) 2))))