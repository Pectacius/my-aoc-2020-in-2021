use input_parser;

mod program;

fn main() {
    let result = input_parser::read_line_input(8, "instructions".to_string());

    match result {
        Some(input) => {
            let mut device = program::Program::new(input);
            let result = device.run();
            println!("result: {}", result)
        },
        None => {
            println!("Could not parse input");
        }
    }
}
