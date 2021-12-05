use std::str;
use std::fmt;
use crate::pos;

pub struct Ship {
    next_instruction: usize,
    instructions: Vec<Instruction>,
    ship_pos: pos::Pos,
    waypoint: pos::Pos,
}

impl fmt::Debug for Ship {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        f.debug_struct("Ship")
            .field("Pos", &self.ship_pos)
            .field("Waypoint", &self.waypoint)
            .finish()
    }
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
            ship_pos: pos::Pos::new(0., 0.),
            waypoint: pos::Pos::new(10., 1.), 
        }
    }

    pub fn can_move(&self) -> bool {
        self.next_instruction < self.instructions.len()
    }

    pub fn move_ship(&mut self) {
        let instruction = &self.instructions[self.next_instruction];

        match &instruction.direction {
            Direction::North => {
                self.waypoint.translate(0., instruction.value);
            },
            Direction::South => {
                self.waypoint.translate(0., -instruction.value);
            },
            Direction::East => {
                self.waypoint.translate(instruction.value, 0.);
            },
            Direction::West => {
                self.waypoint.translate(-instruction.value, 0.);
            },
            Direction::Left => {
                self.waypoint.rotate_origin(instruction.value);
            },
            Direction::Right => {
                self.waypoint.rotate_origin(-instruction.value);
            },
            Direction::Forward => {
                self.ship_pos.translate_by_point(instruction.value, &self.waypoint);
            },
        }
        self.next_instruction += 1;
    }

    pub fn manhattan(&self) -> f32 {
        self.ship_pos.manhattan(0., 0.)
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