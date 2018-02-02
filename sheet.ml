(*
**  Sheet - an array of cells
*)

open Cell

(* (Hardcoded) sheet size: rows, columns, and sheet contents *)
let size = (20, 10)
let thesheet = Array.make_matrix (fst size) (snd size) default_cell

(* read_cell - Get a pointer to the cell's record
   @arg  (i,j)  Coordinates of the requested cell [int * int]
   @ret  Associated record [cell] *)
let read_cell (i, j) =
	thesheet.(i).(j)

(* update_cell_formula - Change the formula of a cell record
   @arg  (i,j)  Coordinates of the requested cell [int * int]
   @arg  f      New formula for this cell [form] *)
let update_cell_formula (i, j) f =
	thesheet.(i).(j).formula <- f

(* update_cell_value - Change the value of a cell record
   @arg  (i,j)  Coordinates of the requested cell [int * int]
   @arg  v      New value for this cell [number] *)
let update_cell_value (i, j) (v: number option) =
	thesheet.(i).(j).value <- v



(*
**  Sheet operations
*)

(* sheet_iter - Iterate a function on the whole sheet
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
		let c = { value = None; formula = Cst 0. } in
		thesheet.(i).(j) <- c
	in sheet_iter init_cell

(* Now perform the initialization *)
let _ = sheet_init ()

(* sheet_show - Print the contents of the sheet on stdout *)
let sheet_show () =
	let g (i, j) = begin
		(* Print a newline before each sheet row *)
		if j = 0 then print_newline () else ();
		let c = read_cell (i, j) in
		print_string (cell_val2string c);
		print_string " "
    end in
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
		| S -> List.fold_left ( +. ) 0. vs
		| M -> List.fold_left ( *. ) 1. vs
		| A -> List.fold_left ( +. ) 0. vs /. float_of_int (List.length vs)
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

(* sheet_recompute - Recompute the values of all the cells in the sheet *)
let sheet_recompute () =
	sheet_invalidate ();
	sheet_iter eval_cell
