use std::fs;
use std::io::BufReader;
use std::io::prelude::*;

mod bags;

fn main() {
    let f = fs::File::open("bags.txt").expect("Unable to open file");
    let f = BufReader::new(f);

    let mut iter = f.lines();

    let mut bag_stats = bags::Bags::new();

    loop {
        match iter.next() {
            Some(val) => {
                let curr_line = val.unwrap();
                if curr_line == "" {
                    break
                }

                let container: String;
                let contains: Vec<bags::Bag>;
                let result = parse_line(curr_line);
                container = result.0;
                contains = result.1;
                bag_stats.insert_bag(&container, contains);
                
            },
            None => {
                break;
            }
        }
    }
    //println!("{:?}", bag_stats.bags);
    println!("Count: {}", bag_stats.total_count("shiny gold"));
}

fn parse_line(line: String) -> (String, Vec<bags::Bag>) {
    let words: Vec<&str> = line.split(" ").collect();
    let containers: Vec<&str> = words[4..words.len()].to_vec();

    let mut inner_bags: Vec<bags::Bag> = Vec::new();

    let mut container = words[0].to_owned();
    container.push_str(" ");
    container.push_str(words[1]);

    if !((containers[0] == "no") && (containers[1] == "other") && (containers[2] == "bags.")) {
        assert!(containers.len() % 4 == 0);
        for i in (0..containers.len()).step_by(4) {
            let mut name = containers[i+1].to_owned();
            name.push_str(" ");
            name.push_str(containers[i+2]);
            let count = containers[i].parse::<i32>().unwrap();
            inner_bags.push(bags::Bag::new(name, count));
        }
    }
    //println!("{}: {:?}", container, inner_bags);
    (container, inner_bags)
}