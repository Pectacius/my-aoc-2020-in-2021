use std::fs;
use std::io::BufReader;
use std::io::prelude::*;

mod passport;


fn main() {
    let f = fs::File::open("day_4/passport.txt").expect("Unable to read file");
    let f = BufReader::new(f);
    
    let mut count = 0;

    let mut curr_value: String = "".to_owned();

    for line in f.lines() {
        let curr_line = line.unwrap();
        
        if curr_line == "" {
            let new_passport = passport::Passport::new(&curr_value);
            curr_value = "".to_owned();
            if new_passport.is_valid() {
                count += 1;
            }
        } else {
            curr_value.push_str(" ");
            curr_value.push_str(&curr_line);
        }
    }
    println!("Valid passports: {}", count);
}

