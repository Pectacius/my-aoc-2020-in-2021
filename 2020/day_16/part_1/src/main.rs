use input_parser;

mod ticket;

fn main() {
    let result = input_parser::read_ticket(String::from("tickets"));

    match result {
        Some(value) => {
            let rules = value.0;
            //let your_ticket = value.1;
            let nearby_ticket = value.2;

            let mut t = ticket::Ticket::new();
            let mut bad_count = 0;

            for i in rules {
                let r:Vec<&str> = i.split(":").collect();
                let rule_name = r[0];
                let rule = r[1];
                t.insert_rule(rule_name.to_string(), rule.to_string());
            }

            for i in nearby_ticket {
                let count = t.validate_ticket(i);
                bad_count += count;
            }
            println!("Bad count: {}", bad_count);
        },
        None => {
            println!("Could not parse input");
        }
    }
}
