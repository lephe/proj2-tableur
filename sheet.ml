(*
**  Sheet - an array of cells
*)

open Cell

(* (Hardcoded) sheet size: rows, columns, and sheet contents *)
let size = (20, 10)
let thesheet = Array.make_matrix (fst size) (snd size) default_cell

(* read_cell - Get a pointer to the cell's record
   @arg  co     Coordinates of the requested cell [int * int]
   @ret  Associated record [cell] *)
let read_cell co =
	thesheet.(fst co).(snd co)

(* update_cell_formula - Change the formula of a cell record
   @arg  co     Coordinates of the requested cell [int * int]
   @arg  f      New formula for this cell [form] *)
let update_cell_formula co f =
	thesheet.(fst co).(snd co).formula <- f

(* update_cell_value - Change the value of a cell record
   @arg  co     Coordinates of the requested cell [int * int]
   @arg  v      New value for this cell [number] *)
let update_cell_value co (v: number option) =
	thesheet.(fst co).(snd co).value <- v

(* sheet_iter - Iterate a function on the whole sheet
   @arg  f      Function to iterate [int -> int -> unit] *)
let sheet_iter f =
	for i = 0 to (fst size - 1) do
	for j = 0 to (snd size - 1) do
		f i j
    done; done



(* initialisation du tableau : questions un peu subtiles de partage,
 * demandez autour de vous si vous ne comprenez pas pourquoi cela est
 * nécessaire.  Vous pouvez ne pas appeler la fonction ci-dessous,
 * modifier une case du tableau à l'aide de update_cell_formula, et
 * regarder ce que ça donne sur le tableau : cela devrait vous donner
 * une piste *)
let init_sheet () =
  let init_cell i j =
    let c = { value = None; formula = Cst 0. } in
    thesheet.(i).(j) <- c
  in
  sheet_iter init_cell

(* on y va, on initialise *)
let _ = init_sheet ()


(* affichage rudimentaire du tableau *)

let show_sheet () =
  let g i j =
    begin
       (* aller à la ligne en fin de ligne *)
      if j = 0 then print_newline() else ();
      let c = read_cell (i,j) in
      print_string (cell_val2string c);
      print_string " "
    end
  in
  sheet_iter g;
  print_newline()




(*** Evaluation of formulae ***)

(* invalidate_sheet - Invalidate all computed values in cells *)
let invalidate_sheet () =
	let f i j = update_cell_value (i, j) None in
	sheet_iter f

(* eval_form - Evaluate formulas using the current sheet as input
   @arg  fo     Formula to evaluate [form]
   @ret  Value for this sheet [number] *)
let rec eval_form fo : number = match fo with
	| Cst n -> n
	| Cell (p, q) -> eval_cell p q
	| Op(o, fs) -> begin
		let vs = List.map eval_form fs in match o with
		| S -> List.fold_left ( +. ) 0. vs
		| M -> List.fold_left ( *. ) 1. vs
		| A -> List.fold_left ( +. ) 0. vs /. float_of_int (List.length vs)
		end

(* eval_cell - Fetch, or evaluate and store, the value of a cell
   Ater this call, the cell always has a value of Some f.
   @arg  i      First cell coordinate [int]
   @arg  j      Second cell coordinate [int] *)
and eval_cell i j =
	let c = read_cell (i, j) in
	match c.value with
	| None ->
		let v = eval_form c.formula in
		update_cell_value (i, j) (Some v);
		v
	| Some v -> v

(* recompute_sheet - Recompute the values of all the cells in the sheet *)
let recompute_sheet () =
	invalidate_sheet ();
	sheet_iter eval_cell
