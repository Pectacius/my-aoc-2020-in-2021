use input_parser;

mod ticket;

fn main() {
    let result = input_parser::read_ticket(String::from("tickets"));

    match result {
        Some(value) => {
            let rules = value.0;
            let your_ticket: Vec<u64> = value.1.split(",").map(|i| i.parse::<u64>().unwrap()).collect();
            let nearby_ticket = value.2;

            let mut t = ticket::Ticket::new();

            for i in rules {
                let r:Vec<&str> = i.split(":").collect();
                let rule_name = r[0];
                let rule = r[1];
                t.insert_rule(rule_name, rule.to_string());
            }

            let valid_tickets: Vec<String> = nearby_ticket.into_iter().filter(|i| t.is_valid_ticket(i.to_string())).collect();

            let mut valid_nearby_tickets: Vec<Vec<u64>> = Vec::new();
            for i in valid_tickets {
                let tick: Vec<u64> = i.split(",").map(|i| i.parse::<u64>().unwrap()).collect();
                valid_nearby_tickets.push(tick);
            }
            valid_nearby_tickets.push(your_ticket.clone());

            let valid_transpose = transpose(&valid_nearby_tickets);

            t.generate_matches(&valid_transpose);
            t.filter_matches();
            let departure_idx = t.find_departure_idx();

            let mut product = 1;
            for i in departure_idx {
                product *= your_ticket[i];
            }
            println!("{}", product);
        },
        None => {
            println!("Could not parse input");
        }
    }
}

fn transpose(m: &Vec<Vec<u64>>) -> Vec<Vec<u64>> {
    let mut result:Vec<Vec<u64>> = Vec::new();

    for k in 0..m[0].len() {
        let column: Vec<u64> = m.clone().into_iter().map(|i| i[k]).collect();
        result.push(column);
    }
    result
}
