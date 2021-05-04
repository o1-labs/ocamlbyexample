let i = 1

let () =
  match i with
  | 0 -> print_endline "zero"
  | 1 -> print_endline "one"
  | _ -> failwith "didn't expect such a number"
