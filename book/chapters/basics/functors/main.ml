open Core

module type Thing = sig
  type t
  val a : t
  val b : t -> string 
end

module Make (Animal : Thing)
