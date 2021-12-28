#lang racket

(require "pt1.rkt")

(module+ test
    (require test-engine/racket-tests))

; Assumes that the list of bits is never empty and always starts with the digit one
; and will contain a 5 bit sequence that starts with zero.
; Gives the remaining string without the number value bits and the number that is
; encoded in decimal
; -> (list remaining-bin-list decimal-number)
(define (parse-number bin-list)
    (define (extract-digits curr-bin-list curr-bin-num)
        (cond
            [(equal? (first curr-bin-list) 0)
                (list
                    (list-tail curr-bin-list 5)
                    (append
                        curr-bin-num
                        (take (rest curr-bin-list) 4)))]
            [else
                (let*-values
                    ([(curr-bits remaining-bits)
                        (split-at curr-bin-list 5)])
                    (extract-digits
                        remaining-bits
                        (append curr-bin-num (rest curr-bits))))]))

    (match-let
        ([(list unparsed-bin-list dec-num) (extract-digits bin-list empty)])
        (list unparsed-bin-list (bin-list->number dec-num))))


(module+ test
    (check-expect
        (parse-number (list 1 0 1 1 1  1 1 1 1 0  0 0 1 0 1  0 0 0))
        (list (list 0 0 0) 2021)))



(define (apply-operator op-num values-list)
    (match op-num
        [0 (foldl + 0 values-list)]
        [1 (foldl * 1 values-list)]
        [2 (argmin values values-list)]
        [3 (argmax values values-list)]
        [5 (if (> (first values-list) (second values-list)) 1 0)]
        [6 (if (< (first values-list) (second values-list)) 1 0)]
        [7 (if (equal? (first values-list) (second values-list)) 1 0)]))

(module+ test
    ; op 0
    (check-expect (apply-operator 0 (list 0 0 0)) 0)
    (check-expect (apply-operator 0 (list 1 2 3)) 6)
    (check-expect (apply-operator 0 (list 1)) 1)

    ; op 1
    (check-expect (apply-operator 1 (list 0 3 2)) 0)
    (check-expect (apply-operator 1 (list 2 3 4)) 24)
    (check-expect (apply-operator 1 (list 1)) 1)
    (check-expect (apply-operator 1 (list 0)) 0)

    ; op 2
    (check-expect (apply-operator 2 (list 0 0 0)) 0)
    (check-expect (apply-operator 2 (list 1 2 3)) 1)
    (check-expect (apply-operator 2 (list 1)) 1)
    (check-expect (apply-operator 2 (list 4 5 8 1 2 0)) 0)

    ; op 3
    (check-expect (apply-operator 3 (list 0 0 0)) 0)
    (check-expect (apply-operator 3 (list 1 2 3)) 3)
    (check-expect (apply-operator 3 (list 1)) 1)
    (check-expect (apply-operator 3 (list 4 5 8 1 2 0)) 8)

    ; op 5
    (check-expect (apply-operator 5 (list 0 1)) 0)
    (check-expect (apply-operator 5 (list 1 1)) 0)
    (check-expect (apply-operator 5 (list 2 1)) 1)

    ; op 6
    (check-expect (apply-operator 6 (list 0 1)) 1)
    (check-expect (apply-operator 6 (list 1 1)) 0)
    (check-expect (apply-operator 6 (list 2 1)) 0)

    ; op 7
    (check-expect (apply-operator 7 (list 0 1)) 0)
    (check-expect (apply-operator 7 (list 1 1)) 1)
    (check-expect (apply-operator 7 (list 2 1)) 0))

; Evaluates the list of binary digits until empty. Returns
; all the packets evaluated as a list. Assumes that the packets use all
; the entires in the list
; -> (list args...)
(define (evaluate-args-to-empty bin-list)
    (cond
        [(empty? bin-list) empty]
        [else
            (match-let ([(list remaining eval-val) (evaluate-packet bin-list)])
                (cons eval-val (evaluate-args-to-empty remaining)))]))

(module+ test
    (check-expect (evaluate-args-to-empty empty) empty)

    (check-expect
        (evaluate-args-to-empty (list 1 1 0 1 0 0 1 0 1 1 1 1 1 1 1 0 0 0 1 0 1))
        (list 2021))

    (check-expect
        (evaluate-args-to-empty (list 1 1 0 1 0 0 0 1 0 1 0 0 1 0 1 0 0 1 0 0 0 1 0 0 1 0 0))
        (list 10 20))

    (check-expect
        (evaluate-args-to-empty
            (list 0 1 0 1 0 0 0 0 0 0 1 1 0 0 1 0 0 0 0 0 1 0 0 0 1 1 0 0 0 0 0 1 1))
        (list 1 2 3)))

