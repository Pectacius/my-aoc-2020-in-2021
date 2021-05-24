use std::convert::TryInto;
use crate::matrix::Matrix;

pub struct Cubes {
    curr_state: Matrix,
    prev_state: Matrix,
}

impl Cubes {
    pub fn new(initial: Vec<Vec<u8>>) -> Self {
        let prev = Matrix::new(initial.clone());
        let curr = Matrix::new(initial);
        Cubes {
            curr_state: curr,
            prev_state: prev,
        }
    }

    pub fn next_state(&mut self) {
       self.curr_state.expand();
       self.prev_state.expand();

       let (x, y, z, w) = self.curr_state.dimension();

       for i in 0..x {
           for j in 0..y {
               for k in 0..z {
                   for l in 0..w {
                       let neighbours = self.curr_state.get_active_neighbours(i, j, k, l);
                       let curr_state = self.curr_state.get_position(
                            i.try_into().unwrap(), 
                            j.try_into().unwrap(), 
                            k.try_into().unwrap(),
                            l.try_into().unwrap());
                            if curr_state == b'#' {
                                if (neighbours == 2) || (neighbours == 3) {
                                    self.prev_state.insert_pos(
                                        i.try_into().unwrap(),
                                        j.try_into().unwrap(),
                                        k.try_into().unwrap(),
                                        l.try_into().unwrap(),
                                        b'#');
                                }
                                else {
                                    self.prev_state.insert_pos(
                                        i.try_into().unwrap(),
                                        j.try_into().unwrap(),
                                        k.try_into().unwrap(),
                                        l.try_into().unwrap(),
                                        b'.');
                                }
                            }
                            else {
                                if neighbours == 3 {
                                    self.prev_state.insert_pos(
                                        i.try_into().unwrap(),
                                        j.try_into().unwrap(),
                                        k.try_into().unwrap(),
                                        l.try_into().unwrap(),
                                        b'#');
                                }
                                else {
                                    self.prev_state.insert_pos(
                                        i.try_into().unwrap(),
                                        j.try_into().unwrap(),
                                        k.try_into().unwrap(),
                                        l.try_into().unwrap(),
                                        b'.');
                                }
                            }
                   }
               }
           }
       }
       std::mem::swap(&mut self.curr_state, &mut self.prev_state);
    }

    pub fn number_of_active(&self) -> i32 {
        let mut count = 0;

        let (x, y, z, w) = self.curr_state.dimension();

        for i in 0..x {
            for j in 0..y {
                for k in 0..z {
                    for l in 0..w {
                        let curr_state = self.curr_state.get_position(
                        i.try_into().unwrap(), 
                        j.try_into().unwrap(), 
                        k.try_into().unwrap(),
                        l.try_into().unwrap());
                        if curr_state == b'#' {
                           count += 1;
                        }
                    }
                }
            }
        }
        count
    }
}