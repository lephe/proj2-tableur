(*
**  Debug - conditional debugging facilities
*)

(* Debug flag - set to `true` to enable detailed debugging *)
let blabla = false

(* p_debug - print a string if blabla = true [string -> unit] *)
let p_debug s =
	if blabla then print_string s

(* eval_p_debug - lazily print a string if blabla = true
   [(unit -> string) -> unit]
   Avoids evaluating the string when blabla = false (for performance). *)
let eval_p_debug f =
	if blabla then print_string (f ())
