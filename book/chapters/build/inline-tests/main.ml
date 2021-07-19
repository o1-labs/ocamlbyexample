let%test "some test" = true

let%test_unit "some other test" = ()

module A = struct
  let lower_than_5 x = x < 5

  let%test_unit _ = assert ( lower_than_5 3 )
end

let%test_module _ = (module struct
    let%test _ = A.lower_than_5 8
end)
