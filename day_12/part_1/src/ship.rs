use std::str;

pub struct Ship {
    next_instruction: usize,
    instructions: Vec<Instruction>,
    curr_direction: f32, // measured from x plane. right hand coordinate system
    curr_x_pos: f32,
    curr_y_pos: f32,
}

impl Ship {
    pub fn new(input: Vec<String>) -> Self {
        let mut instructions: Vec<Instruction> = Vec::new();

        for i in input {
            let value: Vec<u8> = i.into_bytes();

            let num = str::from_utf8(&value[1..value.len()]).unwrap();
            let num = num.parse::<f32>().unwrap();

            let dir = value[0];

            let instruction: Instruction;

            if dir == b'N' {
                instruction = Instruction {
                    direction: Direction::North,
                    value: num,
                }
            }
            else if dir == b'S' {
                instruction = Instruction {
                    direction: Direction::South,
                    value: num,
                }
            }
            else if dir == b'E' {
                instruction = Instruction {
                    direction: Direction::East,
                    value: num,
                }
            }
            else if dir == b'W' {
                instruction = Instruction {
                    direction: Direction::West,
                    value: num,
                }
            }
            else if dir == b'L' {
                instruction = Instruction {
                    direction: Direction::Left,
                    value: num,
                }
            }
            else if dir == b'R' {
                instruction = Instruction {
                    direction: Direction::Right,
                    value: num,
                }
            }
            else {
                instruction = Instruction {
                    direction: Direction::Forward,
                    value: num,
                }
            }
            instructions.push(instruction);
        }
        Ship {
            next_instruction: 0,
            instructions: instructions,
            curr_direction: 0.,
            curr_x_pos: 0.,
            curr_y_pos: 0.,
        }
    }

    pub fn can_move(&self) -> bool {
        self.next_instruction < self.instructions.len()
    }

    pub fn move_ship(&mut self) {
        let instruction = &self.instructions[self.next_instruction];

        match &instruction.direction {
            Direction::North => {
                self.curr_y_pos += instruction.value;
            },
            Direction::South => {
                self.curr_y_pos -= instruction.value;
            },
            Direction::East => {
                self.curr_x_pos += instruction.value;
            },
            Direction::West => {
                self.curr_x_pos -= instruction.value;
            },
            Direction::Left => {
                self.curr_direction += instruction.value;
            },
            Direction::Right => {
                self.curr_direction -= instruction.value;
            },
            Direction::Forward => {
                let rad = (self.curr_direction as f32).to_radians();
                self.curr_x_pos += instruction.value*rad.cos();
                self.curr_y_pos += instruction.value*rad.sin();
            },
        }
        self.next_instruction += 1;
    }

    pub fn manhattan(&self) -> f32 {
        self.curr_x_pos.abs() + self.curr_y_pos.abs()
    }
}

struct Instruction {
    direction: Direction,
    value: f32,
}

enum Direction {
    North,
    South,
    East,
    West,
    Left,
    Right,
    Forward,
}