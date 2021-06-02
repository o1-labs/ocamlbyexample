let great = function 
  | 0 -> "zero"
  | 1 | 2 -> "1 or 2"
  | 3 -> "three"
  | _ -> "the rest"

let%test "some test" = (great 0 = "zero")

let%test "some other test" = (great 1 = "1 or 2")
