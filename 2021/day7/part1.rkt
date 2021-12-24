#lang racket

(define problem-input-file "2021/day7/input.txt")

; The total amount of fuel denoted f_tot = \sum_{i = 1}{N}|pos_i - target|
; Minimize by differentiating in with respect to target and setting it to zero.
; Note that d|x|/dx = sign(x)
; This gets df_tot/dtarget = \sum_{i = 1}{N}sign(pos_i - target) = 0 => there must be equal amounts
; of pos_i smaller than target and larger than target => target is median of {pos_i}

(define (solve input-str)
    (let* (
        [nums-list (sort (map string->number (string-split input-str ",")) <)]
        [median (find-median nums-list)]
        [floor-avg (floor median)]
        [ceil-avg (ceiling median)])
        (cond
            [(equal? floor-avg ceil-avg)
                (sum-diff nums-list floor-avg)]
            [else
                (min (sum-diff nums-list floor-avg) (sum-diff nums-list ceil-avg))])))

; Median, median({s_i}) is defined to be s_((len+1)/2) if len is odd and (s_(len/2) + s_((s/n)+1))/2
; if len is even
(define (find-median nums-list)
    (let ([len (length nums-list)])
        (cond
            [(equal? (modulo len 2) 0)                          ; is even
                (/ (+ (list-ref nums-list (sub1 (/ len 2))) (list-ref nums-list (/ len 2))) 2)]
            [else                                               ; is odd
                (list-ref nums-list (sub1 (/ (add1 len) 2)))])))

(define (sum-diff nums-list val)
    (foldl (lambda (num curr-sum) (+ (abs (- num val)) curr-sum)) 0 nums-list))


; (solve "16,1,2,0,4,2,7,1,2,14")
(solve (first (file->lines problem-input-file)))