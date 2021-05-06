use std::fs;
use std::io::BufReader;
use std::io::prelude::*;

mod questions;

fn main() {
    let f = fs::File::open("small.txt").expect("Unable to open file");
    let f = BufReader::new(f);

    let mut sum = 0;

    let mut curr_question = questions::Questions::new();

    let mut iter = f.lines();

    loop {
        match iter.next() {
            Some(val) => {
                let curr_line = val.unwrap();
                if curr_line == "" {
                    sum += curr_question.num_of_similar();
                    curr_question = questions::Questions::new();
                }
                else {
                    curr_question.add_person(&curr_line);
                }
            },
            None => {
                sum += curr_question.num_of_similar();
                break;
            }
        }
    }
    println!("sum: {}", sum);
}
