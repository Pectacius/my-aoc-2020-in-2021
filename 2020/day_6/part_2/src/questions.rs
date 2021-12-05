use std::collections::HashSet;

pub struct Questions {
    people: Vec<HashSet<u8>>,
}

impl Questions {
    pub fn new() -> Questions {
        Questions {
            people: Vec::new()
        }
    }

    pub fn num_of_similar(&self) -> usize {
        let mut result = self.people[0].clone();
        for i in self.people.iter() {
            let tmp: HashSet<u8> = result.intersection(i).cloned().collect();
            result = tmp;
        }
        result.len()
    }

    pub fn add_person(&mut self, value: &str) {
        let new_val: HashSet<u8> = value.as_bytes().to_vec().iter().cloned().collect();
        self.people.push(new_val);
    }
}