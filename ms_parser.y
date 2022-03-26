%{


#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>	
#include "mslib.h"	
#include "cgen.c"


extern int yylex(void);
extern int line_num;
%}

%union
{
	char* crepr;
}

%token <crepr> IDENT
%token <crepr> NUMBER
%token <crepr> STRING
%token <crepr> VOID
%token <crepr> BOOL

%token KW_START
%token KW_CONST
%token KW_VAR
%token KW_VOID
%token KW_NUMBER
%token KW_STRING
%token KW_FUNCTION
%token KW_BOOL
%token KW_FOR

%token KW_NUM
%token KW_REAL
%token KW_IF
%token KW_THEN
%token KW_ELSE
%token KW_WHILE

%token KW_FALSE
%token KW_RETURN
%token KW_CONTINUE
%token KW_NULL
%token KW_BREAK
%token KW_TRUE

%token READSTRING
%token READNUMBER
%token WRITESTRING
%token WRITENUMBER

%token LEFT_CUR_BRACKET 
%token RIGHT_CUR_BRACKET 
%token SEMICOLON 
%token DOT
%token LEFT_PARENTHESIS 
%token RIGHT_PARENTHESIS 
%token COMMA 
%token ARROW
%token LEFT_SQ_BRACKET 
%token RIGHT_SQ_BRACKET 

%token ASSIGNMENT
%token ASSIGN_INC
%token ASSIGN_DEC
%token ASSIGN_MULT
%token ASSIGN_DIV
%token ASSIGN_REM
%token ASSIGN_CON
%token OP_COLON
%token ERROR_MESSAGE
%token OP_PWR

%left OP_OR
%left OP_AND
%left OP_EQ OP_NE OP_LT OP_LTE
%left OP_PLUS OP_MINUS
%left OP_MULT OP_DIV OP_REM
%right OP_NOT


%token ASSIGN

%start program

%type <crepr> decl_list body decl 
%type <crepr> const_decl_list const_decl_list_item decl_list_item_id  const_decl
%type <crepr> type_spec
%type <crepr> expr
%type <crepr> prefunc_s WNumber WString
%type <crepr> var_decl_body var_decl_list var_decl_init
%type <crepr> statement_list statement
%type <crepr> function_s assi_s if_s ife_s  while_s return_s break_s continue_s for_s
%type <crepr>    fun_decl func_call
%type <crepr> func_param
%%

program: decl_list KW_FUNCTION KW_START LEFT_PARENTHESIS RIGHT_PARENTHESIS OP_COLON KW_VOID LEFT_CUR_BRACKET body RIGHT_CUR_BRACKET { 
/* We have a successful parse! 
  Check for any errors and generate output. 
*/
	if (yyerror_count == 0) {
    // include the mslib.h file
	  puts(c_prologue); 
	  printf("/* program */ \n\n");
	  printf("%s\n\n", $1);
	  printf("int main() {\n%s\n} \n", $9);
	}
}
| KW_FUNCTION KW_START LEFT_PARENTHESIS RIGHT_PARENTHESIS OP_COLON KW_VOID LEFT_CUR_BRACKET body RIGHT_CUR_BRACKET {
/* We have a successful parse! 
  Check for any errors and generate output. 
*/
	if(yyerror_count==0) {
	  printf("\n\n\t/* program */ \n\n");
    // include the teaclib.h file
	  puts(c_prologue); 
	  printf("int main() {\n%s\n} \n", $8);
	}
}

;

						/*BODY-LISTS DECLARATION*/ 
body: decl_list  
| %empty { $$=""; }
;

decl_list: decl_list decl 						{ $$ = template("%s\n%s", $1, $2); }
| decl { $$=$1; }
;

decl: 
KW_CONST const_decl 							{ $$ = template("const %s;", $2); }
|KW_VAR var_decl_body 							{ $$ = template("%s", $2); }
|function_s SEMICOLON						  { $$ = template("%s;", $1); }
|prefunc_s SEMICOLON                            { $$ = template("%s;", $1); }
|statement_list                                 { $$ = template("%s", $1); }

