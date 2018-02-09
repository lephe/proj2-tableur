(*
**  Sheet - an array of cells
*)

open Cell

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
	(* First unlink all the dependencies related to the old formula *)
	form_iter thesheet.(i).(j).formula (sheet_unlink (i, j));
	(* Then set the new formula *)
	thesheet.(i).(j).formula <- f;
	(* Finally, link all the new dependencies *)
	form_iter f (sheet_link (i, j))

(* update_cell_value - Change the value of a cell record
   @arg  (i,j)  Coordinates of the requested cell [int * int]
   @arg  v      New value for this cell [number] *)
let update_cell_value (i, j) (v: number option) =
	thesheet.(i).(j).value <- v



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
		let c = read_cell (i, j) in
		print_value (c.value);
		print_string " "
	in
	sheet_iter g;
	print_newline()



(*
**  Evaluation of formulae
*)

(* eval_form - Evaluate formulas using the current sheet as input
   @arg  fo     Formula to evaluate [form]
   @ret  Value for this sheet [number] *)
let rec eval_form fo : number = match fo with
	| Cst n -> n
	| Cell (p, q) -> eval_cell (p, q)
	| Op(o, fs) -> begin
		let vs = List.map eval_form fs in match o with
		| Operator_Sum  -> List.fold_left ( +. ) 0. vs
		| Operator_Prod -> List.fold_left ( *. ) 1. vs
		| Operator_Avg  -> List.fold_left ( +. ) 0. vs /.
			float_of_int (List.length vs)
		| Operator_Max  -> List.fold_left max (List.hd vs) vs
		| Operator_Min  -> List.fold_left min (List.hd vs) vs
		end

(* eval_cell - Fetch, or evaluate and store, the value of a cell
   Ater this call, the cell always has a value of Some f.
   @arg  (i,j)  Coordinates of requested cell [int * int]
   @ret  Value of the cell [number] *)
and eval_cell (i, j) =
	let c = read_cell (i, j) in
	match c.value with
	| None ->
		let v = eval_form c.formula in
		update_cell_value (i, j) (Some v);
		v
	| Some v -> v

(* sheet_invalidate - Invalidate all computed values in cells *)
let sheet_invalidate () =
	let f (i, j) = update_cell_value (i, j) None in
	sheet_iter f

(* sheet_update - Make sure the formulae and values are coherent
   If there has been any update since the last call to this function,
   invalidates the whole sheet and recalculates all the values. *)
let sheet_recompute () =
	sheet_invalidate ();
	sheet_iter eval_cell
