open Core_kernel
open Js_of_ocaml

let _ =
  Js.export "myLib"
    (object%js (_self)
      method add x y = x + y

      val myVal = 3

      method hello (name: Js.js_string Js.t) : (Js.js_string Js.t) = 
        let name = Js.to_string name in 
        let hello_name = "hello " ^ name in
        Js.string hello_name

      method typedArray _ =
         let init_typed_array = Js.Unsafe.js_expr
            {js|(function() {
              var buf = new Uint8Array(2);
              buf[0] = 1;
              return buf;
            })|js}
          in
          let typed_array = Js.Unsafe.fun_call init_typed_array [||] in
          let typed_array = Js_of_ocaml.Typed_array.String.of_uint8Array typed_array in
          String.iter ~f:(fun (x:char) -> printf "%d\n" (int_of_char x)) typed_array
     end)
