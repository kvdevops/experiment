%{
#include "yygrammar.h"
%}
%%
"="                       { return ASSIGN_TK; }
"+"                       { return PLUS_TK; }
"-"                       { return MINUS_TK; }
"*"                       { return MULT_TK; }
"/"                       { return DIV_TK; }
">"                       { return GT_TK; }
"<"                       { return LT_TK; }
"^"                       { return XOR_TK; }
"("                       { return OP_TK; }
")"                       { return CP_TK; }
"["                       { return OSB_TK; }
"]"                       { return CSB_TK; }
"{"                       { return OCB_TK; }
"}"                       { return CCB_TK; }
","                       { return C_TK; }
"!"                       { return NOT_TK; }
";"                       { return SC_TK; }
"~"                       { return NEG_TK; }
"int_tk"                  { return INT_LIT_TK; }
"bool_or_tk"              { return BOOL_OR_TK; }
"lte_tk"                  { return LTE_TK; }
"gte_tk"                  { return GTE_TK; }
"assign_any_tk"           { return ASSIGN_ANY_TK; }
"bool_and_tk"             { return BOOL_AND_TK; }
"eq_tk"                   { return EQ_TK; }
"public_tk"               { return MODIFIER_TK; }
"interface_tk"            { return INTERFACE_TK; }
"rem_tk"                  { return REM_TK; }
"not_eq_tk"               { return NEQ_TK; }
"super_tk"                { return SUPER_TK; }
"if_tk"                   { return IF_TK; }
"break_tk"                { return BREAK_TK; }
"default_tk"              { return DEFAULT_TK; }
"float_tk"                { return FP_LIT_TK; }
"or_tk"                   { return OR_TK; }
"finally_tk"              { return FINALLY_TK; }
"import_tk"               { return IMPORT_TK; }
"for_tk"                  { return FOR_TK; }
"dot_tk"                  { return DOT_TK; }
"char_lit_tk"             { return CHAR_LIT_TK; }
"rel_cl_tk"               { return REL_CL_TK; }
"ls_tk"                   { return LS_TK; }
"srs_tk"                  { return SRS_TK; }
"incr_tk"                 { return INCR_TK; }
"class_tk"                { return CLASS_TK; }
"else_tk"                 { return ELSE_TK; }
"this_tk"                 { return THIS_TK; }
"rel_qm_tk"               { return REL_QM_TK; }
"true_tk"                 { return BOOL_LIT_TK; }
"package_tk"              { return PACKAGE_TK; }
"null_tk"                 { return NULL_TK; }
"string_tk"               { return STRING_LIT_TK; }
"do_tk"                   { return DO_TK; }
"throws_tk"               { return THROWS_TK; }
"zrs_tk"                  { return ZRS_TK; }
"catch_tk"                { return CATCH_TK; }
"try_tk"                  { return TRY_TK; }
"id_tk"                   { return ID_TK; }
"new_tk"                  { return NEW_TK; }
"throw_tk"                { return THROW_TK; }
"assert_tk"               { return ASSERT_TK; }
"continue_tk"             { return CONTINUE_TK; }
"boolean_tk"              { return BOOLEAN_TK; }
"fp_tk"                   { return FP_TK; }
"void_tk"                 { return VOID_TK; }
"and_tk"                  { return AND_TK; }
"extends_tk"              { return EXTENDS_TK; }
"instanceof_tk"           { return INSTANCEOF_TK; }
"integral_tk"             { return INTEGRAL_TK; }
"decr_tk"                 { return DECR_TK; }
"implements_tk"           { return IMPLEMENTS_TK; }
"return_tk"               { return RETURN_TK; }
"case_tk"                 { return CASE_TK; }
"while_tk"                { return WHILE_TK; }
"switch_tk"               { return SWITCH_TK; }
" "                       { /* blank */ }
\r          { yypos++; /* adjust linenumber and skip newline */ }
\n          { yypos++; /* adjust linenumber and skip newline */ }
.           { printf("\n++ illegal token : %s ++", yytext); yyerror(""); }
