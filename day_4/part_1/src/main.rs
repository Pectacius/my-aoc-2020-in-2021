use std::collections::HashMap;
use input_parser;

struct Passport {
    fields: HashMap<String, String>,
}

impl Passport {
    fn new(values: &str) -> Passport {
        let fields: Vec<&str> = values.split_ascii_whitespace().collect();
        let mut map: HashMap<String, String> = HashMap::new();
        for val in fields {
            let field: Vec<&str> = val.rsplit(':').collect();
            map.insert(field[1].to_string(), field[0].to_string());
        }
        Passport {
            fields: map
        }
    }

    fn is_valid(&self) -> bool {
        if self.fields.get("byr").is_none() {
            return false;
        }
        if self.fields.get("iyr").is_none() {
            return false;
        }
        if self.fields.get("eyr").is_none() {
            return false;
        }
        if self.fields.get("hgt").is_none() {
            return false;
        }
        if self.fields.get("hcl").is_none() {
            return false;
        }
        if self.fields.get("ecl").is_none() {
            return false;
        }
        if self.fields.get("pid").is_none() {
            return false;
        }
        return true; 
    }
}

fn main() {
    let result = input_parser::read_new_line_delimiter_input(4, "passport".to_string());

    match result {
        Some(value) => {
            let mut count = 0;

            for i in value {
                let new_passport = Passport::new(&i);
                if new_passport.is_valid() {
                    count += 1;
                }
            }
            println!("Valid passports: {}", count);
        },
        None => {
            println!("Could not read input");
        }
    }
}
