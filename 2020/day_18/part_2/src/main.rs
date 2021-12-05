use input_parser;

mod expression;

fn main() {
    let result = input_parser::read_line_input(18, "homework".to_string());

    match result {
        Some(value) => {
            let mut sum = 0;
            for val in value {
                let curr_val = expression::evaluate_expression(&val);
                sum += curr_val;
            }
            println!("Total sum is: {}", sum);

        },
        None => {
            println!("Could not parse input file.");
        }
    }
}
