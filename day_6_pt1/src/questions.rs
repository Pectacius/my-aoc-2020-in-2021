use std::collections::HashSet;
use std::iter::FromIterator;

pub struct Questions {
    pub total_questions: HashSet<u8>,
}

impl Questions {
    pub fn new(values: &str) -> Questions {
        let data: &[u8] = values.as_bytes();

        Questions {
            total_questions: HashSet::from_iter(data.iter().cloned())
        }
    }

    pub fn num_of_questions(&self) -> usize {
        self.total_questions.len()
    }
}