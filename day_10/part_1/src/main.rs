use input_parser;

fn main() {
    let result = input_parser::read_line_input(10, "joltage".to_string());

    match result {
        Some(value) => {
            let mut input: Vec<i32> = Vec::new();

            for i in value {
                let num = i.parse::<i32>().unwrap();
                input.push(num);
            }

            let mut delta_one = 0;
            let mut delta_three = 1; // last one always has a difference of 3

            input.sort();

            // check difference of first one from baseline of 0
            let first = input[0];
            if first == 1 {
                delta_one += 1;
            }
            if first == 3 {
                delta_three += 1;
            }

            // check the rest
            for i in 0..(input.len()-1) {
                let first = input[i];
                let second = input[i+1];
                let diff = second - first;
                if diff == 1 {
                    delta_one += 1;
                }
                if diff == 3 {
                    delta_three += 1;
                }
            }
            
            println!("Product of differences: {}", delta_one*delta_three);
        },
        None => {
            println!("Could not parse input");
        }
    }
}
