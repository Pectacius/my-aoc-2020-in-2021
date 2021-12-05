pub struct Terrain {
    ground: Vec<Vec<u8>>,
    step_x: usize,
    step_y: usize,
    next_x: usize,
    next_y: usize,
}

impl Terrain {
    pub fn new(x_step: usize, y_step: usize) -> Self {
        Terrain {
            ground: Vec::new(),
            step_x: x_step,
            step_y: y_step,
            next_x: 0,
            next_y: 0,
        }
    }

    pub fn set_step_size(&mut self, x_step: usize, y_step: usize) {
        self.step_x = x_step;
        self.step_y = y_step;
    }

    pub fn add_row(&mut self, row: Vec<u8>) {
        self.ground.push(row);
    }

    // essentially a poor man's iterator
    pub fn has_next(&self) -> bool {
        self.next_y < self.ground.len()
    }

    pub fn next(&mut self) -> u8 {
        let result = self.ground[self.next_y][self.next_x];
        self.next_y += self.step_y;
        self.next_x += self.step_x;
        self.next_x %= self.ground[0].len();
        result
    }

    pub fn reset_iter(&mut self) {
        self.next_x = 0;
        self.next_y = 0;
    }

    pub fn find_trees(&mut self) -> f64 {
        let mut tree_count = 0.;
        while self.has_next() {
            let pos = self.next();
            if pos == b'#' {
                tree_count += 1.;
            }
        }
        tree_count
    }
}