use input_parser;

mod questions;

fn main() {
    let result = input_parser::read_new_line_delimiter_input(6, "questions".to_string());

    match result {
        Some(value) => {
            let mut sum = 0;

            for i in value {
                let mut curr_question = questions::Questions::new();
                for j in i.split_whitespace() {
                    curr_question.add_person(j);
                }
                sum += curr_question.num_of_similar();
            }
            println!("Sum: {}", sum);
        },
        None => {
            println!("Could not parse input");
        }
    }
}
