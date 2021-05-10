use std::fs;
use std::io::BufReader;
use std::io::prelude::*;

mod questions;

fn main() {
    let f = fs::File::open("questions.txt").expect("Unable to open file");
    let f = BufReader::new(f);

    let mut sum = 0;

    let mut curr_value: String = "".to_owned();

    let mut iter = f.lines();

    loop {
        match iter.next() {
            Some(val) => {
                let curr_line = val.unwrap();
                if curr_line == "" {
                    let new_question = questions::Questions::new(&curr_value);
                    curr_value = "".to_owned();
                    sum += new_question.num_of_questions();
                }
                else {
                    curr_value.push_str(&curr_line);
                }
            },
            None => {
                let new_question = questions::Questions::new(&curr_value);
                sum += new_question.num_of_questions();
                break;
            }
        }
    }
    println!("sum: {}", sum);
}
