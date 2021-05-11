use input_parser;

mod terrain;

fn main() {
    let input = input_parser::read_line_input(3, "terrain".to_string());

    match input {
        Some(lines) => {
            let mut t = terrain::Terrain::new(3, 1);

            for line in lines {
                let row: Vec<u8> = line.bytes().collect();
                t.add_row(row);
            }
            let mut tree_product: f64 = 1.;

            let terrains = vec![
                (1, 1), // terrain 1
                (3, 1), // terrain 2
                (5, 1), // terrain 3
                (7, 1), // terrain 4
                (1, 2), // terrain 5
            ];

            for i in terrains.iter() {
                t.set_step_size(i.0, i.1);
                let trees = t.find_trees();
                t.reset_iter();
                tree_product *= trees;
            }

            println!("Trees product: {}", tree_product);
        },
        None => {
            println!("Coult not read file");
        }
    }

    
}