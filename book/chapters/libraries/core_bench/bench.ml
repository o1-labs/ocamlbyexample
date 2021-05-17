open Core
open Core_bench

let () =
  let _ = Random.init (* seed: *) 0 in
  let buffer_length = 100 in 
  let rand_char _ = Random.int 256 |> char_of_int in
  let bytes_buffer = Bytes.init buffer_length ~f:rand_char in
  let hexstring = Hexstring.encode bytes_buffer in
  Command.run (Bench.make_command [
    Bench.Test.create ~name:"encoding" 
      (fun () -> ignore (Hexstring.encode bytes_buffer));
    Bench.Test.create ~name:"decoding" 
      (fun () -> ignore (Hexstring.decode hexstring));
  ])
