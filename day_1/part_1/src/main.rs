use std::fs;
use std::collections::HashMap;

fn main() {
    let contents = fs::read_to_string("day_1/numbers.txt")
        .expect("Unable to read file");

    let mut map: HashMap<i32, i32> = HashMap::new();
    for line in contents.lines() {
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
}
