use std::fs;

fn main() {
    let contents = fs::read_to_string("day_2/passwords.txt")
        .expect("Unable to read file");

    let mut valid_count = 0;

    for line in contents.lines() {
        let (first_idx, second_idx, character, password) = parse_line(line);
        if is_valid(first_idx, second_idx, character, password) {
            valid_count += 1;
        }
    }
    println!("valid passwords: {}", valid_count);
}

fn parse_line(line: &str) -> (usize, usize, char, String) {
    let mut iter = line.split_whitespace();
    let count = iter.next().expect("Error parsing");
    let character = iter.next().expect("Error parsing");
    let password = iter.next().expect("Error parsing");

    let mut count_iter = count.rsplit('-');
    let second_idx = count_iter.next().expect("Error parsing");
    let first_idx = count_iter.next().expect("Error parsing");
    let first_idx = first_idx.parse::<usize>().expect("Not an usize");
    let second_idx = second_idx.parse::<usize>().expect("Not an usize");

    let character = character.chars().next().expect("Error parsing");

    (first_idx, second_idx, character, password.to_string())
}

fn is_valid(position1: usize, position2: usize, character: char, password: String) -> bool {
    let char_list: Vec<char> = password.chars().collect();
    let first = contains(&char_list, position1, character);
    let second = contains(&char_list, position2, character);
    let result = first ^ second;
    result
}

fn contains(char_list: &Vec<char>, position: usize, charactor: char) -> bool {
    if ((position - 1) < char_list.len()) && (position > 0) {
        let c = char_list[position - 1];
        return c == charactor;
    }
    else {
        return false;
    }
}
