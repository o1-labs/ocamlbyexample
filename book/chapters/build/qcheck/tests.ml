let encode_decode =
  QCheck.(
    Test.make ~count:1000 ~name:"encode -> decode" string (fun some_string ->
        let expected_result = Bytes.of_string some_string in
        let hexstring = Bytes.of_string some_string |> Hexstring.encode in
        Hexstring.decode hexstring = Ok expected_result))

let elem_gen = 
  let open QCheck.Gen in
  let c = char_range 'a' 'f' in
  let d = char_range '0' '9' in
  oneof [ c; d ]

let size_gen = 
  QCheck.Gen.(map (fun x -> 2 * x) nat)

let arbitrary_hexstring =
  QCheck.Gen.list_size size_gen elem_gen

let decode_arbitrary_hexstring =
  QCheck.(
    Test.make ~count:1000 ~name:"rand hexstring -> decode"
      (make arbitrary_hexstring) (fun arb ->
        let s = arb |> List.to_seq |> String.of_seq in
        let decoded = Hexstring.decode s in
        match decoded with
        | Ok r -> Hexstring.encode r = s
        | Error _  -> false

let () =
  QCheck_base_runner.run_tests_main
    [ encode_decode; decode_arbitrary_hexstring ]
