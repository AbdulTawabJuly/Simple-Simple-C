
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vector>
#include <map>
#include "IR.h"

extern int yyparse();
extern int yylex();
extern FILE *yyin;
void yyerror(const char *err);

#ifdef DEBUGBISON
#define debugBison(a) (printf("\n%d \n",a))
#else
#define debugBison(a)
#endif

std::vector<bool> exec_flags = {true}; // Controls execution flow
std::vector<bool> any_exec;

std::vector<double> switch_vals;
std::vector<bool> switch_exec;
std::vector<bool> switch_stop_flipping;
%}

%union {
    char *identifier;
    double double_literal;
    char *string_literal;
}

%token tok_printd
%token tok_prints
%token tok_eq
%token tok_ne
%token tok_and
%token tok_or
%token tok_xor
%token tok_not
%token tok_if
%token tok_else
%token tok_elseif
%token tok_switch
%token tok_case
%token tok_default
%token tok_break
%token <identifier> tok_identifier
%token <double_literal> tok_double_literal
%token <string_literal> tok_string_literal

%type <double_literal> if_stmt else_block switch_stmt case_block switch_value case_value expression condition elif_condition term
%type <double_literal> root

%left '+' '-'
%left '*' '/'
%left '(' ')'

%start root

%%

// Grammar rules
root: /* empty */ { debugBison(1); }  
    | statement root { debugBison(32); }
    ;

statement: prints { debugBison(2); }
    | printd { debugBison(3); }
    | assignment { debugBison(4); }
    | if_stmt { debugBison(16); }
    | switch_stmt { debugBison(40); }
    ;

prints: tok_prints '(' tok_string_literal ')' ';'  
{
    debugBison(5);
    if (exec_flags.back()) {
        printf("%s\n", $3);
    }
}
;

printd: tok_printd '(' term ')' ';'
{
    debugBison(6);
    if (exec_flags.back()) {
        printf("%lf\n", $3); // Ensure $3 is double
    }
}
;

term: tok_identifier { debugBison(7); $$ = getValueFromSymbolTable($1); }
    | tok_double_literal { debugBison(8); $$ = $1; }
    ;

assignment: tok_identifier '=' expression ';' { debugBison(9); setValueInSymbolTable($1, $3); }
;

if_stmt: tok_if '(' condition ')' '{' root '}' else_block
{
    debugBison(26);
    exec_flags.pop_back();
    any_exec.pop_back();
}
;

switch_stmt: tok_switch '(' switch_value ')' '{' case_block '}' {switch_vals.pop_back();exec_flags.pop_back();};
switch_value: expression {switch_vals.push_back($1);exec_flags.push_back(true);switch_stop_flipping.push_back(false);};
case_value: term {
	double expr = $1;
	bool exec_this_case = (expr == switch_vals.back() && exec_flags.back());
	//printf("switch_val = %f\n",switch_vals.back());
	//printf("condition evaluated for val %f  %d\n",expr,exec_this_case);
	exec_flags[exec_flags.size()-1] = exec_this_case;};
case_root: root {if(!switch_stop_flipping.back()){exec_flags[exec_flags.size()-1] = !exec_flags.back();switch_stop_flipping[switch_stop_flipping.size()-1] = !(exec_flags.back()); }};
default_begin: tok_default {bool e = exec_flags.back();
	     };
case_block: /* empty */ { debugBison(42);}
    | tok_case case_value ':' case_root tok_break ';' case_block {};
    | default_begin ':' root tok_break ';'
    {
	
    };

else_block: /* empty */ { debugBison(29); }
    | tok_elseif '(' elif_condition ')' '{' root '}' else_block
    {
        debugBison(31);
    }  
    | tok_else {exec_flags[exec_flags.size()-1] = !any_exec.back();} '{' root '}'
    {
        debugBison(30);
    }
;
elif_condition: expression {debugBison(19); exec_flags[exec_flags.size()-1] = (($1 != 0.0) && !any_exec.back()); any_exec[any_exec.size()-1] = any_exec.back() || exec_flags.back(); $$ = $1;};
condition: expression
{
    debugBison(19);
    if ($1 == 0.0)
        exec_flags.push_back(false);
    else
        exec_flags.push_back(true);
    any_exec.push_back(exec_flags.back());
}
;

expression: term { debugBison(10); $$ = $1; }
    | expression '+' expression { debugBison(11); $$ = performBinaryOperation($1, $3, '+'); }
    | expression '-' expression { debugBison(12); $$ = performBinaryOperation($1, $3, '-'); }
    | expression '/' expression { debugBison(13); $$ = performBinaryOperation($1, $3, '/'); }
    | expression '*' expression { debugBison(14); $$ = performBinaryOperation($1, $3, '*'); }
    | expression '>' expression { debugBison(20); $$ = performLogicalOperations($1, $3, OP_GREATER); }
    | expression '<' expression { debugBison(21); $$ = performLogicalOperations($1, $3, OP_LESS); }
    | expression ">=" expression { debugBison(22); $$ = performLogicalOperations($1, $3, OP_GREATER_EQUAL); }
    | expression "<=" expression { debugBison(23); $$ = performLogicalOperations($1, $3, OP_LESS_EQUAL); }
    | expression '&' expression { debugBison(23); $$ = performBitwiseOperations($1, $3, OP_BIT_AND); } // Bitwise AND
    | expression '|' expression { debugBison(23); $$ = performBitwiseOperations($1, $3, OP_BIT_OR); }  // Bitwise OR
    | expression '^' expression { debugBison(23); $$ = performBitwiseOperations($1, $3, OP_BIT_XOR); } // Bitwise XOR
    | expression tok_and expression { debugBison(23); $$ = performLogicalCompoundOperations($1, $3, OP_LOGICAL_AND); } // Logical AND
    | expression tok_or expression { debugBison(23); $$ = performLogicalCompoundOperations($1, $3, OP_LOGICAL_OR); } // Logical OR
    | tok_not expression { debugBison(23); $$ = performNotOperations($2); }
    | expression tok_eq expression { debugBison(24); $$ = performLogicalOperations($1, $3, OP_EQUAL); }
    | expression tok_ne expression { debugBison(25); $$ = performLogicalOperations($1, $3, OP_NOT_EQUAL); }
    | '(' expression ')' { debugBison(15); $$ = $2; }
    ;


%%

void yyerror(const char *err) {
    fprintf(stderr, "\nError: %s\n", err);
}

int main(int argc, char** argv) {
    if (argc > 1) {
        FILE *fp = fopen(argv[1], "r");
        if (!fp) {
            perror("File opening failed");
            return EXIT_FAILURE;
        }
        yyin = fp;
    }
    if (yyin == NULL) {
        yyin = stdin;
    }

    int parserResult = yyparse();

    return EXIT_SUCCESS;
}
