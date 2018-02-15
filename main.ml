(*
**  Main - a script-directed spreadsheet application
*)

open Config
open Cell
open Sheet
open Command

(* Create a lexer stream from stdin input *)
let lexbuf = Lexing.from_channel stdin

(* parse - lex the stream, then parse it *)
let parse () =
	Parser.debut Lexer.token lexbuf

(* spreadsheet - main function (usually)
   Runs a script read from stdin, and prints the results on stdout *)
let spreadsheet () =
	let result = parse () in
	command_script result;
	flush stdout

(* Some check functions (for debugging purposes only) *)
let check_coords () =
	let check_name name =
		print_string name;
		print_string " => ";
		let i = snd (cell_name2coord (name, 1)) in
		print_int i;
		print_string " => ";
		print_string (fst (cell_coord2name (0, i)));
		print_newline ()
	in
	print_string "Checking multiple-letter column names:\n";
	check_name "Z";
	check_name "AA";
	check_name "BZ";
	check_name "ZZB";
	check_name "AAAA"

let _ =
	(* Parse configuration *)
	config_parse Sys.argv;
	(* Start application *)
	if config.checks then check_coords ();
	spreadsheet ()
