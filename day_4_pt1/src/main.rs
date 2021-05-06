use std::fs;
use std::collections::HashMap;

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
    let contents = fs::read_to_string("passport.txt")
        .expect("Unable to read file");
    let mut valid_passports = 0;
    for line in contents.rsplit("\n\r\n") {
        let passport = Passport::new(line);
        if passport.is_valid() {
            valid_passports += 1;
        }
    }
    println!("Number of valid passports: {}", valid_passports);
}
