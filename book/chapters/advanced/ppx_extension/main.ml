
[%%thingify let some_func a = a + 1]   

let%thingify some_other_func a = a + 1

let () = 
Format.printf "before\n" ;
  let res = some_func 5 in
  Format.printf "debug: %d\n" res 
