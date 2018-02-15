(*
**  Command - command execution (see lexer.mll and parser.mly for the parser)
*)

open Config
open Cell
open Debug
open Sheet

(* comm - available commands for spreadsheet scripts *)
type comm =
	| Upd of cellname * form		(* Update a cell's formula *)
	| SwitchTo of int				(* Switch to a different sheet *)
	| Show of cellname				(* Show a cell's value *)
	| ShowAll						(* Show all cells *)



(*
**  Command execution
*)

(* command_run - execute a command using the sheet as input [comm -> unit] *)
let command_run c = match c with

	| Show name ->
		(* Recompute the whole sheet if in naive mode *)
		if config.naive then sheet_recompute ();

		let (i, j) = cell_name2coord name in
		eval_p_debug (fun () -> "Showing cell " ^string_of_cellname name^"\n");
		print_value (eval_cell (i, j));
		print_newline ()

	| SwitchTo s ->
		sheet_switch s

	| ShowAll ->
		(* Recompute the whole sheet if in naive mode *)
		if config.naive then sheet_recompute ();

		eval_p_debug (fun () -> "Show All\n");
		sheet_show ()

	| Upd(name, f) ->
		let (i, j) = cell_name2coord name in
		update_cell_formula (i, j) f

(* command_script - execute a list of commands [comm list -> unit] *)
let command_script =
	List.iter command_run



(*
**  String conversion and printing
*)

(* print_command - exactly what you expect [comm -> unit] *)
let print_command c = match c with
	| Upd (c, f) ->
		print_cellname c;
		print_string "=";
		print_form f
	| SwitchTo s ->
		print_string "SwitchTo(";
		print_int s;
		print_string ")";
	| Show c ->
		print_string "Show(";
		print_cellname c;
		print_string ")";
	| ShowAll ->
		print_string "ShowAll"
