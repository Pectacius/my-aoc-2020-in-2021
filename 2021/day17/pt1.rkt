#lang racket

(module+ test
    (require test-engine/racket-tests))

(provide
    initial-x-pos initial-y-pos
    target target-from-file
    target-left-x target-right-x
    probe-traj-apogee)


(define initial-x-pos 0)
(define initial-y-pos 0)

(struct target (left-x right-x bot-y top-y))

(define (target-from-file file-name)
    (match-let*
        ([data-line (first (file->lines file-name))]
         [data-info (first (string-split data-line "target area: "))]
         [(list x-part y-part) (string-split data-info ", ")]
         [(list left-x right-x) (string-split (string-trim x-part "x=") "..")]
         [(list bot-y top-y) (string-split (string-trim y-part "y=") "..")])
        (target
            (string->number left-x) (string->number right-x)
            (string->number bot-y) (string->number top-y))))

(module+ test
    (define test-target (target-from-file "input.txt"))

    (check-expect (target-left-x test-target) 201)
    (check-expect (target-right-x test-target) 230)
    (check-expect (target-bot-y test-target) -99)
    (check-expect (target-top-y test-target) -65))


(define (target-hit? targ x-pos y-pos)
    (and
        (<= (target-left-x targ) x-pos)
        (<= x-pos (target-right-x targ))
        (<= (target-bot-y targ) y-pos)
        (<= y-pos (target-top-y targ))))

(define (target-cannot-hit? targ x-pos y-pos)
    (or (> x-pos (target-right-x targ)) (< y-pos (target-bot-y targ))))


(define (apply-drag x-vel)
    (define drag-amount 1)
    (cond
        [(positive? x-vel) (- x-vel drag-amount)]
        [(negative? x-vel) (+ x-vel drag-amount)]
        [else x-vel]))

(define (apply-gravity y-vel)
    (define gravity-amount 1)
    (- y-vel gravity-amount))

; Finds the apogee of the trajectory if the trajectory can hit the target
; -> (list can-hit? apogee)
; The value apogee should only be considered if the can-hit? value is true
(define (probe-traj-apogee targ x-pos y-pos x-vel y-vel highest-y-pos)
    (cond
        [(target-cannot-hit? targ x-pos y-pos) (list #f -1)]
        [(target-hit? targ x-pos y-pos) (list #t highest-y-pos)]
        [else
            (let* (
                [new-x-pos (+ x-pos x-vel)]
                [new-y-pos (+ y-pos y-vel)]
                [new-x-vel (apply-drag x-vel)]
                [new-y-vel (apply-gravity y-vel)]
                [new-highest-y-pos (max new-y-pos highest-y-pos)])
                (probe-traj-apogee
                    targ
                    new-x-pos new-y-pos
                    new-x-vel new-y-vel
                    new-highest-y-pos))]))

(module+ test
    (check-expect
        (probe-traj-apogee
            (target 20 30 -10 -5)
            initial-x-pos initial-y-pos
            7 2
            very-small-num)
        (list #t 3))

    (check-expect
        (probe-traj-apogee
            (target 20 30 -10 -5)
            initial-x-pos initial-y-pos
            6 3
            very-small-num)
        (list #t 6))

    (check-expect
        (probe-traj-apogee
            (target 20 30 -10 -5)
            initial-x-pos initial-y-pos
            9 0
            very-small-num)
        (list #t 0))

    (check-expect
        (probe-traj-apogee
            (target 20 30 -10 -5)
            initial-x-pos initial-y-pos
            17 -4
            very-small-num)
        (list #f -1))

    (check-expect
        (probe-traj-apogee
            (target 20 30 -10 -5)
            initial-x-pos initial-y-pos
            6 9
            very-small-num)
        (list #t 45)))


; Note that the maximum initial x-vel must be at most target-right-x as any value greater
; will overshoot. Also note that the way that drag works, velocity_n+1 = velocity_n - 1
; means that the total displacement would be v_1 + v_1 - 1 + v_1 - 2 + ... 0. This implies
; that the maximum possible displacement in the x direction would be the sum from
; 1 to v i.e. (v+1)v/2. This means that if (v+1)v/2 < target-left-x then the probe will
; miss regardless. Thus we can then create a bound on the possible values of x-vel
; based on target-right-x and target-left-x.
;
; Specifically, we want both:
; v < target-right-x
; v(v+1)/2 >= target-left-x
;
; This is can be written as x \in [(-1 + sqrt(1 + 4*2*target-left-x))/2, target-right-x]
;
; Also note that the initial y-vel must be positive. This is because there is always a
; trivial initial condition i.e. x-vel = target-left-x and y-vel = target-top-y which
; produces an apogee of 0. This means any potential maximum must produce an apogee
; greater than zero and any negative initial y-vel will produce an apogee of 0
; There is also an upper bound on the initial y-vel
(define (find-max-apogee targ)
    (define (find-max-given-x x-vel y-vel curr-highest-apogee)
        ; (match-let
        ;     ([(list hit? apogee)
        ;         (probe-traj-apogee targ initial-x-pos initial-y-pos x-vel y-vel 0)])
        ;     (cond
        ;         [(not hit?) curr-highest-apogee]
        ;         [else
        ;             (find-max-given-x x-vel (add1 y-vel) (max curr-highest-apogee apogee))]))
        (foldl (lambda (curr-y-vel curr-max-apogee)
            (match-let
                ([(list hit? apogee)
                    (probe-traj-apogee targ initial-x-pos initial-y-pos x-vel curr-y-vel 0)])
                    (cond
                        [hit? (max apogee curr-max-apogee)]
                        [else curr-max-apogee]))) 0 (range 0 500 1))
        )

    (define min-x-vel (exact-floor (/ (sub1 (sqrt (add1 (* 8 (target-left-x targ))))) 2)))
    (define max-x-vel (target-right-x targ))
    (define min-y-vel 1)


    (foldl
        (lambda (curr-x-vel curr-highest-apogee)
            (let ([max-apogee-for-curr-x
                (find-max-given-x curr-x-vel 1 0)])
            (max max-apogee-for-curr-x curr-highest-apogee)))
        0
        (range min-x-vel (add1 max-x-vel) 1)))

(module+ test
    (check-expect (find-max-apogee (target 20 30 -10 -5)) 45))

(module+ main
    (define problem-input "2021/day17/input.txt")
    (find-max-apogee (target 201 230 -99 -65)))

(module+ test
    (test))