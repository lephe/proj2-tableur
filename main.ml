(*
**  Main - a script-directed spreadsheet application
*)

open Config
open Cell
open Sheet
open Command

(* Create a lexer stream from stdin input *)
let lexbuf = Lexing.from_channel stdin

(* parse - lex the stream using Lexer.token, then parse it *)
let parse () =
	Parser.debut Lexer.token lexbuf

(* spreadsheet - main function
   Run a script read from stdin, and print the results on stdout *)
let spreadsheet () =
	let result = parse () in
	command_script result;
	flush stdout;
;;

let _ =
	(* Parse configuration *)
	config_parse Sys.argv;
	(* Start application *)
	spreadsheet()

(*
**  Additionnal code for name/coordinate verification - run it if you change
**  the cell_coord2name or cell_name2coord functions!
*)

(* let check_name name =
	print_string name;
	print_string " => ";
	let i = snd (cell_name2coord (name, 1)) in
	print_int i;
	print_string " => ";
	print_string (fst (cell_coord2name (0, i)));
	print_newline ()

let _ =
	check_name "A";
	check_name "Z";
	check_name "AA";
	check_name "AZ";
	check_name "BA";
	check_name "ZZ";
	check_name "AAA";
	check_name "ZZZ";
	check_name "AAAA";
	print_string "===\n" *)
