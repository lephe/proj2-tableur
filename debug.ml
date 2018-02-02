(*
**  Debug - conditional debugging facilities
*)

(* Debug flag - set to `true` to enable detailed debugging *)
let blabla = false

(* p_debug - Conditionally debug a string
   @arg  s      String to debug (printed only if blabla = true) [string] *)
let p_debug s = if blabla then print_string s else ()

(* eval_p_debug - Lazy conditional debugging
   @arg  f      A string generator to call if blabla = true [unit -> string] *)
let eval_p_debug f =
	if blabla then print_string (f ()) else ()
