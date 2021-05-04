open Core

let () =
  let five = (5, "five") in
  let _sad = 5, "five" in (* Poor style and should be avoided *)
  let (_, second) = five in (* Extract component *)
  printf "Hey OCaml, give me %s!\n" second;
  let first = five |> fst in (* Extract first component *)
  printf "I'll give you 3 + 2 = %d\n" first
