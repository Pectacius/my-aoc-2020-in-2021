use std::fs;
use std::io::BufReader;
use std::io::prelude::*;

mod program;

fn main() {
    let f = fs::File::open("day_8/instructions.txt").expect("Unable to open file");
    let f = BufReader::new(f);
    let mut iter = f.lines();

    let mut input: Vec<String> = Vec::new();

    loop {
        match iter.next() {
            Some(val) => {
                let curr_line = val.unwrap();
                if curr_line == "" {
                    break;
                }
                input.push(curr_line);
            },
            None => {
                break;
            }
        }
    }

    let mut original = program::Program::new(input);

    let length = original.len();

    let mut result = -1;

    for i in 0..length {
        if original.can_switch_instruction(i) {
            let mut new_device = original.clone();
            new_device.switch_instruction(i);
            match new_device.run_to_end() {
                Some(val) => {
                    result = val;
                    break;
                },
                None => {
                    continue;
                }
            }
        }
    }
    //println!("{}, {}", device.accumulator, device.pc);
    println!("result: {}", result);
}
