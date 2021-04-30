open Core

let can_error i =
  if i >= 0 then 
    Ok i
  else
    Error "you gave me a negative int"

let () =
  let args = Sys.get_argv () in 
  match args.(1) with 
  | "result" -> (
    let res = can_error (-1) in
    match res with 
    | Ok i -> printf "success: %d\n" i 
    | Error s -> printf "error: %s\n" s
  )
  | "failwith" -> failwith "some error message"
  | "exn" -> 
    let exception Foo of string in
    raise (Foo "some other error message")
  | _ -> print_endline "argument not recognized"

let () =
  print_endline "this might not get executed"
