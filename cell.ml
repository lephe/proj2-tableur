(*
**  Cell - representation of numbers, cells and formulas
*)

(*
**  Cell storage (usual types)
*)

type number = float

(* Operators (functions) available in formulae *)
type oper =
	| Operator_Sum		(* Sum of all arguments [default 0] *)
	| Operator_Prod		(* Product of all arguments [default 1] *)
	| Operator_Avg		(* Numerical mean [default undefined] *)
	| Operator_Max		(* Maximal element [default undefined] *)
	| Operator_Min		(* Minimal element [default undefined] *)

(* Formula trees *)
type form =
	| Cst of number				(* Constant operand *)
	| Cell of (int * int)		(* Value of another cell *)
	| Op of oper * form list	(* Numerical operator *)

(* A set of cell coordinates. Set.Make creates a specialized ordered-set type
   using binary trees, provided a base type and a comparison function *)
module CellSet = Set.Make(struct
	type t = int * int
	let compare = Pervasives.compare
end)

(* Cells proper, using a record type *)
type cell = {
	mutable formula:	form;
	mutable value:		number option;
	mutable deps:		CellSet.t;
	mutable links:		CellSet.t;
}

(* A default cell. This is a unique object, and it will alias *)
let default_cell = {
	formula 	= Cst 0.;
	value		= None;
	deps		= CellSet.empty;
	links		= CellSet.empty;
}



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
	if String.length str > 1 then
		failwith "cell_name2coord : désolé, je ne sais pas faire"
	else (row - 1, int_of_char str.[0] - 65)

(* cell_coord2name - convert integer coordinates to cell names
   [int * int -> cellname]
   TODO: Support column names with several letters *)
let cell_coord2name (i, j) : cellname =
	if j > 25 then
		failwith "cell_coord2name : cela ne devrait pas se produire"
	else (String.make 1 (char_of_int (j + 65)), i + 1)



(*
**  Conversion to strings and displaying
*)

(* string_of_cellname - cellnames converted to strings [cellname -> string] *)
let string_of_cellname (str, row) =
	str ^ (string_of_int row)

(* string_of_number - show numbers as strings [number -> string] *)
let string_of_number n =
	string_of_float n

(* string_of_value - show values [number option -> string] *)
let string_of_value v = match v with
	| None -> "_"
	| Some n -> string_of_number n

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
  | Cst n -> string_of_float n
  | Op(o,fl) ->
     begin
       (string_of_oper o) ^ "(" ^ string_of_list string_of_form fl ^ ")"
     end

(* Associated printing functions *)

let ps = print_string

let print_cellname c	= print_string(string_of_cellname c)
let print_value v		= print_string (string_of_value v)
let print_number n		= print_string (string_of_number n)
let print_oper o		= print_string (string_of_oper o)
let print_form f		= print_string (string_of_form f)

let rec print_list f = function
	| [x] -> f x
	| x::xs -> f x; ps ";"; print_list f xs
	| _ -> failwith "show_list: the list shouldn't be empty"

