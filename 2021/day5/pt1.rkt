#lang racket

(define-struct line (start-x start-y end-x end-y)
    #:transparent)

; Determines if the line is horizontal
(define (is-hori? given-line)
    (equal? (line-start-y given-line) (line-end-y given-line)))

; Determines if the line is vertical
(define (is-vert? given-line)
    (equal? (line-start-x given-line) (line-end-x given-line)))

(module+ test
    (require test-engine/racket-tests))

(module+ test
    (check-expect (max-x-width lines-list) 10))

; Determine maximum width of the grid to contain all lines
(define (max-x-width line-list)
    (let ([x-pos-list
            (list->vector
                (flatten (map
                            (lambda (curr-line)
                                (list (line-start-x curr-line) (line-end-x curr-line)))
                            line-list)))])
        (add1 (vector-argmax values x-pos-list))))

; Determines maximum height of the grid to contain all lines
(define (max-y-height line-list)
    (let ([y-pos-list
            (list->vector
                (flatten (map
                            (lambda (curr-line)
                                (list (line-start-y curr-line) (line-end-y curr-line)))
                            line-list)))])
        (add1 (vector-argmax values y-pos-list))))



(module+ test
    (define hori-line-forward (make-line 1 2 1 5))
    (define expected-hori-points-forward (list (list 1 2) (list 1 3) (list 1 4) (list 1 5)))

    (define hori-line-backward (make-line 3 8 3 5))
    (define expected-hori-points-backward (list (list 3 8) (list 3 7) (list 3 6) (list 3 5)))

    (check-expect (create-line-points hori-line-forward) expected-hori-points-forward)
    (check-expect (create-line-points hori-line-backward) expected-hori-points-backward))

(define (create-line-points line-val)
    (cond
        [(is-hori? line-val)
            (let ([step-size (if (< (line-start-x line-val) (line-end-x line-val)) 1 -1)])
                (map
                    (lambda (x)
                        (list x (line-start-y line-val)))
                    (range (line-start-x line-val) (+ (line-end-x line-val) step-size) step-size)))]
        [(is-vert? line-val)
            (let ([step-size (if (< (line-start-y line-val) (line-end-y line-val)) 1 -1)])
                (map
                    (lambda (y)
                        (list (line-start-x line-val) y))
                    (range (line-start-y line-val) (+ (line-end-y line-val) step-size) step-size)))]))

; Marks all points of the line on the grid
; line-val can only be either horizontal or vertical
(define (apply-flat-line line-val grid-val)
    (let ([line-points (create-line-points line-val)])
        (foldl
            (lambda (line-point grid)
                (mark-grid grid (first line-point) (last line-point)))
            grid-val
            line-points)))

(module+ test
    (define expected-blank-grid
        (list
            (list 0 0 0 0 0 0 0 0 0 0)
            (list 0 0 0 0 0 0 0 0 0 0)
            (list 0 0 0 0 0 0 0 0 0 0)
            (list 0 0 0 0 0 0 0 0 0 0)
            (list 0 0 0 0 0 0 0 0 0 0)
            (list 0 0 0 0 0 0 0 0 0 0)
            (list 0 0 0 0 0 0 0 0 0 0)
            (list 0 0 0 0 0 0 0 0 0 0)
            (list 0 0 0 0 0 0 0 0 0 0)
            (list 0 0 0 0 0 0 0 0 0 0)))
    (check-expect (create-marked-grid lines-list) expected-blank-grid))

(define (create-marked-grid line-list)
    (let (
        [height (max-y-height line-list)]
        [width (max-x-width line-list)])
        (build-list
            height
            (lambda (x)
                (build-list width
                    (lambda (y) 0))))))

(module+ test
    (define test-grid
        (list
            (list 0 0 0 0)
            (list 0 0 0 0)
            (list 0 0 0 0)
            (list 0 0 0 0)))
    (define expected-grid
        (list
            (list 0 0 0 0)
            (list 0 0 0 0)
            (list 0 0 0 0)
            (list 0 0 1 0)))
    (check-expect (mark-grid test-grid 2 3) expected-grid))

(define (mark-grid grid x-pos y-pos)
    (map
        (lambda (row y-idx)
            (cond
                [(equal? y-idx y-pos)
                    (map
                        (lambda (entry x-idx)
                            (cond
                                [(equal? x-idx x-pos) (add1 entry)]
                                [else entry]))
                    row (build-list (length row) values))]
                [else row]))
        grid (build-list (length grid) values)))

(module+ test
    (define lines-list
        (list
            (make-line 0 9 5 9)
            (make-line 8 0 0 8)
            (make-line 9 4 3 4)
            (make-line 2 2 2 1)
            (make-line 7 0 7 4)
            (make-line 6 4 2 0)
            (make-line 0 9 2 9)
            (make-line 3 4 1 4)
            (make-line 0 0 8 8)
            (make-line 5 5 8 2)))
    (define expected-marked-grid
        (list
            (list 0 0 0 0 0 0 0 1 0 0)
            (list 0 0 1 0 0 0 0 1 0 0)
            (list 0 0 1 0 0 0 0 1 0 0)
            (list 0 0 0 0 0 0 0 1 0 0)
            (list 0 1 1 2 1 1 1 2 1 1)
            (list 0 0 0 0 0 0 0 0 0 0)
            (list 0 0 0 0 0 0 0 0 0 0)
            (list 0 0 0 0 0 0 0 0 0 0)
            (list 0 0 0 0 0 0 0 0 0 0)
            (list 2 2 2 1 1 1 0 0 0 0)))
    (check-expect (draw-hori-vert-lines lines-list) expected-marked-grid))

(define (draw-hori-vert-lines lines-list)
    (foldl apply-flat-line
        (create-marked-grid lines-list)
        (filter (lambda (curr-line) (or (is-hori? curr-line) (is-vert? curr-line))) lines-list)))


(module+ test
    (check-expect (count-at-least (draw-hori-vert-lines lines-list) 2) 5))

(define (count-at-least grid num)
    (length (filter (lambda (val) (>= val num)) (flatten grid))))

(module+ test
    (test))


(define (parse-input file-name)
    (define line-delimiter " -> ")
    (define coord-delimiter ",")
    (map
        (lambda (file-line)
            (let* (
                [start-end-string (string-split file-line line-delimiter)]
                [start-coord (string-split (first start-end-string) coord-delimiter)]
                [end-coord (string-split (last start-end-string) coord-delimiter)])
                (make-line
                    (string->number (first start-coord))
                    (string->number (last start-coord))
                    (string->number (first end-coord))
                    (string->number (last end-coord)))))
        (file->lines file-name)))

(define problem-input "2021/day5/input.txt")
(define threshold 2)

(module+ main
    (count-at-least (draw-hori-vert-lines (parse-input problem-input)) threshold))

