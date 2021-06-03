#[derive(ocaml::IntoValue, ocaml::FromValue, Debug)]
pub struct House {
    name: String,
    windows: u8,
    door: bool,
    cupboards: u64,
}

#[ocaml::func]
pub fn build_house(name: String, windows: u8) -> House {
    House {
        name,
        windows,
        door: true,
        cupboards: 4,
    }
}

#[ocaml::func]
pub fn destroy_house(mut house: House) -> House {
    house.door = false;
    house
}

#[ocaml::func]
pub fn display_house(house: House) {
    println!("{:?}", house);
}