; Will parse n packets out of the bin-list into a list.
; Assumes that there is at least n packets
; contained in the input. Returns the remaining list that has not been parsed and the sum
; of the packet version of the packets that have been parsed
; -> (list remaining-bin-list (list evaluated-list ...))
(define (evaluate-bin-n-times bin-list n)
    (cond
        [(equal? n 0) (list bin-list empty)]
        [else
            (match-let*
                ([(list remaining-list curr-arg) (evaluate-packet bin-list)]
                 [(list final-remaining rest-args) (evaluate-bin-n-times remaining-list (sub1 n))])
                 (list final-remaining (cons curr-arg rest-args)))]))

(module+ test
    (check-expect
        (evaluate-bin-n-times (list 0 1 0 1 1 1 1 0) 0)
        (list (list 0 1 0 1 1 1 1 0) empty))

    (check-expect
        (evaluate-bin-n-times
            (list 1 1 0 1 0 0 0 1 0 1 0 0 1 0 1 0 0 1 0 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0) 2)
        (list (list 0 0 0 0 0 0 0) (list 10 20)))

    (check-expect
        (evaluate-bin-n-times
            (list
                0 1 0 1 0 0 0 0 0 0 1
                1 0 0 1 0 0 0 0 0 1 0
                0 0 1 1 0 0 0 0 0 1 1
                0 0 0 0 0)
            3)
        (list (list 0 0 0 0 0) (list 1 2 3))))


; Assumes that the bin-list forms a valid single packet
; Returns the evaluation of all packets contained in this packet and the
; remaining bin-list that was not processed
; -> (list remaining-bin-list evaluated-result)
(define (evaluate-packet bin-list)
    (let ([packet-version
            (bin-list->number (list (first bin-list) (second bin-list) (third bin-list)))]
          [packet-type-id
            (bin-list->number (list (fourth bin-list) (fifth bin-list) (sixth bin-list)))])
        (cond
            [(equal? packet-type-id 4)
                (parse-number (list-tail bin-list 6))]
            [else
                (let ([packet-len-type-id (seventh bin-list)])
                    (cond
                        [(equal? packet-len-type-id 0)
                            (let*-values
                                ([(bit-len curr-remaining-bin)
                                    (split-at (list-tail bin-list 7) 15)]
                                 [(packet-to-parse remaining)
                                    (split-at curr-remaining-bin (bin-list->number bit-len))])
                                (list
                                    remaining
                                    (apply-operator packet-type-id (evaluate-args-to-empty packet-to-parse))))]
                        [else
                            (let-values
                                ([(bit-len curr-remaining-bin)
                                    (split-at (list-tail bin-list 7) 11)])
                                (match-let
                                    ([(list remaining curr-args)
                                        (evaluate-bin-n-times
                                            curr-remaining-bin
                                            (bin-list->number bit-len))])
                                    (list remaining (apply-operator packet-type-id curr-args))))]))])))


(module+ test
    ; Number case
    (check-expect
        (evaluate-packet (hex-string->bin-list "D2FE28"))
        (list (list 0 0 0) 2021))

    ; Operator cases
    (check-expect
        (evaluate-packet (hex-string->bin-list "38006F45291200"))
        (list (list 0 0 0 0 0 0 0) 1))

    (check-expect
        (evaluate-packet (hex-string->bin-list "EE00D40C823060"))
        (list (list 0 0 0 0 0) 3))

    ; General cases
    (check-expect
        (second (evaluate-packet (hex-string->bin-list "C200B40A82")))
        3)

    (check-expect
        (second (evaluate-packet (hex-string->bin-list "04005AC33890")))
        54)

    (check-expect
        (second (evaluate-packet (hex-string->bin-list "880086C3E88112")))
        7)

    (check-expect
        (second (evaluate-packet (hex-string->bin-list "CE00C43D881120")))
        9)

    (check-expect
        (second (evaluate-packet (hex-string->bin-list "D8005AC2A8F0")))
        1)

    (check-expect
        (second (evaluate-packet (hex-string->bin-list "F600BC2D8F")))
        0)

    (check-expect
        (second (evaluate-packet (hex-string->bin-list "9C005AC2F8F0")))
        0)

    (check-expect
        (second (evaluate-packet (hex-string->bin-list "9C0141080250320F1802104A08")))
        1))

(module+ test
    (test))

(module+ main
    (define problem-input "2021/day16/input.txt")
    (second (evaluate-packet (hex-string->bin-list (first (file->lines problem-input))))))