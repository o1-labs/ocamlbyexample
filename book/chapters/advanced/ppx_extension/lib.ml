open Ppxlib

(*
let located_label_expr expr =
  let loc = expr.pexp_loc in
  [%expr Stdlib.( ^ ) [%e expr] (Stdlib.( ^ ) ": " Stdlib.__LOC__)]

let located_label_string ~loc str =
  [%expr
    Stdlib.( ^ )
      [%e Exp.constant ~loc (Const.string (str ^ ": "))]
      Stdlib.__LOC__]
*)

(* let with_label = ()

let with_label ~loc =
  [%expr with_label] *)

let expand_function ~loc ~path:_ name expr =
  let open Ast_helper in
  let open Ast_builder.Default in
  let open Asttypes in
  [%stri
    let [%p Pat.var ~loc (Located.mk ~loc name)] =
      [%e expr]]

(*  
> The type for Ast_pattern is defined as ('a, 'b, 'c) t where 'a is the type of AST nodes that are matched, 'b is the type of the values you're extracting from the node as a function type and 'c is the return type of that last function. 
*)
let extension =
  (* label ->
    'context Extension.Context.t ->
    (payload, 'a, 'context) Ast_pattern.t ->
    (loc:Ppxlib.Location.t -> path:label -> 'a) -> Extension.t
*)
  Extension.declare
    (* the name of the ppx extension *)
    "thingify"
    (* the node we're trying to produce *)
    Extension.Context.structure_item
    (* sort of a regex to figure out what to use *)
    Ast_pattern.(
      pstr
        ( pstr_value nonrecursive
            (value_binding ~pat:(ppat_var __) ~expr:__ ^:: nil)
            (* we create lists using the `^::` operator. Here our list terminates with `nil`, it only has a single item (of type `pstr_value`) *)
        ^:: nil ))
    (* parser function *)
    expand_function

(* -------- *)

let rec snarkydef_inject ~local ~loc ~arg ~name expr =
  match expr.pexp_desc with
  | Pexp_fun (lbl, default, pat, body) ->
      { expr with
        pexp_desc =
          Pexp_fun
            (lbl, default, pat, snarkydef_inject ~local ~loc ~arg ~name body)
      }
  | Pexp_newtype (typname, body) ->
      { expr with
        pexp_desc =
          Pexp_newtype (typname, snarkydef_inject ~local ~loc ~arg ~name body)
      }
  | Pexp_function _ ->
      Location.raise_errorf ~loc:expr.pexp_loc
        "%%snarkydef currently doesn't support 'function'"
  | _ ->
      failwith "yo"

let expand_function ~loc:_ ~path:_ ~arg:_ _label _expr = (* 
  let open Ast_helper in
  let open Ast_builder.Default in
  let open Asttypes in
 [%stri
  let [%p Pat.var ~loc (Located.mk ~loc "snarkydef")] =
    [%e snarkydef_inject ~local ~loc ~arg ~name: "snarkydef" expr]] *)
    failwith "todo"

let snarkydef =
  Extension.declare_with_path_arg "snarkydef" Extension.Context.structure_item
    Ast_pattern.(
      pstr
        ( pstr_value nonrecursive
            (value_binding ~pat:(ppat_var __) ~expr:__ ^:: nil)
        ^:: nil ))
    expand_function

let () =
  Driver.register_transformation ~rules:[Context_free.Rule.extension extension; Context_free.Rule.extension snarkydef] "my_transformation"
