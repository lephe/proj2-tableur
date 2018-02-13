%{
open Cell
open Command
%}

/* Lexeme list - associated regexs are in lexer.mll */

%token <int>	INT
%token <float>	NBR
%token <string>	CELLROW /* Cell rows are converted later */
%token <int>	SHEET

%token LPAREN RPAREN EQUAL SEMICOL DOT
%token SWITCHTO SHOW SHOWALL
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
	| SWITCHTO SHEET { SwitchTo($2) }
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
	| NBR { Cst (F $1) }
	| INT { Cst (I $1) }
	| cell { Cell (Cell.cell_name2coord $1) }
	| operator LPAREN forlist RPAREN { Op($1,$3) }
	| SHEET LPAREN formula SEMICOL formula RPAREN { Func($1,$3,$5) }

forlist:
	| formula { [$1] }
	| formula SEMICOL forlist { $1::$3 }
