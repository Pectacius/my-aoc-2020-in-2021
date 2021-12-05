use input_parser;

mod program;

fn main() {
    let result = input_parser::read_line_input(8, "instructions".to_string());

    match result {
        Some(input) => {
            let mut original = program::Program::new(input);
            let length = original.len();

            let mut result = -1;

            for i in 0..length {
                if original.can_switch_instruction(i) {
                    let mut new_device = original.clone();
                    new_device.switch_instruction(i);
                    match new_device.run_to_end() {
                        Some(val) => {
                            result = val;
                            break;
                        },
                        None => {
                            continue;
                        }
                    }
                }
            }
            println!("result: {}", result);
        },
        None => {
            println!("Could not parse input");
        }
    }
}
