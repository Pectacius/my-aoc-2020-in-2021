use std::collections::HashSet;
use std::iter::FromIterator;
use input_parser;


fn main() {
    let result = input_parser::read_line_input(9, "XMAS".to_string());

    match result {
        Some(value) => {
            
            let mut input: Vec<u64> = Vec::new();

            for i in value {
                let num = i.parse::<u64>().unwrap();
                input.push(num);
            }

            let start_index: usize = 25;
            let mut key_number: u64 = 0;

            for i in start_index..input.len() {
                let prev = &input[i-start_index..i];
                //assert!(prev.len() == 25);
                let value = input[i];
                if !contains_sum(value, prev) {
                    key_number = value;
                    break;
                }
            }

            let mut number_range: Vec<u64> = Vec::new();
            let mut sum: u64 = 0;

            for i in 0..input.len() {
                for j in i..input.len() {
                    let curr_value = input[j];
                    sum += curr_value;
                    number_range.push(curr_value);
                    if number_range.len() >= 2 {
                        if sum > key_number {
                            sum = 0;
                            number_range = Vec::new();
                            break;
                        }
                        if j == (input.len() - 1) {
                            sum = 0;
                            number_range = Vec::new();
                        }
                        if sum == key_number {
                            number_range.sort();
                            let sum = number_range[0] + number_range[number_range.len()-1];
                            println!("Sum: {}", sum);
                            return;
                        }
                    }
                }
            }   
        },
        None => {
            println!("Could not parse input");
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
