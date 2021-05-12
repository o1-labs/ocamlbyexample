open Core

(* finds the highest modification_time from all the files in a folder (defaults to 0 if folders is the empty list) *)
let rec highest_timestamp ?(highest = 0.) folders =
  match folders with
  | [] -> highest
  | file :: rest -> (
      let is_dir = Sys.is_directory file in
      match is_dir with
      | `Yes ->
          let inside_dirs = Sys.ls_dir file in
          let inside_dirs = List.map inside_dirs ~f:(fun x -> file ^ "/" ^ x) in
          highest_timestamp ~highest (inside_dirs @ rest)
      | _ ->
          let stat = Unix.stat file in
          let modif_time = stat.st_mtime in
          let highest =
            if Float.(modif_time > highest) then modif_time else highest
          in
          highest_timestamp ~highest rest)

(* returns a higher timestamp than [last_change] if a more recent change is detected, otherwise returns [None] *)
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
  | None -> watch last_change path ~f
  | Some new_last_change ->
      printf "some changes observed, new timestamp: %f\n%!" new_last_change;
      f ();
      watch new_last_change path ~f

(* watches a folder and apply [f] if any change is detected *)
let main path ~f =
  let last_change = highest_timestamp path in
  watch last_change path ~f
