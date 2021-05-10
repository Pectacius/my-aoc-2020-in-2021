use std::fs;
use std::io::BufReader;
use std::io::prelude::*;

fn main() {
    let f = fs::File::open("joltage.txt").expect("Unable to open file");
    let f = BufReader::new(f);
    let mut iter = f.lines();

    let mut input: Vec<i32> = Vec::new();

    loop {
        match iter.next() {
            Some(val) => {
                let curr_line = val.unwrap();
                if curr_line == "" {
                    break;
                }
                let value = curr_line.parse::<i32>().unwrap();
                input.push(value);
            },
            None => {
                break;
            }
        }
    }

    let mut delta_one = 0;
    let mut delta_three = 1; // last one always has a difference of 3

    input.sort();

    // check difference of first one from baseline of 0
    let first = input[0];
    if first == 1 {
        delta_one += 1;
    }
    if first == 3 {
        delta_three += 1;
    }

    // check the rest
    for i in 0..(input.len()-1) {
        let first = input[i];
        let second = input[i+1];
        let diff = second - first;
        if diff == 1 {
            delta_one += 1;
        }
        if diff == 3 {
            delta_three += 1;
        }
    }

    println!("Product of differences: {}", delta_one*delta_three);
}
