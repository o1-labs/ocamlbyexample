open Lib

let () = 
  let h = build "casa" 5 in
  let h = destroy h in
  display h
