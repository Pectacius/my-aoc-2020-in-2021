use input_parser;

fn main() {
    let contents = input_parser::read_line_input(2, "passwords".to_string());
    
    match contents {
        Some(values) => {
            let mut valid_count = 0;

            for line in values {
                let (min, max, character, password) = parse_line(&line);
                let min = min.parse::<i32>().expect("Not a number");
                let max = max.parse::<i32>().expect("Not a number");
                let character: Vec<char> = character.chars().collect();
                let character = character[0];
                if is_valid(min, max, character, password) {
                    valid_count += 1;
                }
            }
            println!("Number of valid passwords: {}", valid_count);
        },
        None => {
            println!("Could not read file");
        }
    }

    
}

fn parse_line(line: &str) -> (String, String, String, String) {
    let mut iter = line.split_whitespace();
    let count = iter.next().expect("Error parsing");
    let character = iter.next().expect("Error parsing");
    let password = iter.next().expect("Error parsing");

    // get min and max
    let count: Vec<&str> = count.rsplit('-').collect();
    let min = count[1];
    let max = count[0];

    // get specific character
    let character: Vec<&str> = character.rsplit(':').collect();
    let character = character[1];
    (min.to_string(), max.to_string(), character.to_string(), password.to_string())
}

fn is_valid(min: i32, max: i32, character: char, password: String) -> bool {
    let mut count = 0;
    for c in password.chars() {
        if c == character {
            count += 1;
        }
    }

    if (count >= min) && (count <= max) {
        return true;
    }
    else {
        return false;
    }   
}