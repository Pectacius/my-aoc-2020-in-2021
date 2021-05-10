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

    let mut device = program::Program::new(input);
    //println!("{}, {}", device.accumulator, device.pc);
    let result = device.run();
    println!("result: {}", result);
}
