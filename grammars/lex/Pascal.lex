%{
#include "yygrammar.h"
%}
%%
","                 { return ','; }
"+"                 { return '+'; }
"-"                 { return '-'; }
"*"                 { return '*'; }
"/"                 { return '/'; }
"("                 { return '('; }
")"                 { return ')'; }
"."                 { return '.'; }
";"                 { return ';'; }
":"                 { return ':'; }
"^"                 { return '^'; }
"["                 { return '['; }
"]"                 { return ']'; }
"="                 { return '='; }
"<"                 { return '<'; }
">"                 { return '>'; }
"ge_tk"             { return GE; }
"dotdot_tk"         { return DOTDOT; }
"if_tk"             { return IF; }
"then_tk"           { return THEN; }
"downto_tk"         { return DOWNTO; }
"repeat_tk"         { return REPEAT; }
"function_tk"       { return FUNCTION; }
"of_tk"             { return OF; }
"begin_tk"          { return SBEGIN; }
"label_tk"          { return LABEL; }
"string_tk"         { return STRING; }
"while_tk"          { return WHILE; }
"record_tk"         { return RECORD; }
"sfile_tk"          { return SFILE; }
"do_tk"             { return DO; }
"var_tk"            { return VAR; }
"with_tk"           { return WITH; }
"unsign_int_tk"     { return UNSIGNED_INT; }
"const_tk"          { return CONST; }
"set_tk"            { return SET; }
"until_tk"          { return UNTIL; }
"to_tk"             { return TO; }
"end_tk"            { return END; }
"type_tk"           { return TYPE; }
"le_tk"             { return LE; }
"else_tk"           { return ELSE; }
"array_tk"          { return ARRAY; }
"packed_tk"         { return PACKED; }
"ne_tk"             { return NE; }
"and_tk"            { return AND; }
"not_tk"            { return NOT; }
"procedure_tk"      { return PROCEDURE; }
"div_tk"            { return DIV; }
"nil_tk"            { return NIL; }
"case_tk"           { return CASE; }
"becomes_tk"        { return BECOMES; }
"id_tk"             { return IDENTIFIER; }
"for_tk"            { return FOR; }
"unsigned_real_tk"  { return UNSIGNED_REAL; }
"in_tk"             { return IN; }
"program_tk"        { return PROGRAM; }
"or_tk"             { return OR; }
"goto_tk"           { return GOTO; }
"mod_tk"            { return MOD; }
" "                 { /* blank */ }
\r          { yypos++; /* adjust linenumber and skip newline */ }
\n          { yypos++; /* adjust linenumber and skip newline */ }
.           { printf("\n++ illegal token : %s ++", yytext); yyerror("illegal xyz token"); }
