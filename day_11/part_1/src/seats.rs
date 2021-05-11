use std::convert::TryInto;
use std::fmt;

pub struct Seats {
    curr_state: Vec<Vec<u8>>,
    height: i32,
    width: i32
}

impl fmt::Display for Seats {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", Seats::to_string(&self.curr_state))
    }
}

impl Seats {
    pub fn new(input: Vec<String>) -> Self {
        let mut curr_state = Vec::new();
        for i in input {
            let row = i.into_bytes();
            curr_state.push(row);
        }
        let height: i32 = curr_state.len().try_into().unwrap();
        let width: i32 = curr_state[0].len().try_into().unwrap();

        Seats{
            curr_state: curr_state,
            height: height,
            width: width,
        }
    }

    pub fn get_state(&self) -> Vec<Vec<u8>> {
        self.curr_state.clone()
    }

    fn to_string(input: &Vec<Vec<u8>>) -> String {
        let mut result = String::from("");
        for i in 0..input.len() {
            for j in 0..input[0].len() {
                result.push(input[i][j] as char);
            }
            result.push_str("\n");
        }
        result
    }

    pub fn is_state_repeat(&self, state: &Vec<Vec<u8>>) -> bool {
        for i in 0..self.curr_state.len() {
            for j in 0..self.curr_state[0].len() {
                if self.curr_state[i][j] != state[i][j] {
                    return false;
                }
            }
        }
        true
    }

    pub fn next_state(&mut self) {
        let mut tmp_state = self.curr_state.clone();

        for i in 0..self.curr_state.len() {
            for j in 0..self.curr_state[0].len() {
                let curr_seat = self.curr_state[i][j];
                if curr_seat == b'.' {
                    continue;
                }
                let occupied = self.occupied_adj_seats(i.try_into().unwrap(), j.try_into().unwrap());
                if curr_seat == b'L' {
                    if occupied == 0 {
                        tmp_state[i][j] = b'#';
                    }
                    else {
                        tmp_state[i][j] = b'L';
                    }
                }
                else if curr_seat == b'#' {
                    if occupied >= 4 {
                        tmp_state[i][j] = b'L'
                    }
                    else {
                        tmp_state[i][j] = b'#';
                    }
                }
                else {
                    tmp_state[i][j] = curr_seat;
                }
            }
        }
        self.curr_state = tmp_state;
    }

    pub fn total_occupied_seats(&self) -> i32 {
        let mut occupied = 0;
        for i in 0..self.curr_state.len() {
            for j in 0..self.curr_state[0].len() {
                if self.curr_state[i][j] == b'#' {
                    occupied += 1;
                }
            }
        }
        occupied
    }

    fn occupied_adj_seats(&self, y: i32, x: i32) -> i32 {
        let mut occupied = 0;
        for i in -1..2 {
            for j in -1..2 {
                let pos_y = y - i;
                let pos_x = x - j;
                if (pos_y == y) && (pos_x == x) {
                    continue; // skip the current seat
                }
                else {
                    let seat = self.get_seat(pos_y, pos_x);
                    match seat {
                        Some(val) => {
                            if val == b'#' {
                                occupied += 1;
                            }
                        },
                        None => {
                            continue;
                        }
                    }
                }
            }
        }
        occupied
    }

    fn get_seat(&self, y: i32, x: i32) -> Option<u8> {
        if (y < 0) || (y >= self.height) || (x < 0) || (x >= self.width) {
            None
        }
        else {
            let curr_y: usize = y.try_into().unwrap();
            let curr_x: usize = x.try_into().unwrap();
            Some(self.curr_state[curr_y][curr_x])
        }
    }
}