#lang racket

(require racket/match)
(require racket/set)

(define (sort-string str) (list->string (sort (string->list str) char<?)))

(define (string->charset str) (list->set (string->list str)))

(define (find-069 dig-6seg-list dig-8 eg-set bd-set)
    (define (is-zero? char-set)
        (subset? (set-subtract dig-8 char-set) bd-set))

    (define (is-six? char-set)
        (and (not (is-zero? char-set)) (not (is-nine? char-set))))

    (define (is-nine? char-set)
        (subset? (set-subtract dig-8 char-set) eg-set))

    (let (
        [zero (first (filter is-zero? dig-6seg-list))]
        [six (first (filter is-six? dig-6seg-list))]
        [nine (first (filter is-nine? dig-6seg-list))]
    ) (list zero six nine)))

(define (find-235 dig-5seg-list dig-8 c-set e-set)
    (define (is-two? char-set)
        (and (not (is-three? char-set)) (not (is-five? char-set))))

    (define (is-three? char-set)
        (and
            (not (subset? c-set (set-subtract dig-8 char-set)))
            (subset? e-set (set-subtract dig-8 char-set))))

    (define (is-five? char-set)
        (and
            (subset? c-set (set-subtract dig-8 char-set))
            (subset? e-set (set-subtract dig-8 char-set))))

    (let (
        [two (first (filter is-two? dig-5seg-list))]
        [three (first (filter is-three? dig-5seg-list))]
        [five (first (filter is-five? dig-5seg-list))]
    ) (list two three five)))

(define (segment-digit-map scrambled-list)
    (match-let* (
        [digit1
            (string->charset
                (first (filter (lambda (val) (equal? (string-length val) 2)) scrambled-list)))]
        [digit4
            (string->charset
                (first (filter (lambda (val) (equal? (string-length val) 4)) scrambled-list)))]
        [digit7
            (string->charset
                (first (filter (lambda (val) (equal? (string-length val) 3)) scrambled-list)))]
        [digit8
            (string->charset
                (first (filter (lambda (val) (equal? (string-length val) 7)) scrambled-list)))]
        [seg6
            (map
                string->charset
                (filter (lambda (val) (equal? (string-length val) 6)) scrambled-list))]
        [seg5
            (map
                string->charset
                (filter (lambda (val) (equal? (string-length val) 5)) scrambled-list))]
        [bd-set (set-subtract digit4 digit1)]
        [eg-set (set-subtract digit8 digit7 digit4)]
        [(list zero six nine) (find-069 seg6 digit8 eg-set bd-set)]
        [c-set (set-subtract digit8 six)]
        [e-set (set-subtract digit8 nine)]
        [(list two three five) (find-235 seg5 digit8 c-set e-set)])
        (make-hash
            (list
                (cons (list->string(sort (set->list zero) char<?)) 0)
                (cons (list->string(sort (set->list digit1) char<?)) 1)
                (cons (list->string(sort (set->list two) char<?)) 2)
                (cons (list->string(sort (set->list three) char<?)) 3)
                (cons (list->string(sort (set->list digit4) char<?)) 4)
                (cons (list->string(sort (set->list five) char<?)) 5)
                (cons (list->string(sort (set->list six) char<?)) 6)
                (cons (list->string(sort (set->list digit7) char<?)) 7)
                (cons (list->string(sort (set->list digit8) char<?)) 8)
                (cons (list->string(sort (set->list nine) char<?)) 9)))))


(define (decode signal msg)
    (let* (
        [digit-map (segment-digit-map signal)]
        [decoded-list (map (lambda (dig) (hash-ref digit-map (sort-string dig))) msg)]
    ) (foldl (lambda (curr-num cum-sum) (+ (* cum-sum 10) curr-num)) 0 decoded-list)))

(module+ test
    (require test-engine/racket-tests)
    (define test-signal
        (list "acedgfb" "cdfbe" "gcdfa" "fbcad" "dab" "cefabd" "cdfgeb" "eafb" "cagedb" "ab"))
    (define test-msg (list "cdfeb" "fcadb" "cdfeb" "cdbaf"))
    (define test-map (segment-digit-map test-signal))

    (check-expect (hash-ref test-map (sort-string "cagedb")) 0)
    (check-expect (hash-ref test-map (sort-string "ab")) 1)
    (check-expect (hash-ref test-map (sort-string "gcdfa")) 2)
    (check-expect (hash-ref test-map (sort-string "fbcad")) 3)
    (check-expect (hash-ref test-map (sort-string "eafb")) 4)
    (check-expect (hash-ref test-map (sort-string "cdfbe")) 5)
    (check-expect (hash-ref test-map (sort-string "cdfgeb")) 6)
    (check-expect (hash-ref test-map (sort-string "dab")) 7)
    (check-expect (hash-ref test-map (sort-string "acedgfb")) 8)
    (check-expect (hash-ref test-map (sort-string "cefabd")) 9)

    (check-expect (decode test-signal test-msg) 5353)

    (test))

(module+ main
    (define input-file "2021/day8/input.txt")

    (define (parse-input file-path)
        (define delimiter " | ")
        (map (lambda (line) (string-split line delimiter)) (file->lines file-path)))

    (foldl
        +
        0
        (map
            (lambda (signal-msg)
                (decode (string-split (first signal-msg)) (string-split (last signal-msg))))
            (parse-input input-file))))