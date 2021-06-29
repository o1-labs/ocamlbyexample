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

#[ocaml::func]
pub fn bump_windows(house: House, num: ocaml::Int) -> Option<House> {
    if house.num + num >= 10 {
        return None
    } else {
        Some(House {
            windows: house.windows + num,
            ..house
        })
    }
}

#[derive(Debug, Clone)]
pub struct Opaque(String);

ocaml::custom!(Opaque {
    finalize: finalizer,
});

unsafe extern "C" fn finalizer(v: ocaml::Raw) {
    let ptr = v.as_pointer::<Opaque>();
    ptr.drop_in_place()
}

unsafe impl ocaml::FromValue<'_> for Opaque {
    fn from_value(value: ocaml::Value) -> Self {
        let x: ocaml::Pointer<Self> = ocaml::FromValue::from_value(value);
        x.as_ref().clone()
    }
}

#[ocaml::func]
pub fn create_opaque() -> Opaque {
    Opaque("sup".to_string())
}

#[ocaml::func]
pub fn print_opaque(opaque: Opaque) {
    println!("{:?}", opaque);
}
