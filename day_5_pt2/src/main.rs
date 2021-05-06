use std::fs;
use std::io::BufReader;
use std::io::prelude::*;


fn main() {
    let f = fs::File::open("pass.txt").expect("Unable to read file");
    let f = BufReader::new(f);

    let mut passes: Vec<i32> = Vec::new();

    for line in f.lines() {
        let curr_line = line.unwrap();

        // detect end of input
        if curr_line != "" {
            let pos = find_pos(&curr_line);
            passes.push(compute_id(pos.0, pos.1));
        }
    }

    match find_seat(&mut passes) {
        Some(seat) => println!("Seat id: {}", seat),
        None => println!("Seat not found")
    }

    let pos = find_pos("BFFFBBFRRR");
    println!("{}, {}", pos.0, pos.1);
    println!("{}", compute_id(pos.0, pos.1));
}

fn find_seat(seats: &mut Vec<i32>) -> Option<i32> {
    seats.sort();
    println!("{:?}", seats);
    for (i, seat) in seats.iter().enumerate() {
        match seats.get(i+1) {
            Some(nxt_seat) => {
                if (nxt_seat - seat) == 2 {
                    return Some(seat + 1)
                }
            },
            None => continue,
        }
    }
    None
}

fn find_pos(input: &str) -> (i32, i32) {
    let mut column = 0;
    let mut row = 0;
    let mut lower_bound_row = 0;
    let mut upper_bound_row = 127;
    let mut lower_bound_col = 0;
    let mut upper_bound_col = 7;
    
    for (i, c) in input.chars().enumerate() {
        if i == 6 {
            if c == 'F' {
                row = lower_bound_row;
            }
            else {
                row = upper_bound_row;
            }
        }
        else if i == 9 {
            if c == 'R' {
                column = upper_bound_col;
            }
            else {
                column = lower_bound_col;
            }
        }
        else {
            if c == 'F' {
                upper_bound_row = (upper_bound_row + lower_bound_row)/2;
            }
            else if c == 'B' {
                lower_bound_row = (upper_bound_row + lower_bound_row)/2 + 1;
            }
            else if c == 'R' {
                lower_bound_col = (lower_bound_col + upper_bound_col)/2 + 1;
            }
            else {
                upper_bound_col = (lower_bound_col + upper_bound_col)/2;
            }
        }
    }
    (row, column)
}

fn compute_id(row: i32, column: i32) -> i32 {
    row * 8 + column
}

