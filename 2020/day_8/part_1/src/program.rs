use std::convert::TryFrom;

pub struct Program {
    pub accumulator: i32,
    pub pc: i32,
    instructions: Vec<Line>,
    visited_pc: Vec<i32>
}

impl Program {
    pub fn new(input: Vec<String>) -> Self {
        let mut instructions: Vec<Line> = Vec::new();

        for i in input.iter() {
            instructions.push(Program::parse_line(i.to_string()));
        }

        Program {
            accumulator: 0,
            pc: 0,
            instructions: instructions,
            visited_pc: Vec::new(),
        }
    }

    fn parse_line(input: String) -> Line {
        let line: Vec<&str> = input.split(" ").collect();
        
        let instruction = line[0];
        let argument = line[1];

        let num = argument.parse::<i32>().unwrap();
        Line {
            instruction: instruction.to_string(),
            argument: num,
        }
    }

    fn fetch(&self) -> (&String, i32){
        let index = usize::try_from(self.pc).ok().unwrap();
        let instruction = &self.instructions[index];
        (&instruction.instruction, instruction.argument)
    }
    
    fn execute(&mut self) {
        let instruction: String;
        let argument: i32;
        let result = self.fetch();
        instruction = result.0.to_string();
        argument = result.1;

        self.visited_pc.push(self.pc);

        if instruction == "nop" {
            self.pc += 1;
        }
        if instruction == "acc" {
            self.accumulator += argument;
            self.pc += 1;
        }
        if instruction == "jmp" {
            self.pc += argument;
        }

    }

    fn check_loop(&self) -> bool {
        self.visited_pc.contains(&self.pc)
    }

    pub fn run(&mut self) -> i32 {
        loop {
            if self.check_loop() {
                break;
            }
            self.execute();
        }
        self.accumulator
    }
}

struct Line {
    instruction: String,
    argument: i32,
}
