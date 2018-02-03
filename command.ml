(*
**  Command - command execution (check Menhir files for the parser)
*)

open Debug
open Cell
open Sheet

(* comm - available commands for the spreadsheet scripts *)
type comm =
	| Upd of cellname * form		(* Update a cell's formula *)
	| Show of cellname				(* Show a cell's value *)
	| ShowAll						(* Show all cells *)



(*
**  Display commands (as text)
*)

(* comm_show - print a command's text on stdout
   @arg  c      Command to show [comm] *)
let comm_show c = match c with
	| Upd (c, f) -> begin
		ps (cell_name2string c);
		ps "=";
		show_form f
	end
	| Show c -> begin
		ps "Show(";
		ps (cell_name2string c);
		ps ")"
	end
	| ShowAll ->
		ps "ShowAll"



(*
**  Execute commands
*)

(* run_command - execute a command using the sheet as input
   @arg  c      Command to run [comm] *)
let run_command c = match c with
	| Show name -> begin
		sheet_recompute ();
		let (i, j) = cellname_to_coord name in
		eval_p_debug (fun () -> "Showing cell " ^ cell_name2string name);
		ps (cell_val2string (read_cell (i, j)));
		print_newline ()
	end
	| ShowAll -> begin
		eval_p_debug (fun () -> "Show All\n");
		sheet_recompute ();
		sheet_show ()
	end
	| Upd(name, f) ->
		let (i, j) = cellname_to_coord name in
		eval_p_debug (fun () -> "Update cell " ^ cell_name2string name ^ "\n");
		update_cell_formula (i, j) f

(* run_script - execute a list of commands
   @arg  c      Script to run [comm list] *)
let run_script cs =
	List.iter run_command cs
