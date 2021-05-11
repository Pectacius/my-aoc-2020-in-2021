use input_parser;

mod ship;

fn main() {
    let result = input_parser::read_line_input(12, "directions".to_string());

    match result {
        Some(val) => {
            let mut s = ship::Ship::new(val);

            while s.can_move() {
                s.move_ship();
            }
            println!("Distance: {}", s.manhattan());
        },
        None => {
            println!("Error parsing input");
        }
    }
}
