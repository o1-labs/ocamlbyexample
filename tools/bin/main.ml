open Core

(* constants *)

let chapters_list = "book/chapters.json"
let chapters_dir = "book/chapters/"
let chapter_template = "templates/chapter.html"

(* data structures *)

type section = { line : int ; 
text : string }

type chapter = { title : string ; sections : section list }

(* read *)

let get_chapters _ =
  let json = Yojson.Basic.from_file chapters_list in
  let open Yojson.Basic.Util in
  let chapters = json |> member "chapters" |> to_list |> filter_string in
  chapters

let get_chapter name =
  let chapter_file = chapters_dir ^ name ^ "/chapter.json" in
  let json = Yojson.Basic.from_file chapter_file in
  let open Yojson.Basic.Util in
  let title = json |> member "title" |> to_string in
(*  let sections = json |> member "sections" |> to_list |> in *)
  let to_section = function
    | `Assoc ([ ("line", line); ("text", text)]) -> 
      {line = to_int line ; text = to_string text }
    | _ -> 
      failwith "misformated chapter.json file: a section must contain block of { line, text }"
  in
  let sections = json |> member "sections" |> convert_each to_section in
    {title ; sections}

(* write *)

  let get_chapter_template { title ; sections } = 
    let open Jingoo in
    let models = [("title", Jg_types.Tstr title)] in
    let result = Jg_template.from_file chapter models


(* helpers *)

let print_section { line ; text } = 
  printf "  - %d: %s\n" line text

let print_chapter (idx: int) { title ; sections } = 
  printf "%d - %s\n" (idx + 1) title;
  List.iter sections ~f:print_section

(* main *)

let main _ =
  let chapters = get_chapters () in
  let chapters = List.map chapters ~f:( fun name -> get_chapter name) in
  List.iteri chapters ~f:print_chapter

let () =  main ()
