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
            let mut tree_count = 0;

            while t.has_next() { 
                let pos = t.next();
                if pos == b'#' {
                    tree_count += 1;
                }
            }
            println!("Trees hit: {}", tree_count);
        },
        None => {
            println!("Coult not read file");
        }
    }
}