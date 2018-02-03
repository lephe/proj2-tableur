{
  open Parser;;        (* le type "token" est défini dans parser.mli *)
(* ce n'est pas à vous d'écrire ce fichier, il est engendré automatiquement *)
}

rule token = parse    (* la "fonction" aussi s'appelle token .. *)
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
	| "Show"	{ SHOW }
	| "ShowAll"	{ SHOWALL }

	(* Spreadsheet functions *)
	| "SUM"		{ SUM }
	| "MULT"	{ MULT }
	| "AVERAGE"	{ AVERAGE }
	| "MAX"		{ MAX }
	| "MIN"		{ MIN }

	(* Input values *)
	| '-'? ['0'-'9']+ '.' ['0'-'9'] as s { NBR (float_of_string s) }
	| '-'? ['0'-'9']+ as s { INT (int_of_string s) }
	| ['A'-'Z']+ as s { CELLROW s }
