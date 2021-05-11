# my-aoc-2020-in-2021
My AOC 2020 solutions in Rust only using standard library

Each folder is one seperate question and is meant to be able to run in isolation from other questions.

Running `cargo build` will build all binaries for all the days and parts

Each day and part is given a specific name in the format of `day_<day number>_part_<part number>`. For example, If I wanted to run the solution for Day 10 Part 1, `cargo run day_10_part_2`.

Preferably, each binary should be built in the top level directory instead of their own respective folders as it may cause some issues when looking for the input file.