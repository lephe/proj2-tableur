(*
**  Sheet - an array of cells
*)

open Cell
open Debug

(* Sheet size: rows, columns *)
let size = (20, 10)
(* Sheet contents: aliased for now because the record object is shared *)
let thesheet = Array.make_matrix (fst size) (snd size) default_cell

(* read_cell - Get a pointer to the cell's record
   @arg  (i,j)  Coordinates of the requested cell [int * int]
   @ret  Associated record [cell] *)
let read_cell (i, j) =
	thesheet.(i).(j)

(* sheet_link - Create a dependency link from (i, j) to (k, l)
   [int * int -> int * int -> unit] *)
let sheet_link (i, j) (k, l) =
	thesheet.(i).(j).deps  <- CellSet.add (k, l) thesheet.(i).(j).deps;
	thesheet.(k).(l).links <- CellSet.add (i, j) thesheet.(k).(l).links

(* sheet_unlink - Remove a dependency link of (i, j) towards (k, l)
   [int * int -> int * int -> unit] *)
let sheet_unlink (i, j) (k, l) =
	thesheet.(i).(j).deps  <- CellSet.remove (k, l) thesheet.(i).(j).deps;
	thesheet.(k).(l).links <- CellSet.remove (i, j) thesheet.(k).(l).links

(* update_cell_formula - Change the formula of a cell record
   @arg  (i,j)  Coordinates of the requested cell [int * int]
   @arg  f      New formula for this cell [form] *)
let update_cell_formula (i, j) f =
	let c = read_cell (i, j) in
	(* First unlink all the dependencies related to the old formula *)
	form_iter c.formula (sheet_unlink (i, j));
	(* Then set the new formula and link all the new dependencies *)
	c.formula <- f;
	form_iter f (sheet_link (i, j));
	(* Invalidate the cell's links' value *)
	CellSet.iter (fun (i, j) -> thesheet.(i).(j).value <- None) c.links;
	(* Also invalidate the cell value, but not if it's a constant *)
	match f with
	| Cst n -> c.value <- Some n;
	| _ -> c.value <- None

(* update_cell_value - Change the value of a cell record
   @arg  (i,j)  Coordinates of the requested cell [int * int]
   @arg  v      New value for this cell [number] *)
let update_cell_value (i, j) (v: number option) =
	thesheet.(i).(j).value <- v



(*
**  Evaluation of formulae
*)

(* eval_form - Evaluate formulas using the current sheet as input
   @arg  fo     Formula to evaluate [form]
   @arg  s		Set of already-evaluated cells [CellSet]
   @ret  Value for this sheet, None in case of cycles [number option] *)
let rec eval_form fo (s: CellSet.t) : number option = match fo with
	| Cst n -> Some n
	| Cell (p, q) -> eval_cell_cycle (p, q) s
	| Op(o, fs) -> begin
		(* If a cycle is detected during operand evaluation, propagate None *)
		let opts = List.map (fun f -> eval_form f s) fs in
		if List.exists ((=) None) opts then None else
		(* Otherwise, evaluate the function *)
		let vs = List.map (function | (Some n) -> n | None -> 0.) opts in
		match o with
		| Operator_Sum  -> Some (List.fold_left ( +. ) 0. vs)
		| Operator_Prod -> Some (List.fold_left ( *. ) 1. vs)
		| Operator_Avg  -> Some (List.fold_left ( +. ) 0. vs /.
			float_of_int (List.length vs))
		| Operator_Max  -> Some (List.fold_left max (List.hd vs) vs)
		| Operator_Min  -> Some (List.fold_left min (List.hd vs) vs)
		end

(* eval_cell_cycle - Evaluate, but check cycles
   If no cycle happens, the value of the evaluated cell is updated to Some n.
   @arg  (i,j)  Coordinates of requested cell [int * int]
   @ret  Value of the cell; None if a cycle is detected [number options] *)
and eval_cell_cycle (i, j) (s: CellSet.t) =

	(* Check cycles, returning None on error *)
	if CellSet.mem (i, j) s then begin
		eval_p_debug (fun () -> "Cycle detected during evaluation of cell "
			^ string_of_cellname (cell_coord2name (i, j)) ^ "!\n");
		None
	end else

	(* If everything's good, try evaluating further *)
	let c = read_cell (i, j) in
	match c.value with
	| None ->
		eval_p_debug (fun () -> "Evaluating the formula of cell " ^
			string_of_cellname (cell_coord2name (i, j)) ^ "\n");
		let v = eval_form c.formula (CellSet.add (i, j) s) in
		update_cell_value (i, j) v;
		v
	| Some v -> Some v

(* eval_cell - Fetch, or evaluate and store, the value of a cell
   Wrapper for eval_cell_cycle that calls with an empty set of alread-evaluated
   cells. *)
and eval_cell (i, j) =
	eval_cell_cycle (i, j) CellSet.empty




(*
**  Sheet operations
*)

(* sheet_iter - Iterate a function on all the cells
   @arg  f      Function to iterate [int * int -> unit] *)
let sheet_iter f =
	for i = 0 to (fst size - 1) do
	for j = 0 to (snd size - 1) do
		f (i, j)
	done; done

(* sheet_init - Initialize the sheet with empty cells
   We have to do this because Array.make_matrix linked the *same* record object
   in every cell, which is inconvenient *)
let sheet_init () =
	let init_cell (i, j) =
		(* Create a *new* record each time *)
		let c = {
			value		= None;
			formula		= Cst 0.;
			deps		= CellSet.empty;
			links		= CellSet.empty;
		} in
		thesheet.(i).(j) <- c
	in sheet_iter init_cell

(* Now perform the initialization *)
let _ = sheet_init ()

(* sheet_show - Print the contents of the sheet on stdout *)
let sheet_show () =
	let g (i, j) =
		(* Print a newline before each sheet row *)
		if j = 0 then print_newline () else ();
		print_value (eval_cell (i, j));
		print_string " "
	in
	sheet_iter g;
	print_newline()

(* sheet_recompute - Invalidate and recompute the whole sheet *)
let sheet_recompute () =
	sheet_iter (fun (i, j) -> update_cell_value (i, j) None);
	sheet_iter eval_cell
