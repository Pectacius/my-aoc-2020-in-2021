use std::fs;
use std::io::BufReader;
use std::io::prelude::*;

mod terrain;

fn main() {
    let f = fs::File::open("terrain.txt").expect("Unable to open file");
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
    let mut tree_product: f64 = 1.;

    let terrains = vec![
        (1, 1), // terrain 1
        (3, 1), // terrain 2
        (5, 1), // terrain 3
        (7, 1), // terrain 4
        (1, 2), // terrain 5
    ];

    for i in terrains.iter() {
        t.set_step_size(i.0, i.1);
        let trees = t.find_trees();
        t.reset_iter();
        tree_product *= trees;
    }

    println!("Trees product: {}", tree_product);
}