#lang racket

(provide
    build-paper
    fold-paper
    parse-ins)

(define x-dir 0)
(define y-dir 1)

(struct fold-instruction (dir pos) #:transparent)


(define (build-paper pos-list)
    (foldl
        (lambda (pos curr-map)
            (hash-set curr-map (map string->number (string-split pos ",")) 1))
        (hash)
        pos-list))

(module+ test
    (require test-engine/racket-tests)

    (define test-paper
        (build-paper
            (list
                "6,10"
                "0,14"
                "9,10"
                "0,3"
                "10,4"
                "4,11"
                "6,0"
                "6,12"
                "4,1"
                "0,13"
                "10,12"
                "3,4"
                "3,0"
                "8,4"
                "1,10"
                "2,14"
                "8,10"
                "9,0")))

    (check-expect (length (hash-keys (fold-paper test-paper (fold-instruction 1 7)))) 17)

    (test))

(define (fold-paper paper ins)
    (let
        ([dir (fold-instruction-dir ins)]
         [line-to-fold (fold-instruction-pos ins)])
        (cond
            [(equal? dir x-dir)
                (let* (
                    [dots-to-flip (filter (lambda (pos) (> (first pos) line-to-fold)) (hash-keys paper))]
                    [new-paper (foldl (lambda (pos curr-paper) (hash-remove curr-paper pos)) paper dots-to-flip)])
                    (foldl
                        (lambda (pos curr-paper)
                            (match-let*
                                ([(list x y) pos] [dis-from-line (- x line-to-fold)])
                                (hash-set curr-paper (list (- line-to-fold dis-from-line) y) 1)))
                        new-paper
                        dots-to-flip))]
            [else
                (let* (
                    [dots-to-flip (filter (lambda (pos) (> (second pos) line-to-fold)) (hash-keys paper))]
                    [new-paper (foldl (lambda (pos curr-paper) (hash-remove curr-paper pos)) paper dots-to-flip)])
                    (foldl
                        (lambda (pos curr-paper)
                            (match-let*
                                ([(list x y) pos] [dis-from-line (- y line-to-fold)])
                                (hash-set curr-paper (list x (- line-to-fold dis-from-line)) 1)))
                        new-paper
                        dots-to-flip))])))

(define (parse-ins ins-list)
    (map
        (lambda (str)
            (match-let
                ([(list dir amount) (string-split (first (string-split str "fold along ")) "=")])
                (fold-instruction (if (equal? dir "x") x-dir y-dir) (string->number amount))))
        ins-list))

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

    (length (hash-keys (fold-paper paper (first ins-list)))))