open Core

type person = { name: string ; age: int ; human : bool }
[@@deriving show]

let () =
  let human_one = { name = "david" ; age = 32 ; human = false } in
  printf "%s\n" (show_person human_one)