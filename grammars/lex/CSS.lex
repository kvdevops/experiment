%{
#include "yygrammar.h"
%}
%%
","                   { return ','; }
"+"                   { return '+'; }
"-"                   { return '-'; }
"*"                   { return '*'; }
"/"                   { return '/'; }
"{"                   { return '{'; }
"}"                   { return '}'; }
">"                   { return '>'; }
"["                   { return '['; }
"]"                   { return ']'; }
")"                   { return ')'; }
"="                   { return '='; }
":"                   { return ':'; }
";"                   { return ';'; }
"."                   { return '.'; }
" "                   { return WS;}
"<!--"                { return CDO;}
"-->"                 { return CDC;}
"~="                  { return INCLUDES;}
"|="                  { return DASHMATCH;}
"string_tk"           { return STRING;}
"id_tk"               { return IDENT;}
"hash_tk"             { return HASH;}
"import_tk"           { return IMPORT_SYM;}
"page_tk"             { return PAGE_SYM;}
"media_tk"            { return MEDIA_SYM;}
"charset_tk"          { return CHARSET_SYM;}
"imp_tk"              { return IMPORTANT_SYM;}
"ems_tk"              { return EMS;}
"exs_tk"              { return EXS;}
"len_tk"              { return LENGTH;}
"angle_tk"            { return ANGLE;}
"time_tk"             { return TIME;}
"freq_tk"             { return FREQ;}
"prct_tk"             { return PERCENTAGE;}
"num_tk"              { return NUMBER;}
"uri_tk"              { return URI; }
"func_tk"             { return FUNCTION;}
\r                    { yypos++; /* adjust linenumber and skip newline */ }
\n                    { yypos++; /* adjust linenumber and skip newline */ }
.                     { printf("\nillegal token: %s", yytext);yyerror("\n");}
