use input_parser;

mod passport;


fn main() {
    let result = input_parser::read_new_line_delimiter_input(4, "passport".to_string());

    match result {
        Some(value) => {
            let mut count = 0;

            for i in value {
                let new_passport = passport::Passport::new(&i);
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

