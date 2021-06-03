type house = {
  name: string;
  windows: int;
  door: bool;
  cupboards: int64;
}


external build : string -> int -> house = "build_house"

external destroy : house -> house = "destroy_house"

external display : house -> unit = "display_house"
