(*
**  Command - command execution (see lexer.mll and parser.mly for the parser)
*)

open Cell
open Debug
open Sheet

(* comm - available commands for spreadsheet scripts *)
type comm =
	| Upd of cellname * form		(* Update a cell's formula *)
	| Show of cellname				(* Show a cell's value *)
	| ShowAll						(* Show all cells *)



(*
**  Conversion and printing
*)

(* print_command - Exactly what you expect [comm -> unit] *)
let print_command c = match c with
	| Upd (c, f) ->
		print_cellname c;
		print_string "=";
		print_form f
	| Show c ->
		print_string "Show(";
		print_cellname c;
		print_string ")";
	| ShowAll ->
		print_string "ShowAll"



(*
**  Execute commands
*)

(* command_run - execute a command using the sheet as input [comm -> unit] *)
let command_run c = match c with

	| Show name ->
		sheet_recompute ();
		let (i, j) = cell_name2coord name in
		eval_p_debug (fun () -> "Showing cell " ^ string_of_cellname name);
		print_string (string_of_value (read_cell (i, j)).value);
		print_newline ()

	| ShowAll ->
		eval_p_debug (fun () -> "Show All\n");
		sheet_recompute ();
		sheet_show ()

	| Upd(name, f) ->
		let (i, j) = cell_name2coord name in
		eval_p_debug (fun () -> "Update " ^ string_of_cellname name ^ "\n");
		update_cell_formula (i, j) f

(* command_script - execute a list of commands [comm list -> unit] *)
let command_script commands =
	List.iter command_run commands
