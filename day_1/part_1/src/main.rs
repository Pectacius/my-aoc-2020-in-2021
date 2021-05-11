use std::collections::HashMap;
use input_parser;

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
                match &map.get(&value) {
                    Some(_) => {
                        println!("product: {}", key * value);
                        break;
                    }
                    None => {
                        continue;
                    }
                }
            }
        },
        None => {
            println!("Could not read file");
        }
    }    
}
