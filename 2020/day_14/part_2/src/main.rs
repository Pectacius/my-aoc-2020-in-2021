use std::str;
use input_parser;

mod bit;
mod memory;

fn main() {
    let result = input_parser::read_line_input(14, String::from("program"));

    match result {
        Some(value) => {
            let mut mem = memory::Memory::new();
            for line in value {
                let parsed_line = parse_line(&line);
                if parsed_line.0 == "" {
                    mem.set_mask(parsed_line.1);
                }
                else {
                    let result_address = mem.apply_mask(&parsed_line.0);
                    let value: u64 = parsed_line.1.parse().unwrap();
                    mem.write_address(&result_address, value);
                }
            }
            println!("Sum: {}", mem.sum());
        },
        None => {
            println!("Could not parse value");
        }
    }
}


// empty string for the first part if line is a mask
// otherwise it represents the address
fn parse_line(line: &str) -> (String, String) {
    let values: Vec<&str> = line.split(" ").collect();
    if values[0] == "mask" {
        ("".to_string(), values[2].to_string())
    }
    else {
        let b_val = values[0].as_bytes();
        let f_pass = &b_val[4..b_val.len()];
        let l_pass = &f_pass[0..f_pass.len()-1];

        let address_str = str::from_utf8(l_pass).unwrap();
        let address_string = address_str.to_string();
        (address_string, values[2].to_string())
    }
}
