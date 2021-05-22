use std::fs;
use std::io::BufReader;
use std::io::prelude::*;

// This lib was made after 10 days into the journey as I realized every
// day I would be writing "copy pasta" code that reads the input file.
// Hate "copy pasta" coding.

// reads inputs where each line is a seperate input
// If contents are successfully read a vector of strings where each entry
// corresponding to a line is returned. Else None is returned signaling
// that the file could not be read.
pub fn read_line_input(day: u32, file_name: String) -> Option<Vec<String>> {
    let path = format!("day_{}/{}.txt", day, file_name);
    match fs::File::open(path) {
        Ok(f) => {
            let f = BufReader::new(f);
            let mut iter = f.lines();

            let mut input: Vec<String> = Vec::new();

            loop {
                match iter.next() {
                    Some(val) => {
                        let curr_line = val.unwrap();
                        // I'm lazy when downloading the input file so there is always
                        // a blank line at the end.
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
            Some(input)
        },
        Err(_) => None
    }
}

pub fn read_new_line_delimiter_input(day: u32, file_name: String) -> Option<Vec<String>> {
    let path = format!("day_{}/{}.txt", day, file_name);
    match fs::File::open(path) {
        Ok(f) => {
            let f = BufReader::new(f);
            let mut iter = f.lines();

            let mut input: Vec<String> = Vec::new();

            let mut curr_value: String = "".to_owned();

            loop {
                match iter.next() {
                    Some(val) => {
                        let curr_line = val.unwrap();
                        if curr_line == "" {
                            input.push(curr_value.clone());
                            curr_value = "".to_owned();
                        }
                        else {
                            curr_value.push_str(" ");
                            curr_value.push_str(&curr_line);
                        }
                    },
                    None => {
                        input.push(curr_value.clone());
                        break;
                    }
                }
            }
            
            Some(input)
        },
        Err(_) => None
    }
}

pub fn read_split_newline(day: u32, file_name: String) -> Option<Vec<String>> {
    let path = format!("day_{}/{}.txt", day, file_name);
    match fs::File::open(path) {
        Ok(f) => {
            let f = BufReader::new(f);
            let mut iter = f.lines();

            let mut input: Vec<String> = Vec::new();

            let mut curr_value: String = "".to_owned();

            loop {
                match iter.next() {
                    Some(val) => {
                        let curr_line = val.unwrap();
                        if curr_line == "" {
                            input.push(curr_value.clone());
                            curr_value = "".to_owned();
                        }
                        else {
                            curr_value.push_str(&curr_line);
                        }
                    },
                    None => {
                        input.push(curr_value.clone());
                        break;
                    }
                }
            }
            
            Some(input)
        },
        Err(_) => None
    }
}

pub fn read_ticket(file_name: String) -> Option<(Vec<String>, String, Vec<String>)> {
    let path = format!("day_16/{}.txt", file_name);
    match fs::File::open(path) {
        Ok(f) => {
            let mut rules: Vec<String> = Vec::new();
            let mut your_ticket = String::from("");
            let mut nearby_ticket: Vec<String> = Vec::new();
            
            let f = BufReader::new(f);
            let mut iter = f.lines();

            let mut curr_section = 1;

            loop {
                match iter.next() {
                    Some(val) => {
                        let curr_line = val.unwrap();
                        if curr_line == "" {
                            continue;
                        }
                        if (curr_line == "your ticket:") || (curr_line == "nearby tickets:") {
                            curr_section += 1;
                            continue;
                        }
                        if curr_section == 1 {
                            rules.push(curr_line.to_owned());
                        }
                        if curr_section == 2 {
                            your_ticket = curr_line.to_owned();
                        }
                        if curr_section == 3 {
                            nearby_ticket.push(curr_line.to_owned());
                        }
                    },
                    None => {
                        break;
                    }
                }
            }
            Some((rules, your_ticket, nearby_ticket))
        },
        Err(_) => None
    }
}
