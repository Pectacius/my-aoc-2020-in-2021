use input_parser;

mod cubes;
mod matrix;


fn main() {
    let result = input_parser::read_line_input(17, "cubes".to_string());
    match result {
        Some(value) => {
            let mut input: Vec<Vec<u8>> = Vec::new();

            for i in value {
                input.push(i.as_bytes().to_vec());
            }

            let mut cube = cubes::Cubes::new(input);

            for _ in 0..6 {
                cube.next_state();
            }

            println!("Active number: {}", cube.number_of_active());

        },
        None => {
            println!("Could not read input");
        }
    }
}
