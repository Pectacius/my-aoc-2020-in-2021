#[derive(Debug)]
pub struct Pos {
    pos_x: f32,
    pos_y: f32,
}

impl Pos {
    pub fn new(x: f32, y: f32) -> Self {
        Pos {
            pos_x: x,
            pos_y: y,
        }
    }

    // theta in degrees! yes degrees!
    pub fn rotate_origin(&mut self, theta: f32) {
        let angle = theta.to_radians();

        let x = self.pos_x;
        let y = self.pos_y;

        self.pos_x = x*angle.cos() - y*angle.sin();
        self.pos_y = x*angle.sin() + y*angle.cos();

        self.pos_x = self.pos_x.round();
        self.pos_y = self.pos_y.round();
    }

    pub fn translate(&mut self, x: f32, y: f32) {
        self.pos_x += x;
        self.pos_y += y;

        self.pos_x = self.pos_x.round();
        self.pos_y = self.pos_y.round();
    }

    pub fn translate_by_point(&mut self, s: f32, p: &Pos) {
        self.pos_x += s*p.pos_x;
        self.pos_y += s*p.pos_y;

        self.pos_x = self.pos_x.round();
        self.pos_y = self.pos_y.round();
    }

    pub fn manhattan(&self, x: f32, y: f32) -> f32 {
        let delta_x = self.pos_x - x;
        let delta_y = self.pos_y - y;

        delta_x.abs() + delta_y.abs()
    }
}