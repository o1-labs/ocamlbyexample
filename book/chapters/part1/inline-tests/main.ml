let%test "this will pass if true" = true 
let%test_unit "this will pass if unit is returned" = ()
let%test_module "name" = (module <module-expr>) 

(* taken from https://github.com/janestreet/ppx_inline_test *)
let is_prime = <magic>

let%test _ = is_prime 5
let%test _ = is_prime 7
let%test _ = not (is_prime 1)
let%test _ = not (is_prime 8)
//
module Make(C : S) = struct
  <magic>
  let%test _ = <some expression>
end

module M = Make(Int)
//
let%test_module _ = (module struct
    module UID = Unique_id.Int(struct end)

    let%test _ = UID.create() <> UID.create()
end)
