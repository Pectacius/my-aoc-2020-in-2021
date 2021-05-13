use std::convert::TryFrom;
use std::str;

pub fn to_36_bit(value: &str) -> String {
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

pub fn from_36_bit(value: &str) -> u64 {
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

pub fn generate_bit_combinations(value: &str) -> Vec<String> {
    let mut combinations: Vec<String> = Vec::new();

    let mut count = 0;
    for i in value.as_bytes() {
        if *i == b'X' {
            count += 1;
        }
    }
    if count == 0 {
        combinations.push(value.to_string());
    }
    else {
        let combs = bit_combinations(count, String::from(""));

        for i in combs {
            let vals = i.as_bytes();
            let mut curr_idx = 0;
            let mut a_comb = String::from("");
            for j in value.as_bytes() {
                if *j == b'X' {
                    a_comb.push_str(&str::from_utf8(&[vals[curr_idx]]).unwrap());
                    curr_idx += 1;
                }
                else {
                    a_comb.push_str(&str::from_utf8(&[*j]).unwrap())
                }
            }
            combinations.push(a_comb);
        }
    }
    combinations
}

fn bit_combinations(value: i32, curr: String) -> Vec<String> {
    if value == 0 {
        vec![curr]
    }
    else {
        let mut option1 = curr.clone();
        let mut option2 = curr.clone();
        option1.push_str(&String::from("1"));
        option2.push_str(&String::from("0"));

        let mut result1 = bit_combinations(value - 1, option1);
        let result2 = bit_combinations(value - 1, option2);
        result1.extend(result2);

        result1
    }
}