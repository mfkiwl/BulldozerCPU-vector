%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "asm.tab.h"  	/* Se incluye el archivo donde se definen los valores de las constantes 
			   correspondientes a cada palabra clave. */
%}

registro_esc	 	("R1"|"R2"|"R3"|"R4"|"R5"|"R6"|"R7"|"r1"|"r2"|"r3"|"r4"|"r5"|"r6"|"r7")
registro_vect		("R8"|"R9"|"R10"|"R11"|"R12"|"R13"|"R14"|"R15"|"r8"|"r9"|"r10"|"r11"|"r12"|"r13"|"r14"|"r15")
num			({numd}|{numh})
numd			([0-9])+
numh			"0x"([0-9A-F])+
%%

 			/* Se definen todas las palabras clave del lenguaje y su valor de retorno (definido en
			   constantes con el mismo nombre, que se declaran en y.tab.h; */

("NOP"|"nop")			{yyless(3); return INSTR_NOP;}
("ADD"|"add")			{yyless(3); return INSTR_ADD;}
("CMPJ"|"cmpj")			{yyless(4); return INSTR_CMPJ;}
("EORV"|"eorv")			{yyless(4); return INSTR_EORV;}
("SUBV"|"subv")			{yyless(4); return INSTR_SUBV;}
("ADDV"|"addv")			{yyless(4); return INSTR_ADDV;}
("LSLV"|"lslv")			{yyless(4); return INSTR_LSLV;}
("LSRV"|"lsrv")			{yyless(4); return INSTR_LSRV;}
("RORV"|"rorv")			{yyless(4); return INSTR_RORV;}
("ROLV"|"rolv")			{yyless(4); return INSTR_ROLV;}
("LDV"|"ldv")			{yyless(3); return INSTR_LDV;}
("STV"|"stv")			{yyless(3); return INSTR_STV;}
("AND"|"and")			{yyless(3); return INSTR_AND;}

{registro_esc}			{yylval.string = (char *) strdup(yytext); return REGISTER;}
{registro_vect}			{yylval.string = (char *) strdup(yytext); return REGISTER_VECT;}


					/* Definición de las expresiones regulares que describen los tokens válidos. */

[ \t]					/* No hacer nada si se encuentra un espacio o una tabulación. */
[\n]				{return NEWLINE;}		
					/* Si se encuentra un cambio de línea, aumentar el número de línea y retornar 
					   el valor constante NEWLINE (ver y.tab.h). */
([A-Za-z]|_)([A-Za-z0-9]){0,31}	{ yylval.string = (char *) strdup(yytext); return ID;} 
					/* Cuando se encuentra un ID, se pasa el valor real del identificador a una de las variables 
					   de yacc y se retorna el valor constante ID (ver y.tab.h). */
{numd}				{ yylval.ival = atoi(yytext);return NUM;}
					/* Cuando se encuentra un NUM, se pasa el valor real del  identificador a una 
					   de las variables de yacc y se retorna el valor constante NUM (ver y.tab.h). */
{numh}				{ yylval.ival = (int)strtol(yytext, NULL, 0); return NUMH;}
					/* Cuando se encuentra un NUMH, se pasa el valor real del  identificador a una 
					   de las variables de yacc y se retorna el valor constante NUMH (ver y.tab.h). */
.				{ return *yytext;}		
					/* Si se encuentra algo que no coincida con las categorías anteriores, retornarlo. */

%%

/* Es necesario definir esta función, pues se hace una llamada a yywrap cuando yylex()
   alcanza el final del archivo. */

int yywrap(){
	return 1;
}
