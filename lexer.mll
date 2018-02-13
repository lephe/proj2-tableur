{
	open Parser;;
}

rule token = parse

	(* Ignore whitespaces *)
	| [' ' '\t' '\n'] { token lexbuf }

	(* Also ignore some comments *)
	| '#' [^ '\n']* { token lexbuf }

	(* Syntactic elements *)
	| eof { EOF }
	| '(' { LPAREN }
	| ')' { RPAREN }
	| '=' { EQUAL }
	| ';' { SEMICOL }
	| '.' { DOT }

    (* Program commands *)
	| "SwitchTo"	{ SWITCHTO }
	| "Show"		{ SHOW }
	| "ShowAll"		{ SHOWALL }

	(* Spreadsheet functions *)
	| "SUM"		{ SUM }
	| "MULT"	{ MULT }
	| "AVERAGE"	{ AVERAGE }
	| "MAX"		{ MAX }
	| "MIN"		{ MIN }

	(* Input values *)
	| 's'['0'-'9'] as s {
		let sub = String.sub s 1 (String.length s - 1) in
		SHEET (int_of_string sub) }
	| '-'? ['0'-'9']+ '.' ['0'-'9']* as s { NBR (float_of_string s) }
	| '-'? ['0'-'9']+ as s { INT (int_of_string s) }
	| ['A'-'Z']+ as s { CELLROW s }
