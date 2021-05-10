use std::fs;
use std::io::BufReader;
use std::io::prelude::*;
use std::collections::HashMap;

fn main() {
    let f = fs::File::open("joltage.txt").expect("Unable to open file");
    let f = BufReader::new(f);
    let mut iter = f.lines();

    let mut input: Vec<i32> = Vec::new();
    input.push(0); // starting jolt

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


    input.sort();

    // add the last element. Always 3 jolts greater
    input.push(input[input.len()-1]+3);

    let mut prev_values: HashMap<i32, u64> = HashMap::new();
    prev_values.insert(0, 1); 

    let combinations = find_combinations(&input, &mut prev_values);

    println!("Total combinations: {}", combinations);
}

fn find_combinations(input: &Vec<i32>, visited: &mut HashMap<i32, u64>) -> u64 {
    // skip first one cause we already added it.
    for i in 1..input.len() {
        let prev = prev_inputs(i, input);
        let mut path_to_curr = 0;
        for j in prev.iter() {
            path_to_curr += visited.get(j).unwrap();
        }
        visited.insert(input[i], path_to_curr);
    }
    *visited.get(&input[input.len()-1]).unwrap()
}

fn prev_inputs(curr_idx: usize, input: &Vec<i32>) -> Vec<i32> {
    let mut result: Vec<i32> = Vec::new();
    if curr_idx == 1 {
        if (input[1] - input[0]) <= 3 {
            result.push(input[0]);
        }
    }
    else if curr_idx == 2 {
        for i in 1..3 {
            if (input[curr_idx] - input[curr_idx-i]) <= 3 {
                result.push(input[curr_idx-i]);
            }
        }
    }
    else {
        for i in 1..4 {
            if (input[curr_idx] - input[curr_idx-i]) <= 3 {
                result.push(input[curr_idx-i]);
            }
        }
    }
    result
}
