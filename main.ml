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
