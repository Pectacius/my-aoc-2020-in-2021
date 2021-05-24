use std::convert::TryFrom;

#[derive(Clone)]
pub struct Matrix {
    mat: Vec<Vec<Vec<Vec<u8>>>>
}

impl Matrix {
    pub fn new(initial: Vec<Vec<u8>>) -> Self {
        let mut initial_vec = Vec::new();
        initial_vec.push(initial);
        Matrix {
            mat: vec![initial_vec]
        }
    }

    pub fn dimension(&self) -> (usize, usize, usize, usize) {
        (self.mat[0][0][0].len(), self.mat[0][0].len(), self.mat[0].len(), self.mat.len())
    }

    // todo
    pub fn get_active_neighbours(&self, x: usize, y: usize, z: usize, w: usize) -> i32 {
        let mut count = 0;

        let actual_x = i32::try_from(x).unwrap();
        let actual_y = i32::try_from(y).unwrap();
        let actual_z = i32::try_from(z).unwrap();
        let actual_w = i32::try_from(w).unwrap();

        for i in -1..2 {
            for j in -1..2 {
                for k in -1..2 {
                    for l in -1..2 {
                        if (i == 0) && (j == 0) && (k == 0) && (l == 0) {
                            continue;
                        }
                        else {
                            let result = self.get_position(
                                actual_x - i, 
                                actual_y - j, 
                                actual_z - k, 
                                actual_w - l);
                            if result == b'#' {
                                count += 1;
                            }
                        }
                    }
                }
            }
        }
        count
    }

    fn expand_positive_x(&mut self) {
        for i in 0..self.mat.len() {
            for j in 0..self.mat[0].len() {
                for k in 0..self.mat[0][0].len() {
                    self.mat[i][j][k].push(b'.');
                }
            }
        }
    }

    fn expand_negative_x(&mut self) {
        for i in 0..self.mat.len() {
            for j in 0..self.mat[0].len() {
                for k in 0..self.mat[0][0].len() {
                    self.mat[i][j][k].insert(0, b'.');
                }
            }
        }
    }

    fn expand_positive_y(&mut self) {
        let row = self.create_row();
        for i in 0..self.mat.len() {
            for j in 0..self.mat[0].len() {
                self.mat[i][j].push(row.clone());
            }
        }
    }

    fn expand_negative_y(&mut self) {
        let row = self.create_row();
        for i in 0..self.mat.len() {
            for j in 0..self.mat[0].len() {
                self.mat[i][j].insert(0, row.clone());
            }
        }
    }

    fn expand_positive_z(&mut self) {
        let plane = self.create_plane();
        for i in 0..self.mat.len() {
            self.mat[i].push(plane.clone());
        }
    }

    fn expand_negative_z(&mut self) {
        let plane = self.create_plane();
        for i in 0..self.mat.len() {
            self.mat[i].insert(0, plane.clone());
        }
    }

    fn expand_positive_w(&mut self) {
        let cube = self.create_cube();
        self.mat.push(cube);
    }

    fn expand_negative_w(&mut self) {
        let cube = self.create_cube();
        self.mat.insert(0, cube);
    }

    fn create_row(&self) -> Vec<u8> {
        let mut new_vec = Vec::new();
        for _ in 0..self.mat[0][0][0].len() {
            new_vec.push(b'.');
        }
        new_vec
    }

    fn create_plane(&self) -> Vec<Vec<u8>> {
        let mut new_vec = Vec::new();
        for _ in 0..self.mat[0][0].len() {
            new_vec.push(self.create_row());
        }
        new_vec
    }

    fn create_cube(&self) -> Vec<Vec<Vec<u8>>> {
        let mut new_vec = Vec::new();
        for _ in 0..self.mat[0].len() {
            new_vec.push(self.create_plane());
        }
        new_vec
    }

    // infinate size. Since invariant is the current data holds at least all
    // the alive cells, anything outside the current data would be considered
    // dead.
    pub fn get_position(&self, x: i32, y: i32, z: i32, w: i32) -> u8 {
        if self.out_of_bounds_z(z) {
            b'.'
        }
        else if self.out_of_bounds_y(y) {
            b'.'
        }
        else if self.out_of_bounds_x(x) {
            b'.'
        }
        else if self.out_of_bounds_w(w) {
            b'.'
        }
        else {
            let x_idx = usize::try_from(x).unwrap();
            let y_idx = usize::try_from(y).unwrap();
            let z_idx = usize::try_from(z).unwrap();
            let w_idx = usize::try_from(w).unwrap();
            self.mat[w_idx][z_idx][y_idx][x_idx]
        }
    }

    fn out_of_bounds_x(&self, x: i32) -> bool {
        (x < 0) || (x >= i32::try_from(self.mat[0][0][0].len()).unwrap()) 
    }

    fn out_of_bounds_y(&self, y: i32) -> bool {
        (y < 0) || (y >= i32::try_from(self.mat[0][0].len()).unwrap())
    }

    fn out_of_bounds_z(&self, z: i32) -> bool {
        (z < 0) || (z >= i32::try_from(self.mat[0].len()).unwrap())
    }

    fn out_of_bounds_w(&self, w: i32) -> bool {
        (w < 0) || (w >= i32::try_from(self.mat.len()).unwrap())
    }

    pub fn insert_pos(&mut self, x: i32, y: i32, z: i32, w: i32, val: u8) {
        let x_actual = usize::try_from(x).unwrap();
        let y_actual = usize::try_from(y).unwrap();
        let z_actual = usize::try_from(z).unwrap();
        let w_actual = usize::try_from(w).unwrap();
        self.mat[w_actual][z_actual][y_actual][x_actual] = val;
    }

    pub fn expand(&mut self) {
        self.expand_negative_x();
        self.expand_positive_x();
        self.expand_negative_y();
        self.expand_positive_y();
        self.expand_negative_z();
        self.expand_positive_z();
        self.expand_negative_w();
        self.expand_positive_w();
    }
}