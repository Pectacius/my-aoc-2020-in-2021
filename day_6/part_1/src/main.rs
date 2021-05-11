use input_parser;

mod questions;

fn main() {
    let result = input_parser::read_split_newline(6, "questions".to_string());

    match result {
        Some(value) => {
            let mut sum = 0;

            for i in value {
                let new_question = questions::Questions::new(&i);
                sum += new_question.num_of_questions();
            }
            println!("Sum: {}", sum);
        },
        None => {
            println!("Could not parse input");
        }
    }
}
