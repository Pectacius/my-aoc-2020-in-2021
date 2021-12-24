#lang racket

(define problem-input-path "2021/day6/input.txt")

(define normal-cycle-days 7)
(define first-cycle-days (+ normal-cycle-days 2))
(define total-days 80)
(define start-day 0)

(define-struct fish (timer-val day-created)
    #:transparent)

(module+ test
    (require test-engine/racket-tests))

(module+ test
    (define test-fish (make-fish 3 0))
    (define expected-direct-offspring
        (list
            (make-fish 8 4)
            (make-fish 8 11)
            (make-fish 8 18)
            (make-fish 8 25)
            (make-fish 8 32)
            (make-fish 8 39)
            (make-fish 8 46)
            (make-fish 8 53)
            (make-fish 8 60)
            (make-fish 8 67)
            (make-fish 8 74)))
    (check-expect (find-all-direct-offspring test-fish) expected-direct-offspring))
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
        (check-expect (find-all-fish initial-fish) 5934))

(define (find-all-fish initial-fish-list)
    (define (find-all curr-fish-count fish-to-find)
        (let ([direct-offspring (flatten (map find-all-direct-offspring fish-to-find))])
            (cond
                [(empty? direct-offspring) curr-fish-count]
                [else (find-all (+ curr-fish-count (length direct-offspring)) direct-offspring)])))
    (find-all (length initial-fish-list) initial-fish-list))


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