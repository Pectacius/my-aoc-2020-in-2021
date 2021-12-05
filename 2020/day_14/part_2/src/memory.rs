use std::collections::HashMap;
use std::str;
use crate::bit;

pub struct Memory {
    memory: HashMap<u64, u64>,
    curr_mask: String,
}

impl Memory {
    pub fn new() -> Self {
        Memory {
            memory: HashMap::new(),
            curr_mask: String::from(""),
        }
    }

    pub fn set_mask(&mut self, mask: String) {
        self.curr_mask = mask;
    }

    pub fn apply_mask(&self, value: &str) -> String {
        let mut result = String::from("");

        let bit_val = bit::to_36_bit(value);

        let bit_val_iter = bit_val.as_bytes();
        let mask_iter = self.curr_mask.as_bytes();

        for i in 0..bit_val_iter.len() {
            let mask_val = mask_iter[i];

            if mask_val == b'0' {
                result.push_str(&str::from_utf8(&[bit_val_iter[i]]).unwrap());
            }
            else if mask_val == b'1' {
                result.push_str(&String::from('1'));
            }
            else {
                result.push_str(&String::from('X'));
            }
        }

        result
    }

    pub fn write_address(&mut self, address: &str, value: u64) {
        let combinations = bit::generate_bit_combinations(address);

        for i in combinations {
            let num_address = bit::from_36_bit(&i);
            self.memory.insert(num_address, value);
        }
    }

    pub fn sum(&self) -> u64 {
        let mut sum = 0;
        for i in &self.memory {
            sum += i.1;
        }
        sum
    }
}