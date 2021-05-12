open Core

let () = 
  let a = [1; 2; 3] in
  let b = a @ [4] in 
  let c = 0 :: b in 
  List.iter c ~f:(fun i -> printf "%d\n" i)
  