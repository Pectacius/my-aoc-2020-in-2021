use std::collections::HashMap;

pub struct Game {
    last_nums: HashMap<u32, u32>, // number and turn last said
    last_last_nums: HashMap<u32, u32>, // number and turn last last said 
    last_said_num: u32,
    turn: u32,
}

impl Game {
    pub fn new() -> Self {
        Game {
            last_nums: HashMap::new(),
            last_last_nums: HashMap::new(),
            turn: 1,
            last_said_num: 0,
        }
    }

    pub fn insert_starting_num(&mut self, num: u32) {
        self.last_nums.insert(num, self.turn);
        self.last_said_num = num;
        self.turn += 1;
    }

    fn insert_num(&mut self, num: u32) {
        // essentially copy the values to last last if the value is already in last
        match self.last_nums.get(&num) {
            Some(val) => {
                self.last_last_nums.insert(num, *val);
            }
            None => {}
        }
        self.last_nums.insert(num, self.turn);
        self.last_said_num = num;
    }

    pub fn next_turn(&mut self) {
        // check last number spoken
        match self.last_last_nums.get(&self.last_said_num) {
            // has been said before
            Some(value) => {
                let diff = self.last_nums.get(&self.last_said_num).unwrap() - value;
                self.insert_num(diff);
            },
            // never said before
            None => {
                self.insert_num(0);
            }
        } 
        self.turn += 1;
    }

    pub fn nth_number(&mut self, n: u32) -> u32 {
        while self.turn <= n {
            self.next_turn();
        }
        self.last_said_num
    }
}