use std::fs;
use std::io::BufReader;
use std::io::prelude::*;

mod terrain;

fn main() {
    let f = fs::File::open("day_3/terrain.txt").expect("Unable to open file");
    let f = BufReader::new(f);
    
    let mut t = terrain::Terrain::new(3, 1);

    let mut iter = f.lines();

    // insert each row
    loop {
        match iter.next() {
            Some(val) => {
                let curr_line = val.unwrap();
                if curr_line == "" {
                    break;
                }
                let line: Vec<u8> = curr_line.bytes().collect();
                t.add_row(line);
            },
            None => {
                break;
            }
        }
    }
    let mut tree_count = 0;

    while t.has_next() {
        let pos = t.next();
        if pos == b'#' {
            tree_count += 1;
        }
    }
    println!("Trees hit: {}", tree_count);
}