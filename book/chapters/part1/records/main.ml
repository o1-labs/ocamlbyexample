open Core

type person = { name: string ; age: int ; human : bool }

let david = { name = "david" ; age = 32 ; human = false }

let mary = { david with name = "mary" }

let toggle_human (p : person) = 
  { p with human = not p.human }

let () = 
  let david' = toggle_human david in
  if david'.human then
    print_endline "david is human"
  else
    print_endline "david is not human"
