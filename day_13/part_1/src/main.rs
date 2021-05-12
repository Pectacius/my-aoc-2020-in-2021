use input_parser;

fn main() {
    let result = input_parser::read_line_input(13, String::from("buses"));

    match result {
        Some(value) => {
            let time = &value[0];
            let time = time.parse::<i32>().unwrap();

            let departures = &value[1];
            let departures = parse_buses(departures);

            let mut bus_times: Vec<(i32, i32)> = Vec::new();

            for id in departures {
                let wait_time = find_waiting_time(id, time);
                bus_times.push((id, wait_time));
            }

            let mut smallest = std::i32::MAX;
            let mut bus = 0;

            for t in bus_times {
                if t.1 < smallest {
                    smallest = t.1;
                    bus = t.0;
                }
            }

            println!("Result: {}", bus*smallest);

        },
        None => {
            println!("Could not parse input");
        }
    }
}

fn find_waiting_time(id: i32, time: i32) -> i32 {
    let delta_time_since_last_bus = time % id;
    id - delta_time_since_last_bus
}

fn parse_buses(line: &str) -> Vec<i32> {
    let mut buses: Vec<i32> = Vec::new();
    for val in line.split(",") {
        if val == "x" {
            continue;
        }
        else {
            let bus = val.parse::<i32>().unwrap();
            buses.push(bus);
        }
    }
    buses
}
