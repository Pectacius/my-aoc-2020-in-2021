use std::convert::TryFrom;

pub struct Program {
    pub accumulator: i32,
    pub pc: i32,
    instructions: Vec<Line>,
    visited_pc: Vec<i32>
}

impl Clone for Program {
    fn clone(&self) -> Self {
        let mut instructions: Vec<Line> = Vec::new();
        for i in self.instructions.iter() {
            let new_line = Line {
                instruction: i.instruction.clone(),
                argument: i.argument.clone(),
            };
            instructions.push(new_line);
        }
        Program {
            accumulator: 0,
            pc: 0,
            instructions: instructions,
            visited_pc: Vec::new(),
        }
    }
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

    fn fetch(&self) -> Option<(&String, i32)>{
        let index = usize::try_from(self.pc).ok().unwrap();
        if index >= self.instructions.len() {
            None
        }
        else {
            let instruction = &self.instructions[index];
            Some((&instruction.instruction, instruction.argument))
        }
        
    }
    
    fn execute(&mut self) -> Option<bool> {
        match self.fetch() {
            Some(result) => {
                let instruction: String;
                let argument: i32;
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
                Some(true)
            },
            None => None
        }
    }

    fn check_loop(&self) -> bool {
        self.visited_pc.contains(&self.pc)
    }

    pub fn run_to_end(&mut self) -> Option<i32> {
        loop {
            if self.check_loop() {
                return None
            }
            if self.execute().is_none() {
                return Some(self.accumulator)
            }
        }
    }

    pub fn can_switch_instruction(&mut self, index: usize) -> bool {
        let line = &self.instructions[index];
        if line.instruction == "nop" {
            true
        }
        else if line.instruction == "jmp" {
            true
        }
        else {
            false
        }
    }

    pub fn switch_instruction(&mut self, index: usize) {
        let line = &self.instructions[index];
        if line.instruction == "nop" {
            self.instructions[index].instruction = "jmp".to_string();
        }
        else if line.instruction == "jmp" {
            self.instructions[index].instruction = "nop".to_string();
        }
    }

    pub fn len(&self) -> usize {
        self.instructions.len()
    }
}

struct Line {
    instruction: String,
    argument: i32,
}
