open Core

let () = 
  let two = Add.add_one 1 in
  printf "two: %d\n" two

module Thing = struct
  let add_two i = i + 2
end

let () = 
  let three = Thing.add_two 1 in
  printf "three: %d\n" three

module BiggerThing : sig
  val add_three : int -> int
end = struct
  let add_three i = i + 3
end

let () = 
  let four = BiggerThing.add_three 1 in
  printf "four: %d\n" four

module WrappingThing : sig
  val add_one : int -> int
  val add_three : int -> int
  val add_four : int -> int
end = struct
  include Add
  let add_three = BiggerThing.add_three

  open BiggerThing
  let add_four i = add_one @@ add_three @@ i
end

let () = 
  let five = WrappingThing.add_four 1 in
  printf "five: %d\n" five

module Nested = struct
  module NestedNested = struct
    let add_five i = i + 5
  end

  let add_six i = 1 + NestedNested.add_five i
end

let () = 
  let six = Nested.NestedNested.add_five 1 in
  let seven = Nested.add_six 1 in
  printf "six: %d\n" six;
  printf "seven: %d\n" seven;

module type SomeSignature = sig
  val i : int
end

module SomeModule1 : SomeSignature = struct
  let i = 1
end

module SomeModule2 = struct let i = 2 end

let () =
  let instance1 = (module SomeModule1 : SomeSignature) in
  let modules = [ instance1 ; (module SomeModule2) ] in
  let modules = modules @ [(module struct let i = 3 end)] in
  let module NNN = (val instance1 : SomeSignature) in 
  let instance2 = match List.last modules with Some x -> x | None -> failwith "impossible" in
  let module VVV = (val instance2 : SomeSignature) in
    printf "%d - %d\n" NNN.i VVV.i