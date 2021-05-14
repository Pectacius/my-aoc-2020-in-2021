use input_parser;

mod game;
// compile with release flags
fn main() {
    let result = input_parser::read_line_input(15, "numbers".to_string());
    let mut g = game::Game::new();

    match result {
        Some(value) => {
            let starting_nums = value[0].split(",");
            for i in starting_nums {
                let num: u32 = i.parse().unwrap();
                g.insert_starting_num(num);
            }
            let n = g.nth_number(30000000);
            println!("Number is: {}", n);
        },
        None => {
            println!("Could not parse input");
        }
    }
}
