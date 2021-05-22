use std::collections::HashMap;

pub struct Ticket {
    rules: HashMap<String, ((i32, i32), (i32, i32))>
}

impl Ticket {
    pub fn new() -> Self {
        Ticket {
            rules: HashMap::new(),
        }
    }

    pub fn insert_rule(&mut self, rule_name: String, rule: String) {
        let rules: Vec<&str> = rule.split(" ").collect();
        // first index is a space
        let c1 = Ticket::parse_range(rules[1]);
        let c2 = Ticket::parse_range(rules[3]);

        self.rules.insert(rule_name, (c1, c2));
    }

    fn parse_range(range: &str) -> (i32, i32) {
        let r: Vec<&str> = range.split("-").collect();
        let r1: i32 = r[0].parse().unwrap();
        let r2: i32 = r[1].parse().unwrap();
        (r1, r2)
    }

    pub fn validate_ticket(&self, ticket: String) -> i32 {
        let mut bad_count = 0;
        
        let values = ticket.split(",");

        for i in values {
            let val: i32 = i.parse().unwrap();
            let mut valid = false;
            for (_, v) in &self.rules {
                let p1 = v.0;
                let p2 = v.1;

                if (val >= p1.0 && val <= p1.1) || (val >= p2.0 && val <= p2.1) {
                    valid = true;
                    break;
                }
                else {
                    continue;
                }
            }
            if !valid {
                bad_count += val;
            }
        }
        bad_count
    }
}