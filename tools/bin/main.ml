open Core

(* constants *)

let book_dir = "book"

let chapters_list = book_dir ^ "/chapters.json"

let chapters_dir = book_dir ^ "/chapters"

let template_dir = "templates"

let chapter_template = template_dir ^ "/chapter.html"

let index_template = template_dir ^ "/index.html"

let output_dir = "dist/"

(* data structures *)

type explanation =
  (* 1:1 matching with what's in the JSON file *)
  | Unparsed of { line : int; text : string }
  (* a parsed explanation includes the code related to a block of text *)
  | Parsed of { code : string list; explanation : string }
[@@deriving show]

type section = {
  (* path to the file *)
  file : string;
  (* this must be a class recognized by https://github.com/highlightjs/highlight.js/blob/main/SUPPORTED_LANGUAGES.md *)
  lang : string;
  (* a file has several "blocks" of text explaining the code *)
  explanations : explanation list;
}
[@@deriving show]

type chapter = {
  title : string;
  folder : string;
  (* a chapter has several files *)
  sections : section list;
}
[@@deriving show]

type part = {
  title : string;
  (* each part has several chapters *)
  chapters : chapter list;
}
[@@deriving show]

(* read JSON files *)

let get_chapter folder =
  let chapter_file = chapters_dir ^ "/" ^ folder ^ "/" ^ "chapter.json" in
  match Sys.file_exists chapter_file with
  | `Unknown | `No -> { title = folder; folder = ""; sections = [] }
  | `Yes ->
      ();
      let json = Yojson.Basic.from_file chapter_file in
      let open Yojson.Basic.Util in
      let title = json |> member "title" |> to_string in
      let to_explanation = function
        | `Assoc [ ("line", line); ("text", text) ] ->
            Unparsed { line = to_int line; text = to_string text }
        | _ ->
            failwith
              "misformated chapter.json: explanations must contain blocks of { \
               line, text }"
      in
      let to_section = function
        | `Assoc
            [ ("file", file); ("lang", lang); ("explanations", explanations) ]
          ->
            let file = to_string file in
            let lang = to_string lang in
            let explanations = explanations |> convert_each to_explanation in
            { file; lang; explanations }
        | _ ->
            failwith
              "misformated chapter.json: sections must contain blocks of { \
               file, explanations }"
      in
      let sections = json |> member "sections" |> convert_each to_section in
      { title; folder; sections }

let get_part part =
  let open Yojson.Basic.Util in
  let title = part |> member "title" |> to_string in
  let chapters = part |> member "chapters" |> to_list |> filter_string in
  let chapters = List.map chapters ~f:get_chapter in
  { title; chapters }

let get_parts _ =
  let json = Yojson.Basic.from_file chapters_list in
  let open Yojson.Basic.Util in
  let parts = json |> member "parts" |> to_list in
  let parts = List.map parts ~f:get_part in
  parts

let get_code folder file_name =
  let file_name = chapters_dir ^ "/" ^ folder ^ "/" ^ file_name in
  In_channel.read_lines file_name

(* transform *)

let produce_explanation (code : string list) (ln : int) (e : explanation)
    (rest_expls : explanation list) =
  match e with
  | Parsed _ ->
      failwith "this shouldn't happen, explanation passed is already parsed"
  | Unparsed expl ->
      if ln < expl.line then
        (* explanation starts later *)
        let limit = expl.line - ln in
        let code, remaining_code = List.split_n code limit in
        let explanation = Parsed { code; explanation = "" } in
        let ln = expl.line in
        (explanation, ln, remaining_code, e :: rest_expls)
      else if ln = expl.line then
        (* explanation starts now *)
        match rest_expls with
        | [] ->
            (* and goes to the end *)
            let explanation = Parsed { code; explanation = expl.text } in
            let ln = ln + List.length code in
            let remaining_code = [] in
            (explanation, ln, remaining_code, [])
        | Unparsed next :: rest_expls ->
            (* and is upper bounded *)
            let limit = next.line - ln in
            let code, remaining_code = List.split_n code limit in
            let explanation = Parsed { code; explanation = expl.text } in
            let ln = next.line in
            let rest_expls = Unparsed next :: rest_expls in
            (explanation, ln, remaining_code, rest_expls)
        | _ ->
            failwith
              "this shouldn't happen, parsed explanation should be unparsed"
      else
        (* explanation starts before code *)
        let explanation = Parsed { code = []; explanation = expl.text } in
        (explanation, ln, code, rest_expls)

let rec produce_explanations (result : explanation list) ln (code : string list)
    (explanations : explanation list) =
  match (code, explanations) with
  | [], [] -> result
  | code, [] -> result @ [ Parsed { code; explanation = "" } ]
  | [], [ Unparsed expl ] ->
      result @ [ Parsed { code = []; explanation = expl.text } ]
  | [], Unparsed expl :: _ ->
      eprintf "explanation dangling: %s" expl.text;
      failwith
        "misformated chapter.json: there can only be one trailing explanation \
         (with no associated code)"
  | [], _ ->
      failwith
        "this shouldn't happen, trailing explanation has already been parsed"
  | code, expl :: rest_expls ->
      let explanation, ln, remaining_code, rest_expls =
        produce_explanation code ln expl rest_expls
      in
      let new_result = result @ [ explanation ] in
      produce_explanations new_result ln remaining_code rest_expls

let parse_parts parts =
  let parse_section folder ({ file; explanations; _ } as section) =
    let code = get_code folder file in
    let explanations = produce_explanations [] 1 code explanations in
    { section with explanations }
  in
  let parse_chapter ({ folder; sections; _ } as chapter) =
    let sections = List.map sections ~f:(parse_section folder) in
    let folder = String.substr_replace_all folder ~pattern:"/" ~with_:"-" in
    { chapter with sections; folder }
  in
  let parse_part ({ chapters; _ } as part) =
    let chapters = List.map chapters ~f:parse_chapter in
    { part with chapters }
  in
  List.map parts ~f:parse_part

(* ocaml -> models for HTML *)

let chapter_to_model { title; folder; sections } =
  let explanation_to_model = function
    | Unparsed _ ->
        failwith "this shouldn't happen, explanations must be parsed first"
    | Parsed { code; explanation } ->
        let code = String.concat code ~sep:"\n" in
        let open Jingoo.Jg_types in
        Tobj [ ("code", Tstr code); ("explanation", Tstr explanation) ]
  in
  let section_to_model { file; lang; explanations } =
    let explanations = List.map explanations ~f:explanation_to_model in
    let open Jingoo.Jg_types in
    Tobj
      [
        ("file", Tstr file);
        ("lang", Tstr lang);
        ("explanations", Tlist explanations);
      ]
  in
  let sections = List.map sections ~f:section_to_model in
  let open Jingoo in
  Jg_types.Tobj
    [
      ("title", Jg_types.Tstr title);
      ("folder", Jg_types.Tstr folder);
      ("sections", Jg_types.Tlist sections);
    ]

let chapters_to_model chapters =
  let chapters = List.map chapters ~f:chapter_to_model in
  Jingoo.Jg_types.Tlist chapters

let part_to_model { title; chapters } =
  let chapters = chapters_to_model chapters in
  let open Jingoo in
  Jg_types.Tobj [ ("title", Jg_types.Tstr title); ("chapters", chapters) ]

let parts_to_model parts =
  let parts = List.map parts ~f:part_to_model in
  Jingoo.Jg_types.Tlist parts

(* models -> HTML *)

let chapter_to_html parts chapter =
  let folder = chapter.folder in
  let chapter = chapter_to_model chapter in
  let models = [ ("parts", parts); ("chapter", chapter) ] in
  let result = Jingoo.Jg_template.from_file chapter_template ~models in
  (folder, result)

let parts_to_index parts =
  let parts = parts_to_model parts in
  let models = [ ("parts", parts) ] in
  let result = Jingoo.Jg_template.from_file index_template ~models in
  result

(* HTML -> disk *)

let html_to_disk (name, data) =
  let name = String.substr_replace_all name ~pattern:"/" ~with_:"-" in
  let output_file = output_dir ^ name ^ ".html" in
  Out_channel.write_all output_file ~data

let chapters_to_html parts chapters =
  let parts_mod = parts_to_model parts in
  let chapters =
    List.filter chapters ~f:(fun { folder; _ } -> not (String.is_empty folder))
  in
  let chapters_html = List.map chapters ~f:(chapter_to_html parts_mod) in
  List.iter chapters_html ~f:html_to_disk

let parts_to_html parts =
  List.iter parts ~f:(fun { chapters; _ } -> chapters_to_html parts chapters)

let index_to_html parts =
  let index_html = parts_to_index parts in
  html_to_disk ("index", index_html)

(* helpers *)

let print_explanation = function
  | Unparsed { line; text } -> printf "    + %d: %s\n" line text
  | Parsed { code; explanation } ->
      let code = String.concat ~sep:"\n" code in
      printf "    + code: %s\n    + %s\n" code explanation

let print_section { file; lang; explanations } =
  printf "  - %s (%s)\n" file lang;
  List.iter explanations ~f:print_explanation

let print_chapter (idx : int) { title; sections; _ } =
  printf "%d - %s\n" (idx + 1) title;
  List.iter sections ~f:print_section

let array_get array idx =
  let len = Array.length array in
  if idx > len - 1 then None else Some array.(idx)

(* main *)

let build _ =
  Unix.mkdir_p output_dir;
  let parts = parse_parts @@ get_parts @@ () in
  parts_to_html parts;
  index_to_html parts;
  printf "done generating HTML files in dist/\n"

let main _ =
  let argv = Sys.get_argv () in
  let arg = array_get argv 1 in
  match arg with
  | None | Some "build" -> build ()
  | Some "watch" ->
      print_endline "building once first";
      build ();
      print_endline ("now watching " ^ book_dir);
      Watch.main [ book_dir; template_dir ] ~f:build
  | _ -> print_endline "usage: byexample <build|watch>"

let () = main ()
