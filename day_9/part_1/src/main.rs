use std::fs;
use std::io::BufReader;
use std::io::prelude::*;
use std::collections::HashSet;
use std::iter::FromIterator;


fn main() {
    // This is literally "copy pasta" coding when it comes to parse
    // the input file as it has literally been the same for the last
    // 8 days... but I want each problem to be independent of each other.
    let f = fs::File::open("day_9/XMAS.txt").expect("Unable to open file");
    let f = BufReader::new(f);
    let mut iter = f.lines();

    let mut input: Vec<u64> = Vec::new();

    loop {
        match iter.next() {
            Some(val) => {
                let curr_line = val.unwrap();
                if curr_line == "" {
                    break;
                }
                let value = curr_line.parse::<u64>().unwrap();
                input.push(value);
            },
            None => {
                break;
            }
        }
    }

    let start_index: usize = 25;

    for i in start_index..input.len() {
        let prev = &input[i-start_index..i];
        //assert!(prev.len() == 25);
        let value = input[i];
        if !contains_sum(value, prev) {
            println!("Number: {}", value);
            break;
        }
    }
}

fn contains_sum(val: u64, entries: &[u64]) -> bool {
    let set: HashSet<u64> = HashSet::from_iter(entries.iter().cloned());
    for i in entries.iter() {
        if val >= *i {
            let diff = val - i;
            // filter out same value pair
            if diff != val {
                if set.contains(&diff) {
                    return true;
                }
            }
        }
    }
    false
}
