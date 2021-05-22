use std::collections::HashMap;

pub struct Ticket {
    rules: HashMap<String, ((u64, u64), (u64, u64))>,
    rule_matches : HashMap<String, Vec<usize>>
}

impl Ticket {
    pub fn new() -> Self {
        Ticket {
            rules: HashMap::new(),
            rule_matches: HashMap::new(),
        }
    }

    pub fn insert_rule(&mut self, rule_name: &str, rule: String) {
        let rules: Vec<&str> = rule.split(" ").collect();
        // first index is a space
        let c1 = Ticket::parse_range(rules[1]);
        let c2 = Ticket::parse_range(rules[3]);

        self.rules.insert(rule_name.to_string(), (c1, c2));
    }

    fn parse_range(range: &str) -> (u64, u64) {
        let r: Vec<&str> = range.split("-").collect();
        let r1: u64 = r[0].parse().unwrap();
        let r2: u64 = r[1].parse().unwrap();
        (r1, r2)
    }

    pub fn is_valid_ticket(&self, ticket: String) -> bool {
        let values = ticket.split(",");

        for i in values {
            let val: u64 = i.parse().unwrap();
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
                return false
            }
        }
        true
    }

    pub fn generate_matches(&mut self, tickets_transpose: &Vec<Vec<u64>>) {
        for (k, v) in &self.rules {
            let mut valid_matches: Vec<usize> = Vec::new();
            for (i, item) in tickets_transpose.iter().enumerate() {
                if Ticket::is_match(&v.0, &v.1, item) {
                    valid_matches.push(i);
                }
            }
            self.rule_matches.insert(k.to_string(), valid_matches);
        } 
    }

    pub fn filter_matches(&mut self) {
        while self.has_multiple_matches() {
            let item = self.find_single().unwrap();
            self.remove_repeats(item.0, item.1);
        }
        self.print_matches();
    }

    pub fn find_departure_idx(&self) -> Vec<usize> {
        let mut indices: Vec<usize> = Vec::new();
        for (k, v) in &self.rule_matches {
            if k.contains("departure") {
                indices.push(v[0]);
            }
        }
        indices
    }

    fn print_matches(&self) {
        for (k, v) in &self.rule_matches {
            println!("{}, {:?}", k, v);
        }
    }

    fn remove_repeats(&mut self, key: String, value: usize) {
        let mut new_matches: HashMap<String, Vec<usize>> = HashMap::new();
        for (k, v) in &self.rule_matches {
            if k.to_string() == key {
                new_matches.insert(k.to_string(), v.to_vec());
            }
            else {
                let index = v.iter().position(|x| *x == value);
                match index {
                    Some(value) => {
                        let mut rule_vec = v.clone();
                        rule_vec.remove(value);
                        new_matches.insert(k.to_string(), rule_vec);
                    },
                    None => {
                        new_matches.insert(k.to_string(), v.to_vec());
                    }
                }
            }
        }
        self.rule_matches = new_matches;
    }

    fn has_multiple_matches(&self) -> bool {
        for (_, v) in &self.rule_matches {
            if v.len() > 1 {
                return true;
            }
        }
        false
    }

    fn find_single(&self) ->Option<(String, usize)> {
        for (k, v) in &self.rule_matches {
            if v.len() == 1 {
                return Some((k.to_string(), v[0]));
            }
        }
        None
    }

    fn is_match(criteria1: &(u64, u64), criteria2: &(u64, u64), column: &Vec<u64>) -> bool {
        let mut result = true;

        for i in column {
            if !((i >= &criteria1.0 && i <= &criteria1.1) || (i >= &criteria2.0 && i <= &criteria2.1)) {
                result = false;
                break;
            }
        }
        result
    }
}