use std::collections::{HashMap, HashSet};
use std::iter::FromIterator;

pub struct Bags {
    pub bags: HashMap<String,HashSet<String>>
}

impl Bags {
    pub fn new() -> Self {
        Bags {
            bags: HashMap::new()
        }
    }

    pub fn insert_bag(&mut self, container: &str, contains: &Vec<String>) {
        let bag = self.bags.get_mut(container);
        match bag {
            Some(val) => {
                for i in contains.iter() {
                    val.insert(i.to_string());
                }
            },
            None => {
                self.bags.insert(container.to_string(), HashSet::from_iter(contains.iter().cloned()));
                
            }
        }
        // insert sub bags
        for i in contains.iter() {
            self.insert_bag(i, &Vec::new());
        }
    }

    fn can_hold_golden_bag(&self, bag: String) -> bool {
        if bag == "shiny gold" {
            false
        }
        else {
            let bags = self.bags.get(&bag);
            match bags {
                Some(val) => {
                    if val.contains("shiny gold") {
                        return true;
                    }
                    for i in val.iter().cloned() {
                        if self.can_hold_golden_bag(i) {
                            return true;
                        }
                    }
                    false
                },
                None => false
            }
        }
    }

    pub fn can_hold_count(&self) -> i32 {
        let mut count = 0;
        for (key, _) in self.bags.iter() {
            if self.can_hold_golden_bag(key.to_string()) {
                count += 1;
            }
        }
        count
    }
}