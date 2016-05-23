%{
#include "yygrammar.h"
%}
%%
","              { return ','; }
"+"              { return '+'; }
"-"              { return '-'; }
"*"              { return '*'; }
"/"              { return '/'; }
"("              { return '('; }
")"              { return ')'; }
"="              { return EQUAL; }
">="             { return COMPARISON_OPERATOR; }
"into_tk"        { return INTO; }
"integer_tk"     { return INTEGER; }
"prec_tk"        { return PRECISION; }
"varchar_tk"     { return VARCHAR; }
"ttable_tk"      { return TTABLE; }
"null_tk"        { return NULL_VALUE; }
"by_tk"          { return BY; }
"column_tk"      { return COLUMN; }
"string_tk"      { return STRING; }
"double_tk"      { return DOUBLE; }
"int_tk"         { return INT; }
"name_tk"        { return NAME; }
"update_tk"      { return UPDATE; }
"where_tk"       { return WHERE; }
"set_tk"         { return SET; }
"add_tk"         { return ADD; }
"select_tk"      { return SELECT; }
"create_tk"      { return CREATE; }
"insert_tk"      { return INSERT; }
"intnum_tk"      { return INTNUM; }
"and_tk"         { return AND; }
"alter_tk"       { return ALTER; }
"not_tk"         { return NOT; }
"drop_tk"        { return DROP; }
"date_tk"        { return DATE; }
"order_tk"       { return ORDER; }
"delete_tk"      { return DELETE; }
"fnum_tk"        { return FLOATNUM; }
"from_tk"        { return FROM; }
"is_tk"          { return IS; }
"or_tk"          { return OR; }
"values_tk"      { return VALUES; }
" "              { /* blank */ }
\r         { yypos++; /* adjust linenumber and skip newline */ }
\n         { yypos++; /* adjust linenumber and skip newline */ }
.          { printf("\n++ illegal token : %s ++", yytext); yyerror(""); }
