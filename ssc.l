
%{
#include "ssc.tab.h"
#include <stdlib.h>
#include <stdio.h>
#include <string>
extern void yyerror(const char *msg);

//#define DEBUGSSC
// This code is for producing debug output.
#ifdef DEBUGSSC
#define debugFlex(a) (printf("\n%d: Token=<ID, lexeme>=<%d, %s>\n", yylineno, a, yytext))
#else
#define debugFlex(a)
#endif
%}

%option yylineno
%option noyywrap

%%

"if"          { debugFlex(tok_if); return tok_if; }
"else"        { debugFlex(tok_else); return tok_else; }
"elseif"      { debugFlex(tok_elseif); return tok_elseif; }
"switch"      { debugFlex(tok_switch); return tok_switch; }
"case"        { debugFlex(tok_case); return tok_case; }
"default"     { debugFlex(tok_default); return tok_default; }
"break"       { debugFlex(tok_break); return tok_break; }
"printd"      { debugFlex(tok_printd); return tok_printd; }
"prints"      { debugFlex(tok_prints); return tok_prints; }

">="|"<="     { debugFlex(yytext[0]); return yytext[0]; }
"=="          { debugFlex(yytext[0]); return tok_eq; }
"!="          { debugFlex(yytext[0]); return tok_ne; }
"^"           { debugFlex(yytext[0]); return tok_xor; }    // Bitwise XOR
"&&"          { debugFlex(tok_and); return tok_and; }      // Logical AND
"||"          { debugFlex(tok_or); return tok_or; }        // Logical OR
"&"           { debugFlex(yytext[0]); return '&'; }        // Bitwise AND
"|"           { debugFlex(yytext[0]); return '|'; }        // Bitwise OR
"!"           { debugFlex(tok_not); return tok_not; }      // NOT Operator

[a-zA-Z][a-zA-Z0-9_]* { debugFlex(tok_identifier); yylval.identifier = strdup(yytext); return tok_identifier; }
[0-9]+(\.[0-9]+)? { debugFlex(tok_double_literal); yylval.double_literal = atof(yytext); return tok_double_literal; }
\"[^"]*\"     { debugFlex(tok_string_literal); yylval.string_literal = strdup(yytext); return tok_string_literal; }
\/\/.*        { ; }
[ \n\r\t]     { ; }

"+"|"-"|"*"|"/"|"="|">"|"<"|";"|"("|")"|"{"|"}" { debugFlex(yytext[0]); return yytext[0]; }
":"           { debugFlex(yytext[0]); return yytext[0]; }
.             { debugFlex(-1); yyerror("this is an illegal lexeme"); exit(EXIT_FAILURE); }

%%