;

              /*CONSTANT DECLARATION*/


const_decl: const_decl_list OP_COLON type_spec SEMICOLON { $$ = template("%s %s", $3, $1); }
;
			





						/*VAR DECLARATION*/ 
var_decl_body: var_decl_list OP_COLON type_spec SEMICOLON  { $$ = template("%s %s;", $3, $1); }
;

const_decl_list: 
const_decl_list COMMA const_decl_list_item 		{ $$ = template("%s, %s", $1, $3); }
| const_decl_list_item 							{ $$ = $1; }
;

var_decl_list: var_decl_list COMMA var_decl_init { $$ = template("%s, %s", $1, $3); }
| var_decl_init { $$ = $1; }
;

const_decl_list_item: 
decl_list_item_id ASSIGN expr 					{ $$ = template("%s = %s", $1, $3);}
;

var_decl_init: decl_list_item_id 				{ $$ = $1; }
| decl_list_item_id ASSIGN expr 				{ $$ = template("%s=%s", $1, $3); }
; 





          /*GENERAL DECLARATION */ 

decl_list_item_id: IDENT                        { $$ = template("%s",$1); } 
| IDENT LEFT_SQ_BRACKET RIGHT_SQ_BRACKET 		{ $$ = template("*%s", $1); }
| IDENT LEFT_SQ_BRACKET NUMBER RIGHT_SQ_BRACKET { $$ = template("*%s", $1); }
;
 
type_spec: KW_NUMBER { $$ = "double"; }
| KW_STRING { $$ = "char*" ;}
| KW_VOID { $$ = "void"; }
| KW_BOOL { $$ = "int"; }
;



             /*ΕΧPRESSION DECLARATION*/
expr: IDENT										{ $$ = template("%s",$1); }
| NUMBER										{ $$ = template("%s",$1); }
| STRING 										{ $$ = template("%s",$1); }
| BOOL 											{ $$ = template("%s",$1); }

|KW_FALSE                                       { $$ = template("false"); }
|KW_TRUE                                        { $$ = template("true"); }
| LEFT_PARENTHESIS expr RIGHT_PARENTHESIS 		{ $$ = template("(%s)", $2); }
 
| OP_NOT expr 									{ $$ = template("!%s", $2); }
						 
| OP_PLUS expr									{ $$ = template("%s", $2); }
| OP_MINUS expr 								{ $$ = template("-%s", $2); }
						 
| expr OP_DIV expr 								{ $$ = template("%s / %s", $1, $3); }
| expr OP_MULT expr 							{ $$ = template("%s * %s", $1, $3); }
| expr OP_REM expr 								{ $$ = template("%s % %s", $1, $3); }
| expr OP_PWR expr 								{ $$ = template("%s % %s", $1, $3); }
						 
| expr OP_PLUS expr 							{ $$ = template("%s + %s", $1, $3); }
| expr OP_MINUS expr 							{ $$ = template("%s - %s", $1, $3); }
						 
| expr OP_EQ expr 								{ $$ = template("%s = %s", $1, $3); }
| expr OP_NE expr 								{ $$ = template("%s !=  %s", $1, $3); }
| expr OP_LTE expr 								{ $$ = template("%s <= %s", $1, $3); }
| expr OP_LT expr 								{ $$ = template("%s < %s", $1, $3); }
						
| expr OP_AND expr 								{ $$ = template("%s && %s", $1, $3); }
| expr OP_OR expr 								{ $$ = template("%s || %s", $1, $3); }
| IDENT LEFT_PARENTHESIS expr RIGHT_PARENTHESIS	{ $$ = template("%s (%s)", $1, $3); }
 
| prefunc_s 									{ $$ = template("%s",$1); }
;


WString: decl_list_item_id						{ $$ = template("%s",$1); }
| STRING										{ $$ = template("%s",$1); } 
;

WNumber: decl_list_item_id						{ $$ = template("%s",$1); }
| NUMBER										{ $$ = template("%d",$1); }
;

         
                      /*FUNCTION DECLARATION*/



