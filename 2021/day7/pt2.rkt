#lang racket

(define problem-input-file "2021/day7/input.txt")

(define (cost-fun nums-list pos)
    (foldl (lambda (num curr-sum) (+ curr-sum (/ (* (abs (- num pos)) (add1 (abs (- num pos)))) 2))) 0 nums-list))

(define (solve input-str)
    (let* (
        [nums-list (sort (map string->number (string-split input-str ",")) <)])
        (argmin values (map (lambda (pos) (cost-fun nums-list pos)) (range (first nums-list) (add1 (last nums-list)) 1)))))

; (solve "16,1,2,0,4,2,7,1,2,14")
(solve (first (file->lines problem-input-file)))