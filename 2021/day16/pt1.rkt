#lang racket

(provide hex-string->bin-list bin-list->number remove-number-bits)

(module+ test
    (require test-engine/racket-tests)

    (define test-val1 13827624)
    (define test-hex-str1 "D2FE28")
    (define test-bin-list1
        (list 1 1 0 1   0 0 1 0   1 1 1 1   1 1 1 0   0 0 1 0   1 0 0 0))

    (define test-val2 15763076597486080)
    (define test-hex-str2 "38006F45291200")
    (define test-bin-list2
        (list 0 0 1 1   1 0 0 0   0 0 0 0   0 0 0 0   0 1 1 0   1 1 1 1   0 1 0 0
              0 1 0 1   0 0 1 0   1 0 0 1   0 0 0 1   0 0 1 0   0 0 0 0   0 0 0 0))

    (define test-val3 66991955200061536)
    (define test-hex-str3 "EE00D40C823060")
    (define test-bin-list3
        (list 1 1 1 0   1 1 1 0   0 0 0 0   0 0 0 0   1 1 0 1   0 1 0 0   0 0 0 0
              1 1 0 0   1 0 0 0   0 0 1 0   0 0 1 1   0 0 0 0   0 1 1 0   0 0 0 0)))

(define (hex-digit->binary hex-dig)
    (define hex-bin-map
        (hash
            "0" (list 0 0 0 0)
            "1" (list 0 0 0 1)
            "2" (list 0 0 1 0)
            "3" (list 0 0 1 1)
            "4" (list 0 1 0 0)
            "5" (list 0 1 0 1)
            "6" (list 0 1 1 0)
            "7" (list 0 1 1 1)
            "8" (list 1 0 0 0)
            "9" (list 1 0 0 1)
            "A" (list 1 0 1 0)
            "B" (list 1 0 1 1)
            "C" (list 1 1 0 0)
            "D" (list 1 1 0 1)
            "E" (list 1 1 1 0)
            "F" (list 1 1 1 1)))
    (hash-ref hex-bin-map hex-dig))

(define (hex-string->bin-list hex-str)
    (foldl
        (lambda (curr-str curr-bin-list)
            (append curr-bin-list (hex-digit->binary curr-str)))
        (list)
        (map string (string->list hex-str))))

(module+ test
    (check-expect (hex-string->bin-list test-hex-str1) test-bin-list1)
    (check-expect (hex-string->bin-list test-hex-str2) test-bin-list2)
    (check-expect (hex-string->bin-list test-hex-str3) test-bin-list3))

(define (bin-list->number bin-list)
    (foldl
        (lambda (curr-bit curr-sum)
            (+ (arithmetic-shift curr-sum 1) curr-bit))
        0 bin-list))

(module+ test
    (check-expect (bin-list->number test-bin-list1) test-val1)
    (check-expect (bin-list->number test-bin-list2) test-val2)
    (check-expect (bin-list->number test-bin-list3) test-val3))


; Assumes that the list of bits is never empty and always starts with the digit one
; and will contain a 5 bit sequence that starts with zero.
; Gives the remaining string without the number value bits
(define (remove-number-bits bin-list)
    (cond
        [(equal? (first bin-list) 0) (list-tail bin-list 5)]
        [else (remove-number-bits (list-tail bin-list 5))]))

(module+ test
    (check-expect (remove-number-bits
        (list 1 0 1 1 1   1 1 1 1 0   0 0 1 0 1   0 0 0))
        (list 0 0 0)))


; Parses the list of binary digits until empty. Assumes that the packets use up all the
; entries in the list
(define (parse-bin-to-empty bin-list)
    (cond
        [(empty? bin-list) 0]
        [else
            (match-let ([(list remaining ver-sum) (parse-packet bin-list)])
                (+ ver-sum (parse-bin-to-empty remaining)))]))

