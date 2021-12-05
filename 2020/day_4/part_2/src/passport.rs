use std::collections::HashMap;

use lazy_static::lazy_static;
use regex::Regex;


pub struct Passport {
    fields: HashMap<String, String>,
}

impl Passport {
    pub fn new(values: &str) -> Passport {
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

    fn validate_byr(value: &str) -> bool {
        if !Passport::is_4_digit(value) {
            return false;
        }
        match value.parse::<i32>() {
            Ok(i) => {
                (i >= 1920) && (i <= 2002)
            },
            Err(_) => {
                false
            }

        }
    }

    fn is_4_digit(value: &str) -> bool {
        lazy_static! {
            static ref REGEX: Regex = Regex::new(r"^[0-9]{4}").unwrap();
        }
        REGEX.is_match(value)
    }

    fn validate_iyr(value: &str) -> bool {
        if !Passport::is_4_digit(value) {
            return false;
        }
        match value.parse::<i32>() {
            Ok(i) => {
                (i >= 2010) && (i <= 2020)
            },
            Err(_) => {
                false
            }
        }
    }

    fn validate_eyr(value: &str) -> bool {
        if !Passport::is_4_digit(value) {
            return false;
        }
        match value.parse::<i32>() {
            Ok(i) => {
                (i >= 2020) && (i <= 2030)
            }
            Err(_) => {
                false
            }
        }
    }

    fn validate_hgt(value: &str) -> bool {
        match Passport::parse_height(value) {
            Some((num, unit)) => {
                if unit == "cm" {
                    (num >= 150) && (num <= 193)
                }
                else {
                    (num >= 59) && (num <= 76)
                }
            },
            None => {
                false
            }
        }
    }

    fn parse_height(value: &str) -> Option<(i32, String)> {
        let mut height_str_vec: Vec<char> = value.chars().collect();
        if height_str_vec.len() <= 2 {
            return None;
        }
        let height_unit_str = height_str_vec[height_str_vec.len()-2].to_string() + &height_str_vec[height_str_vec.len()-1].to_string(); 
        if height_unit_str == "cm" || height_unit_str == "in" {
            height_str_vec.pop();
            height_str_vec.pop();
            let mut num = String::from("");
            for i in height_str_vec {
                num += &i.to_string();
            }
            match num.parse::<i32>() {
                Ok(i) => {
                    return Some((i, height_unit_str));
                },
                Err(_) => {
                    return None;
                }
            }
        }
        None
    }

    fn validate_hcl(value: &str) -> bool {
        lazy_static! {
            static ref RE: Regex = Regex::new(r"^#[0-9a-f]{6}").unwrap();
        }
        RE.is_match(value)
    }

    fn validate_ecl(value: &str) -> bool {
        let valid_colours = ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"];
        valid_colours.contains(&value)
    }

    fn validate_pid(value: &str) -> bool {
        lazy_static! {
            static ref REGEX: Regex = Regex::new(r"^[0-9]{9}").unwrap();
        }
        REGEX.is_match(value)
    }

    pub fn is_valid(&self) -> bool {
        let required_fields = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"];
        for &i in required_fields.iter() {
            if self.fields.get(i).is_none() {
                return false;
            }
        }
        Passport::validate_byr(self.fields.get("byr").unwrap()) &&
            Passport::validate_iyr(self.fields.get("iyr").unwrap()) &&
            Passport::validate_eyr(self.fields.get("eyr").unwrap()) &&
            Passport::validate_hgt(self.fields.get("hgt").unwrap()) &&
            Passport::validate_hcl(self.fields.get("hcl").unwrap()) &&
            Passport::validate_ecl(self.fields.get("ecl").unwrap()) &&
            Passport::validate_pid(self.fields.get("pid").unwrap())
    }
}