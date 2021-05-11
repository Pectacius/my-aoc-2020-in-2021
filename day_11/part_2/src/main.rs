use input_parser;

mod seats;

fn main() {
    let result = input_parser::read_line_input(11, "seats".to_string());

    match result {
        Some(value) => {
            let result;
            let mut s = seats::Seats::new(value);
            let mut prev_state = s.get_state();
            loop {
                s.next_state();
                if s.is_state_repeat(&prev_state) {
                    result = s.total_occupied_seats();
                    break;
                }
                prev_state = s.get_state();
            }
            
            println!("Result: {}", result);
        },
        None => {
            println!("Error in parsing input");
        }
    }
}
