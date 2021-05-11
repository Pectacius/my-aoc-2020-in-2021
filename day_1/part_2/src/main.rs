use std::collections::HashMap;
use input_parser;

fn find_pair(map: &HashMap<i32, i32>, sum: i32) -> Option<(i32, i32)> {
    for key in &*map {
        let third = sum - key.0;
        match &map.get(&third) {
            Some(_) => {
                return Some((*key.0, third))
            }
            None => {
                continue;
            }
        }
    }
    None
}

fn main() {
    let contents = input_parser::read_line_input(1, "numbers".to_string());

    match contents {
        Some(inputs) => {
            let mut map: HashMap<i32, i32> = HashMap::new();
            for line in inputs {
                let num = line.parse::<i32>().unwrap();
                map.insert(num, 2020 - num);
            }
            for (key, value) in &map {
                let result = find_pair(&map, *value);
                match result {
                    Some(t) => {
                        println!("product: {}", key * t.0 * t.1);
                        break;
                    }
                    None => {
                        continue;
                    }
                }
            }
        },
        None => {
            println!("Coult not read file");
        }
    }
}
