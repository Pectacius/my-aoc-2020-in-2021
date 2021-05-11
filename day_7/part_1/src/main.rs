use input_parser;

mod bags;

fn main() {
    let result = input_parser::read_line_input(7, "bags".to_string());
    
    match result {
        Some(value) => {
            let mut bag_stats = bags::Bags::new();

            for i in value {
                let container: String;
                let contains: Vec<String>;
                let result = parse_line(i);
                container = result.0;
                contains = result.1;
                bag_stats.insert_bag(&container, &contains);
            }
            println!("Contains: {}", bag_stats.can_hold_count());
        },
        None => {
            println!("Could not parse input");
        }
    }
}

fn parse_line(line: String) -> (String, Vec<String>) {
    let words: Vec<&str> = line.split(" ").collect();
    let containers: Vec<&str> = words[4..words.len()].to_vec();

    let mut inner_bags: Vec<String> = Vec::new();

    let mut container = words[0].to_owned();
    container.push_str(" ");
    container.push_str(words[1]);

    if !((containers[0] == "no") && (containers[1] == "other") && (containers[2] == "bags.")) {
        assert!(containers.len() % 4 == 0);
        for i in (0..containers.len()).step_by(4) {
            let mut bag = containers[i+1].to_owned();
            bag.push_str(" ");
            bag.push_str(containers[i+2]);
            inner_bags.push(bag);
        }
    }
    //println!("{}: {:?}", container, inner_bags);
    (container, inner_bags)
}