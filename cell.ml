(*
**  Cell - representation of numbers, cells and formulas
*)

(*
**  Cell storage (usual types)
*)

type num =
	| F of float
	| I of int

(* Operators (functions) available in formulae *)
type oper =
	| Operator_Sum		(* Sum of all arguments [default 0] *)
	| Operator_Prod		(* Product of all arguments [default 1] *)
	| Operator_Avg		(* Numerical mean [default undefined] *)
	| Operator_Max		(* Maximal element [default undefined] *)
	| Operator_Min		(* Minimal element [default undefined] *)

(* Formula trees *)
type form =
	| Cst of num				(* Constant operand *)
	| Cell of (int * int)		(* Value of another cell *)
	| Op of oper * form list	(* Numerical operator *)
	| Func of int * form * form	(* Evaluation of sheet function *)

(* A set of cell coordinates. Set.Make creates a specialized ordered-set type
   using binary trees, provided a base type and a comparison function *)
module CellSet = Set.Make(struct
	type t = int * int
	let compare = Pervasives.compare
end)

(* Cells proper, using a record type *)
type cell = {
	mutable formula:	form;
	mutable value:		num option;
	mutable deps:		CellSet.t;
	mutable links:		CellSet.t;
}

(* A default cell. This is a unique object, and it will alias *)
let default_cell = {
	formula 	= Cst (I 0);
	value		= None;
	deps		= CellSet.empty;
	links		= CellSet.empty;
}



(*
**  Operation of the number type
*)

(* num_bop - apply a binary operation to a number type
   @arg  n		First operand [num]
   @arg  m		Second operand [num]
   @arg  fi		int-version of the function [int -> int]
   @arg  ff		float-version of the function [float -> float]
   @ret  Number result, converted to the proper type *)
let num_bop n m fi ff = match (n, m) with
	| (F f, F g) -> F (ff f g)
	| (F f, I i) | (I i, F f) -> F (ff f (float_of_int i))
	| (I i, I j) -> I (fi i j)

(* Usual arithmetic operations that return numbers *)
let num_add n m = num_bop n m (+) (+.)
let num_sub n m = num_bop n m (-) (-.)
let num_mul n m = num_bop n m ( * ) ( *. )
let num_div n m = num_bop n m (/) (/.)
let num_min n m = num_bop n m min min
let num_max n m = num_bop n m max max



(*
**  Operation on the data structures
*)

(* form_iter - iterate a function on all cells listed in a formula
   @arg  f		Formula to traverse
   @arg  iter	Iterated function [(int * int) -> unit] *)
let rec form_iter f iter = match f with
	| Cst _ -> ()
	| Cell(c) -> iter c
	| Op(_, fs) -> List.iter (fun f -> form_iter f iter) fs
	| Func(_, f1, f2) -> form_iter f1 iter; form_iter f2 iter



(*
**  The cellname type and associated conversions
**  (This type is used for parsing and displaying, but not internally.)
*)

(* Cell names manipulated by the parser, eg. ("B", 7) *)
type cellname = string * int

(* cell_name2coord - convert cell names to integer coordinates
   [cellname -> int * int]
   TODO: Support column names with several letters *)
let cell_name2coord (str, row) =
	let col = ref 0 in
	for i = 0 to String.length str - 1 do
		col := 26 * !col + (int_of_char str.[i] - 64)
	done;
	(row - 1, !col - 1)

(* cell_coord2name - convert integer coordinates to cell names
   [int * int -> cellname]
   TODO: Support column names with several letters *)
let cell_coord2name (i, j) : cellname =
	let length = ref 1 and col = ref j and power = ref 26 in
	(* First decide the length and turn "global j" into "j for this length" *)
	while !col >= !power do
		incr length;
		col := !col - !power;
		power := !power * 26
	done;
	(* Calculate all the characters with a base-26 decomposition *)
	let s = ref "" in
	for i = 1 to !length do
		let c = char_of_int (!col mod 26 + 65) in
		s := String.concat "" [ String.make 1 c; !s ];
		col := !col / 26
	done;
	(!s, i + 1)



(*
**  Conversion to strings and displaying
*)

(* string_of_cellname - cellnames converted to strings [cellname -> string] *)
let string_of_cellname (str, row) =
	str ^ (string_of_int row)

(* string_of_num - show numbers as strings [num -> string] *)
let string_of_num n = match n with
	| F f -> string_of_float f
	| I i -> string_of_int i

(* string_of_value - show values [number option -> string] *)
let string_of_value v = match v with
	| None -> "_"
	| Some n -> string_of_num n

(* string_of_oper - get operator names [oper -> string] *)
let string_of_oper oper = match oper with
	| Operator_Sum  -> "SUM"
	| Operator_Prod -> "MULT"
	| Operator_Avg  -> "AVERAGE"
	| Operator_Max  -> "MAX"
	| Operator_Min  -> "MIN"

(* string_of_list - map f on a list and concatenate with semicolons
   [('a -> string) -> 'a list -> string] *)
let rec string_of_list f l = match l with
	| [x] -> f x
	| x::xs -> f x ^ ";" ^ string_of_list f xs
	| _ -> failwith "form_list_toString: the list shouldn't be empty"

(* string_of_form - show formulas as strings [form -> string] *)
let rec string_of_form = function
	| Cell c ->
		let (str, row) = cell_coord2name c in
		str ^ (string_of_int row)
	| Cst n -> string_of_num n
	| Op(o,fl) ->
		(string_of_oper o) ^ "(" ^ string_of_list string_of_form fl ^ ")"
	| Func(s,f1,f2) ->
		"s" ^ (string_of_int s) ^ "(" ^ (string_of_form f1) ^ ";"
		^ (string_of_form f2) ^ ")"


(* Associated printing functions *)

let ps = print_string

let print_cellname c	= print_string(string_of_cellname c)
let print_value v		= print_string (string_of_value v)
let print_num n			= print_string (string_of_num n)
let print_oper o		= print_string (string_of_oper o)
let print_form f		= print_string (string_of_form f)

let rec print_list f = function
	| [x] -> f x
	| x::xs -> f x; ps ";"; print_list f xs
	| _ -> failwith "show_list: the list shouldn't be empty"
