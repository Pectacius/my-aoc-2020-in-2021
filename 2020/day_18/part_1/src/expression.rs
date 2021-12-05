use std::collections::{HashMap, HashSet, VecDeque};
use std::str;

fn tokenizer(expression: &str) -> Vec<char> {
    expression.chars().filter(|c| !c.is_whitespace()).collect()
}

fn to_rpm(value: Vec<char>) -> Vec<char> {
    let mut prededence: HashMap<char, i32> = HashMap::new();
    prededence.insert('*', 1);
    prededence.insert('+', 1);
    prededence.insert('(', 0);

    // front is popping, back is for pushing 
    let mut q: VecDeque<char> = VecDeque::new(); 
    let mut s: Vec<char> = Vec::new();
 
    for token in value {
        if '(' == token {
            s.push(token);
            continue;
        }

        if ')' == token {
            if s.len() > 0 {
                while !('(' == s[s.len()-1]) {
                    q.push_back(s.pop().unwrap())
                }
                s.pop();
                continue;
            }
        }
        // an operator
        if prededence.contains_key(&token) {
            while (s.len() != 0) && (prededence.get(&token) <= prededence.get(&s[s.len()-1])) {
                q.push_back(s.pop().unwrap());
            }
            s.push(token);
            continue;
        }

        if token.is_ascii_digit() {
            q.push_back(token);
            continue;
        }
    }
    // at the end, pop all the elements in S to Q
    while s.len() != 0 {
        let val = s.pop();
        match val {
            Some(value) => {
                q.push_back(value);
            },
            None => {
                break;
            }
        }
    }

    let mut result: Vec<char> = Vec::new();
    for val in q {
        result.push(val);
    }
    result
}

fn evaluate_rpm(value: Vec<char>) -> u64 {
    let mut s = Vec::new();
    let mut operators: HashSet<char> = HashSet::new();
    operators.insert('*');
    operators.insert('+');

    for i in value {
        if operators.contains(&i) {
            let right = s.pop().unwrap();
            let left = s.pop().unwrap();
            s.push(calculate(left, right, i));
        }
        else {
            s.push(to_number(i));
        }
    }
    s.pop().unwrap()
}

fn calculate(left: u64, right: u64, operator: char) -> u64 {
    if operator == '+' {
        left + right
    }
    else {
        left * right
    }
}

fn to_number(value: char) -> u64 {
    let val = value.to_digit(10).unwrap();
    u64::from(val)
}

pub fn evaluate_expression(expression: &str) -> u64 {
    let tokens = tokenizer(expression);
    let rpm_format = to_rpm(tokens);
    evaluate_rpm(rpm_format)
}
