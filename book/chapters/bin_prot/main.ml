open Core

module Thing = struct
  type t =
  | No_arg
  | One_arg of string
  | Record_arg of { num : int } [@@deriving bin_io, show]
end

let () = 
  let some = Thing.One_arg "hello" in
  let buf = Bin_prot.Common.create_buf 50 in
  let pos = Thing.bin_write_t buf ~pos:0 some in 
  let pos' = ref 0 in
  let some' = Thing.bin_read_t buf ~pos_ref:pos' in 
  printf "%s =?= %s\n" (Thing.show some) (Thing.show some');
  printf "%d =?= %d\n" pos !pos'

