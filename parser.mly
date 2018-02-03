%{
open Cell
open Command
%}

/* Lexeme list - associated regexs are in lexer.mll */

%token <int> INT		/* le lexème INT a un attribut entier */
%token <float> NBR		/* le lexème NBR a un attribut flottant */
%token <string> CELLROW	/* le lexème CELLROW a un attribut, de type string */

%token LPAREN RPAREN EQUAL SEMICOL DOT
%token SHOW SHOWALL
%token SUM MULT AVERAGE MAX MIN
%token EOF

  /*
%start singlecomm
%type <Command.comm> singlecomm
    */

%start debut
%type <Command.comm list> debut

%%
debut:
	| clist EOF { $1 }

clist:
	| singlecomm clist { $1::$2 }
	| singlecomm { [$1] }

singlecomm:
	| cell EQUAL formula { Upd($1,$3) }
	| SHOW cell { Show($2) }
	| SHOWALL { ShowAll }

cell:
	| CELLROW INT { ($1,$2) }

operator:
	| SUM		{ Operator_Sum }
	| MULT		{ Operator_Prod }
	| AVERAGE	{ Operator_Avg }
	| MAX		{ Operator_Max }
	| MIN		{ Operator_Min }

formula:
	| NBR { Cst $1 }
	| INT { Cst (float $1) }
	| cell { Cell (Cell.cellname_to_coord $1) }
	| operator LPAREN forlist RPAREN { Op($1,$3) }

forlist:
	| formula { [$1] }
	| formula SEMICOL forlist { $1::$3 }
