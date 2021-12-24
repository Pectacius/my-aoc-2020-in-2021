#lang racket

(define problem-input-path "2021/day6/input.txt")

(define normal-cycle-days 7)
(define first-cycle-days (+ normal-cycle-days 2))
(define total-days 256)
(define start-day 0)

(define-struct fish (timer-val day-created)
    #:transparent)

(module+ test
    (require test-engine/racket-tests))



(define (find-all-direct-offspring given-fish)
    (let ([first-day (+ (fish-day-created given-fish) (fish-timer-val given-fish) 1)])
        (map
            (lambda (day-created)
                (make-fish (sub1 first-cycle-days) day-created))
            (range first-day (add1 total-days) normal-cycle-days))))

(module+ test
    (define initial-fish
        (list
            (make-fish 3 0)
            (make-fish 4 0)
            (make-fish 3 0)
            (make-fish 1 0)
            (make-fish 2 0)))
        (check-expect (find-all-fish initial-fish) 26984457539))

(define (find-all-fish initial-fish-list)
    ; Adds a new key value pair to the fish list. Creates a new map instead of mutating the original
    (define (add-new-key fish-map fish-val num-desc)
        (make-hash (cons (cons fish-val num-desc) (hash->list fish-map))))

    ; fish-map contains the mapping for the number of descendents of each fish. Number does not count
    ; the fish being mapped
    (define (find-num-descendants curr-fish fish-map)
        (cond
            [(hash-has-key? fish-map curr-fish) (list (hash-ref fish-map curr-fish) fish-map)]
            [else
                (let ([direct-offspring (find-all-direct-offspring curr-fish)])
                    (cond
                        [(empty? direct-offspring) (list 0 (add-new-key fish-map curr-fish 0))]
                        [else
                            (match-let (
                                [(list count updated-map)
                                (foldl
                                    (lambda (offspring curr-data)
                                        (match-let* (
                                            [(list curr-count curr-map) curr-data]
                                            [(list desc-count new-map) (find-num-descendants offspring curr-map)]                                        )
                                            (list (+ 1 desc-count curr-count) new-map)))
                                    (list 0 fish-map)
                                    direct-offspring)])
                                (list count (add-new-key updated-map curr-fish count)))]))]))
    (first (foldl
        (lambda (offspring curr-data)
            (match-let* (
                [(list curr-count curr-map) curr-data]
                [(list desc-count new-map) (find-num-descendants offspring curr-map)]                                        )
                (list (+ 1 desc-count curr-count) new-map)))
        (list 0 (make-hash empty))
        initial-fish-list)))


(define (parse-input file-path)
    (define delimiter ",")
    (map
        (lambda (timer-val)
            (make-fish (string->number timer-val) start-day))
        (string-split (first(file->lines file-path)) delimiter)))

(module+ test
    (test))

(module+ main
    (find-all-fish(parse-input problem-input-path)))
