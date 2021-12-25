# my-aoc
My AOC 2020 solutions

## 2021
Completed with Racket.

Each subfolder is one separate question and is meant to be able to run in isolation from other questions.

The solution for each day and part is given a specific name in the format of `day<day_number>/pt<part_number>.rkt`. For example,
to run the solution for Day 6 part 1, `racket 2021/day6/pt1.rkt`.

Most solutions for each day and part have unit-tests which can be run via `raco test day<day_number>/pt<part_number>.rkt`.

## 2020
Completed with Rust

Each subfolder is one separate question and is meant to be able to run in isolation from other questions.

Running `cargo build` will build all binaries for all the days and parts

Each day and part is given a specific name in the format of `day_<day number>_part_<part number>`. For example, if I wanted to run the solution for Day 10 Part 1, `cargo run day_10_part_2`.

Preferably, each binary should be built in the top level directory instead of their own respective folders as it may cause some issues when looking for the input file.