use std::collections::HashMap;
use std::convert::TryFrom;
use std::str;
use input_parser;

fn main() {
    let result = input_parser::read_line_input(14, String::from("program"));

    match result {
        Some(value) => {
            let mut curr_mask = String::from("");
            // used memory locations
            let mut memory: HashMap<i32, u64> = HashMap::new();

            for i in value {
                let line = parse_line(&i);
                if line.0 == -1 {
                    curr_mask = line.1;
                }
                else {
                    let address = line.0;
                    let value = line.1;

                    let val = apply_mask(&value, &curr_mask);
                    memory.insert(address, val);
                }
            }
            let mut sum = 0;
            for k in memory {
                sum += k.1;
            }
            println!("Sum: {}", sum);
        },
        None => {
            println!("Could not parse value");
        }
    }
}

fn apply_mask(value: &str, mask: &str) -> u64 {
    let mut result = String::from("");
    
    let bit_val = to_36_bit(value);

    let bit_val_iter = bit_val.as_bytes();
    let mask_iter = mask.as_bytes();

    for i in 0..bit_val_iter.len() {
        let mask_val = mask_iter[i];
        if mask_val == b'1' {
            result.push_str(&String::from('1'));
        }
        else if mask_val == b'0' {
            result.push_str(&String::from('0'));
        }
        else {
            result.push_str(&str::from_utf8(&bit_val_iter[i..i+1]).unwrap());
        }
    }

    from_36_bit(&result)
}

fn to_36_bit(value: &str) -> String {
    let mut result = String::from("");

    let mut curr_number: i32 = value.parse().unwrap();

    while curr_number > 0 {
        let val = curr_number/2;
        let remainder = curr_number - 2*val;
        let mut curr_result = String::from("");
        if remainder == 0 {
            curr_result.push_str(&String::from("0"));
        }
        else {
            curr_result.push_str(&String::from("1"));
        }
        curr_result.push_str(&result);
        result = curr_result;
        curr_number = val;
    }
    let padding_amount = 36 - result.as_bytes().len();
    let mut padding = String::from_utf8(vec![b'0'; padding_amount]).unwrap();
    padding.push_str(&result);
    padding
}

fn from_36_bit(value: &str) -> u64 {
    let mut result = 0;
    let val_iter = value.as_bytes();

    for i in 0..val_iter.len() {
        let idx = val_iter.len() - 1 - i;
        let curr_val = val_iter[idx];

        if curr_val == b'1' {
            let power = u32::try_from(i).unwrap();
            result += u64::pow(2, power);
        }
    }
    result
}

// -1 for the i32 part if line is a mask
// otherwise it represents the address
fn parse_line(line: &str) -> (i32, String) {
    let values: Vec<&str> = line.split(" ").collect();
    if values[0] == "mask" {
        (-1, values[2].to_string())
    }
    else {
        let b_val = values[0].as_bytes();
        let f_pass = &b_val[4..b_val.len()];
        let l_pass = &f_pass[0..f_pass.len()-1];

        let address_str = str::from_utf8(l_pass).unwrap();
        let address_string = address_str.to_string();
        let address: i32 = address_string.parse().unwrap();
        (address, values[2].to_string())
    }
}
