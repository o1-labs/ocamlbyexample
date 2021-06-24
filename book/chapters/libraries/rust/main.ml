type house = {
  name: string;
  windows: int;
  door: bool;
  cupboards: int64;
}


external build : string -> int -> house = "build_house"

external destroy : house -> house = "destroy_house"

external display : house -> unit = "display_house"

let () = 
  let h = build "casa" 5 in
  let h = destroy h in
  display h

module Opaque = struct
  type t

  external create : unit -> t = "create_opaque"

  external print : t -> unit = "print_opaque"

end

let () =
  let opaque = Opaque.create () in
  Opaque.print opaque