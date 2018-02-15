(*
**  Config - Command-line options
*)

type config_t = {
	(* Naive mode: evaluates the whole sheet each time a cell is printed. By
	   default, the program will perform lazy evaluation instead.
	   This option does *not* disable cycle detection and should be transparent
	   to the user. *)
	mutable naive: bool;
	(* Check mode: perform some basic checks at startup, before running the
	   application (intended for debugging purposes only ^^) *)
	mutable checks: bool;
}

(* Default options *)
let config = {
	naive	= false;
	checks	= false;
}

(* config_parse - parse command-line options and update the config *)
let config_parse argv =
	let config_parse_one opt = match opt with
		| "-naive"  -> config.naive  <- true
		| "-checks" -> config.checks <- true
		| _ -> print_string ("warning: unknown option " ^ opt ^ "\n")

	(* We need to ignore the first argument; I don't think I can use Array.iter
	   in this situation, so let's KISS *)
	in for i = 1 to Array.length argv - 1 do
		config_parse_one argv.(i)
	done
