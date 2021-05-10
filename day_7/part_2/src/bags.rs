use std::collections::HashMap;

pub struct Bag {
    name: String,
    count: i32,
}

impl Bag {
    pub fn new(name: String, count: i32) -> Self {
        Bag {
            name: name,
            count: count,
        }
    }
}

pub struct Bags {
    pub bags: HashMap<String, Vec<Bag>>, // curr bag, bags contained
}

impl Bags {
    pub fn new() -> Self {
        Bags {
            bags: HashMap::new(),
        }
    }

    pub fn insert_bag(&mut self, container: &str, contains: Vec<Bag>) {
        self.bags.insert(container.to_string(), contains);
    }

    pub fn total_count(&self, container: &str) -> i32 {
        match self.bags.get(container) {
            Some(val) => {
                let mut curr_count = 0;
                for i in val.iter() {
                    curr_count += i.count;
                    curr_count += i.count*self.total_count(&i.name);
                }
                curr_count
            },
            None => 0
        }
    }

}