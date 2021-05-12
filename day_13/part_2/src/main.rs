use input_parser;

fn main() {
    let result = input_parser::read_line_input(13, String::from("buses"));

    match result {
        Some(value) => {
            let departures = &value[1];
            let departures = parse_buses(departures);

            let mut time = 0;
            let mut increase_factor = departures[0].0;

            for i in 1..departures.len() {
                let bus = departures[i].0;
                let idx = departures[i].1;

                while ((time + idx) % bus) != 0 {
                    time += increase_factor;
                }
                increase_factor *= bus;
            }

            println!("Result: {}", time);

        },
        None => {
            println!("Could not parse input");
        }
    }
}

fn parse_buses(line: &str) -> Vec<(u64, u64)> {
    let mut index = 0;
    let mut buses: Vec<(u64,u64)> = Vec::new();
    for val in line.split(",") {
        if val != "x" {
            let bus = val.parse::<u64>().unwrap();
            buses.push((bus, index));
        }
        index += 1;
    }
    buses
}
