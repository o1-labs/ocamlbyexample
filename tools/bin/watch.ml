open Core

(* timestamp is the last timestamp observed (default 0)*)
let rec has_changed (last_change : float) (folders : string list) : float option
    =
  match folders with
  | [] -> None
  | file :: rest -> (
      let is_dir = Sys.is_directory file in
      match is_dir with
      | `Yes ->
          let inside_dirs = Sys.ls_dir file in
          let inside_dirs = List.map inside_dirs ~f:(fun x -> file ^ "/" ^ x) in
          has_changed last_change (inside_dirs @ rest)
      | _ ->
          let stat = Unix.stat file in
          let modif_time = stat.st_mtime in
          if Float.(modif_time > last_change) then Some modif_time
          else has_changed last_change rest)

(* watches a folder and apply [f] if any change is detected *)
let rec watch last_change path ~f =
  Unix.sleep 1;
  match has_changed last_change path with
  | None ->
      printf "no changes observed, ts: %f\n" last_change;
      watch last_change path ~f
  | Some new_last_change ->
      printf "some changes observed, new timestamp: %f\n" new_last_change;
      f ();
      watch new_last_change path ~f