(module+ test
    (check-expect (parse-bin-to-empty empty) 0)

    (check-expect
        (parse-bin-to-empty (list 1 1 0 1 0 0 0 1 0 1 0 0 1 0 1 0 0 1 0 0 0 1 0 0 1 0 0))
        8)

    (check-expect
        (parse-bin-to-empty
            (list 0 1 0 1 0 0 0 0 0 0 1 1 0 0 1 0 0 0 0 0 1 0 0 0 1 1 0 0 0 0 0 1 1))
        7))

; Will parse n packets out of the bin-list. Assumes that there is at least n packets
; contained in the input. Returns the remaining list that has not been parsed and the sum
; of the packet version of the packets that have been parsed
; -> (list remaining-bin-list version-sum)
(define (parse-bin-n-times bin-list n)
    (cond
        [(equal? n 0) (list bin-list 0)]
        [else
            (match-let*
                ([(list remaining-list partial-sum) (parse-packet bin-list)]
                 [(list final-remaining rest-sum) (parse-bin-n-times remaining-list (sub1 n))])
                (list final-remaining (+ partial-sum rest-sum)))]))

(module+ test
    (check-expect
        (parse-bin-n-times (list 0 1 0 1 1 1 1 0) 0)
        (list (list 0 1 0 1 1 1 1 0) 0))

    (check-expect
        (parse-bin-n-times
            (list 1 1 0 1 0 0 0 1 0 1 0 0 1 0 1 0 0 1 0 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0) 2)
        (list (list 0 0 0 0 0 0 0) 8))

    (check-expect
        (parse-bin-n-times
            (list
                0 1 0 1 0 0 0 0 0 0 1
                1 0 0 1 0 0 0 0 0 1 0
                0 0 1 1 0 0 0 0 0 1 1
                0 0 0 0 0)
            3)
        (list (list 0 0 0 0 0) 7)))

; Assumes that the bin-list forms a valid single packet
; Returns the sum of all versions of all packets contained in this packet and the
; remaining bin-list that was not processed -> (list remaining-bin-list version-sum)
(define (parse-packet bin-list)
    (let ([packet-version
            (bin-list->number (list (first bin-list) (second bin-list) (third bin-list)))]
          [packet-type-id
            (bin-list->number (list (fourth bin-list) (fifth bin-list) (sixth bin-list)))])
        (cond
            [(equal? packet-type-id 4)
                (list (remove-number-bits (list-tail bin-list 6)) packet-version)]
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
                                    (+ (parse-bin-to-empty packet-to-parse) packet-version)))]
                        [else
                            (let-values
                                ([(bit-len curr-remaining-bin)
                                    (split-at (list-tail bin-list 7) 11)])
                                (match-let
                                    ([(list remaining curr-sum)
                                        (parse-bin-n-times
                                            curr-remaining-bin
                                            (bin-list->number bit-len))])
                                    (list remaining (+ curr-sum packet-version))))]))])))

(module+ test
    ; Base case
    (check-expect
        (parse-packet (hex-string->bin-list "D2FE28"))
        (list (list 0 0 0) 6))

    ; Operator cases
    (check-expect
        (parse-packet (hex-string->bin-list "38006F45291200"))
        (list (list 0 0 0 0 0 0 0) 9))

    (check-expect
        (parse-packet (hex-string->bin-list "EE00D40C823060"))
        (list (list 0 0 0 0 0) 14))

    ; General cases
    (check-expect
        (second (parse-packet (hex-string->bin-list "8A004A801A8002F478")))
        16)

    (check-expect
        (second (parse-packet (hex-string->bin-list "620080001611562C8802118E34")))
        12)

    (check-expect
        (second (parse-packet (hex-string->bin-list "C0015000016115A2E0802F182340")))
        23)

    (check-expect
        (second (parse-packet (hex-string->bin-list "A0016C880162017C3686B18A3D4780")))
        31))


(module+ test
    (test))

(module+ main
    (define problem-input "2021/day16/input.txt")
    (second (parse-packet (hex-string->bin-list (first (file->lines problem-input))))))