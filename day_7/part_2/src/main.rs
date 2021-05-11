use input_parser;

mod bags;

fn main() {
        let result = input_parser::read_line_input(7, "bags".to_string());
    
    match result {
        Some(value) => {
            let mut bag_stats = bags::Bags::new();

            for i in value {
                let container: String;
                let contains: Vec<bags::Bag>;
                let result = parse_line(i);
                container = result.0;
                contains = result.1;
                bag_stats.insert_bag(&container, contains);
            }
            println!("Contains: {}", bag_stats.total_count("shiny gold"));
        },
        None => {
            println!("Could not parse input");
        }
    }
}

fn parse_line(line: String) -> (String, Vec<bags::Bag>) {
    let words: Vec<&str> = line.split(" ").collect();
    let containers: Vec<&str> = words[4..words.len()].to_vec();

    let mut inner_bags: Vec<bags::Bag> = Vec::new();

    let mut container = words[0].to_owned();
    container.push_str(" ");
    container.push_str(words[1]);

    if !((containers[0] == "no") && (containers[1] == "other") && (containers[2] == "bags.")) {
        assert!(containers.len() % 4 == 0);
        for i in (0..containers.len()).step_by(4) {
            let mut name = containers[i+1].to_owned();
            name.push_str(" ");
            name.push_str(containers[i+2]);
            let count = containers[i].parse::<i32>().unwrap();
            inner_bags.push(bags::Bag::new(name, count));
        }
    }
    //println!("{}: {:?}", container, inner_bags);
    (container, inner_bags)
}