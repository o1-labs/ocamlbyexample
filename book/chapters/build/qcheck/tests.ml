let encode_decode =
  QCheck.(
    Test.make ~count:1000 ~name:"encode -> decode" string (fun some_string ->
        let expected_result = Bytes.of_string some_string in
        let hexstring = Bytes.of_string some_string |> Hexstring.encode in
        Hexstring.decode hexstring = Ok expected_result))

let arbitrary_hexstring =
  let open QCheck.Gen in
  (* the hexadecimal range *)
  let c = char_range 'a' 'f' in
  let d = char_range '0' '9' in
  (* randomly choose a character in any given range *)
  let elem_gen = oneof [ c; d ] in
  (* an hexstring is of even size ( 2 x natural number ) *)
  let size_gen = map (fun x -> 2 * x) nat in
  (* creates lists of size [size_gen] *)
  (* containing elements generated via [elem_gen] *)
  list_size size_gen elem_gen

let decode_arbitrary_hexstring =
  QCheck.(
    Test.make ~count:1000 ~name:"rand hexstring -> decode"
      (make arbitrary_hexstring) (fun arb ->
        let s = arb |> List.to_seq |> String.of_seq in
        let len = List.length arb in
        let decoded = Hexstring.decode s in
        match decoded with
        | Ok r -> Hexstring.encode r = s
        | Error _  -> false

let () =
  QCheck_base_runner.run_tests_main
    [ encode_decode; decode_arbitrary_hexstring ]
