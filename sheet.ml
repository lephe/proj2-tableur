(*
**  Sheet - an array of cells
*)

open Cell
open Debug

(* Sheet size: rows, columns; and sheet count *)
let size = (20, 10)
let sheet_count = 10

(* sheet_create - create a sheet of a given size
   @arg  (rows,cols)  Size of the sheet [int * int]
   @arg  _            Sheet index (provided by Array.init) [int] *)
let sheet_create (rows, cols) _ =

	let init_matrix rows cols func =
		let init_row i = Array.init cols (func i) in
		Array.init rows init_row

	in let one i j =
		(* Create a *new* record each time *)
		let c = {
			value		= None;
			formula		= Cst (I 0);
			deps		= CellSet.empty;
			links		= CellSet.empty;
		} in c

	in init_matrix rows cols one

(* Sheet array (this is the actual data storage) *)
let sheet_array = Array.init sheet_count (sheet_create size)
(* Currently selected sheet *)
let sheet_current = ref 0

(* read_cell - get a pointer to the cell's record
   @arg  (i,j)  Coordinates of the requested cell [int * int]
   @ret  Associated record [cell] *)
let read_cell (i, j) =
	sheet_array.(!sheet_current).(i).(j)

(* sheet_switch - switch to another sheet [int -> unit] *)
let sheet_switch s =
	if s < 0 || s >= sheet_count then
		failwith ("sheet_switch: requested sheet (" ^ (string_of_int (s + 1))
			^ ") is out of bounds")
	else sheet_current := s

(* sheet_link - create a dependency linking cell (i, j) to cell (k, l)
   [int * int -> int * int -> unit] *)
let sheet_link (i, j) (k, l) =
	let src = read_cell (i, j)
	and dst = read_cell (k, l) in
	src.deps  <- CellSet.add (k, l) src.deps;
	dst.links <- CellSet.add (i, j) dst.links

(* sheet_unlink - remove a dependency linking cell (i, j) to cell (k, l)
   [int * int -> int * int -> unit] *)
let sheet_unlink (i, j) (k, l) =
	let src = read_cell (i, j)
	and dst = read_cell (k, l) in
	src.deps  <- CellSet.remove (k, l) src.deps;
	dst.links <- CellSet.remove (i, j) dst.links

(* update_cell_formula - change the formula of a cell record
   @arg  (i,j)  Coordinates of the requested cell [int * int]
   @arg  f      New formula for this cell [form] *)
let update_cell_formula (i, j) f =
	let c = read_cell (i, j) in

	(* First unlink all the dependencies related to the old formula *)
	form_iter c.formula (sheet_unlink (i, j));

	(* Then set the new formula and link to all the new dependencies *)
	c.formula <- f;
	form_iter f (sheet_link (i, j));

	(* Recursively invalidate the cell's links' value *)
	let rec inval (i, j) =
		let cell = read_cell (i, j) in
		(* Prevent infinite recursion *)
		if cell.value <> None then begin
			cell.value <- None;
			CellSet.iter inval cell.links
		end
	in inval (i, j);

	(* If the new formula is a constant, load the value directly instead of
	   deferring evaluation to the lazy stage (execution of Show* commands) *)
	match f with
	| Cst n -> c.value <- Some n
	| _ -> ()

(* update_cell_value - change the value of a cell record
   @arg  (i,j)  Coordinates of the requested cell [int * int]
   @arg  v      New value for this cell [number] *)
let update_cell_value (i, j) (v: num option) =
	(read_cell (i, j)).value <- v



(*
**  Evaluation of formulas
*)

(* eval_form - evaluate formulas using the current sheet as input
   @arg  fo     Formula to evaluate [form]
   @arg  s		Set of already-evaluated cells [CellSet]
   @ret  Value for this sheet, None in case of cycles [number option] *)
let rec eval_form fo (s: CellSet.t) : num option = match fo with

	(* Easy situations *)
	| Cst n -> Some n
	| Cell (p, q) -> eval_cell_cycle (p, q) s

	| Op(o, fs) -> begin
		(* If a cycle is detected during operand evaluation, propagate None *)
		let opts = List.map (fun f -> eval_form f s) fs in
		if List.exists ((=) None) opts then None else
		(* Otherwise, evaluate the function *)
		let vs = List.map (function | (Some n) -> n | None -> (I 0)) opts in

		match o with
		| Operator_Sum  -> Some (List.fold_left num_add (I 0) vs)
		| Operator_Prod -> Some (List.fold_left num_mul (I 1) vs)
		| Operator_Avg  ->
			let sum = List.fold_left num_add (I 0) vs
			and len = I (List.length vs)
			in Some (num_div sum len)
		| Operator_Max  -> Some (List.fold_left max (List.hd vs) vs)
		| Operator_Min  -> Some (List.fold_left min (List.hd vs) vs)
		end

	| Func(sheet, f1, f2) ->
		(* Forbid self-evaluation *)
		if sheet = !sheet_current then
			failwith "eval_form: cannot call a sheet from inside itself";
		(* First evaluate the parameters and rule out cycles - note that we do
		   not detect cycles in *sheet-function calls* *)
		let v1 = eval_form f1 s and v2 = eval_form f2 s in

		match (v1, v2) with
		| (None, _) | (_, None) -> None
		| (Some n1, Some n2) ->
			(* Remember current sheet and switch to sheet s *)
			let old = !sheet_current in
			sheet_switch sheet;
			update_cell_formula (0, 0) (Cst n1);
			update_cell_formula (1, 0) (Cst n2);
			(* Start evaluation with a *new empty* visited cell set - we are in
			   an other temporary sheet! *)
			let v3 = eval_cell (2, 0) in
			(* Transfer the result to the original sheet *)
			sheet_switch old;
			v3

(* eval_cell_cycle - evaluate, but heed for cycles
   If no cycle happens, the value of the evaluated cell is updated to Some n.
   @arg  (i,j)  Coordinates of requested cell [int * int]
   @ret  Value of the cell; None if a cycle is detected [number option] *)
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

(* eval_cell - fetch, or evaluate and store, the value of a cell *)
and eval_cell (i, j) =
	eval_cell_cycle (i, j) CellSet.empty



(*
**  Sheet operations
*)

(* sheet_iter - iterate function on all cells [(int * int -> unit) -> unit] *)
let sheet_iter f =
	for i = 0 to (fst size - 1) do
	for j = 0 to (snd size - 1) do
		f (i, j)
	done; done

(* sheet_show - print the contents of the sheet on stdout [unit -> unit] *)
let sheet_show () =
	let g (i, j) =
		(* Print a newline before each sheet row *)
		if j = 0 then print_newline () else ();
		print_value (eval_cell (i, j));
		print_string " "
	in
	sheet_iter g;
	print_newline()

(* sheet_recompute - invalidate and recompute the whole sheet [unit -> unit] *)
let sheet_recompute () =
	sheet_iter (fun (i, j) -> update_cell_value (i, j) None);
	sheet_iter eval_cell