fun_decl:  IDENT   OP_COLON type_spec 			{ $$ = template("%s %s",$3,$1);}
|%empty { $$=""; }
;

func_call : IDENT LEFT_PARENTHESIS func_param RIGHT_PARENTHESIS SEMICOLON { $$ = template("%s (%s);",$1,$3);}
|IDENT ASSIGN IDENT LEFT_PARENTHESIS func_param RIGHT_PARENTHESIS SEMICOLON { $$ = template("%s =%s(%s);",$1,$3,$5);}


func_param : expr { $$ = template("%s",$1);}
|func_param COMMA expr{ $$ = template(" %s,%s ",$1,$3);}
|%empty { $$=""; }
;





               /*STATEMENT DECLARATION*/		
statement_list: statement_list statement		{ $$ = template("%s %s", $1, $2); }
|statement										{ $$ = template("%s", $1);}
;	
	
statement: assi_s								{ $$ = template("%s",$1); }
| if_s	SEMICOLON								{ $$ = template("%s\n",$1); }
|return_s                                       { $$ = template("%s",$1); }
|while_s SEMICOLON								{ $$ = template("%s\n",$1); }
|for_s SEMICOLON								{ $$ = template("%s\n",$1); }
| break_s										{ $$ = template("%s",$1); }
| continue_s                       		 		{ $$ = template("%s",$1); }
//| prefunc_s	SEMICOLON							{ $$ = template("%s;",$1); }
|func_call                                      { $$ = template("%s",$1); }
;

assi_s: IDENT ASSIGN expr SEMICOLON				{ $$ = template("%s = %s;\n", $1,$3);}
;

if_s: KW_IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS LEFT_CUR_BRACKET body RIGHT_CUR_BRACKET ife_s 		{ $$ = template("if(%s){\n%s\n}", $3, $6); }
|KW_IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS  body  ife_s 		{ $$ = template("if(%s)\n%s\n", $3, $5); }
;

ife_s:  KW_ELSE LEFT_CUR_BRACKET body RIGHT_CUR_BRACKET 		{ $$ = template("else {\n %s}", $3); }
|  KW_ELSE if_s  { $$ = template("else  %s\n",$2); } 
| 	%empty		 { $$=""; }
;

while_s: 
KW_WHILE LEFT_PARENTHESIS expr RIGHT_PARENTHESIS LEFT_CUR_BRACKET body RIGHT_CUR_BRACKET  	{$$ = template("while (%s)\n{\n%s}\n", $3, $6); }
;

for_s: 
KW_FOR LEFT_PARENTHESIS statement  expr SEMICOLON statement RIGHT_PARENTHESIS LEFT_CUR_BRACKET statement RIGHT_CUR_BRACKET  	{$$ = template("for (%s; %s ; %s ) \n", $3, $4,$6,$9); }
;

return_s: KW_RETURN expr SEMICOLON 				{ $$ = template("return %s;\n", $2); }
;

function_s: KW_FUNCTION IDENT LEFT_PARENTHESIS fun_decl RIGHT_PARENTHESIS OP_COLON type_spec LEFT_CUR_BRACKET body RIGHT_CUR_BRACKET 	{$$ = template(" %s %s(%s) {\n%s\n}",$7, $2, $4,$9); }
;

break_s : KW_BREAK SEMICOLON					{ $$ = template("break;"); }
;

continue_s : KW_CONTINUE SEMICOLON 				{ $$ = template("continue;"); }
;

prefunc_s: READSTRING LEFT_PARENTHESIS RIGHT_PARENTHESIS 			{ $$ = template("readString()"); }
| READNUMBER LEFT_PARENTHESIS RIGHT_PARENTHESIS						{ $$ = template("readNumber()"); }
| WRITESTRING LEFT_PARENTHESIS WString RIGHT_PARENTHESIS 	{ $$ = template("writeString(%s)",$3); }
| WRITENUMBER LEFT_PARENTHESIS WNumber RIGHT_PARENTHESIS 	{ $$ = template("writeNumber(%s)",$3); }
;

%%
int main () {
  if ( yyparse() != 0 )
    printf("Rejected!\n");
}