#include "ezbul.h"

/* Se declara una variable par llevar control del número de línea.
   Se inicializa con valor de 1, pues no puede existir línea 0. */

int linenumber = 1;
int err_bool = 0;	// Indica si ya apareció algún error.

/* Retorna el número de registro a partir de su representación literal (reg_str).
   (R10 -> 10) */

int get_reg_num(char* reg_str) {
	str_tolower(reg_str);
	int reg_num = 0;
	if (strcmp(reg_str, "r0") == 0) 
		{
		  reg_num = 0;
		}   
	else if (strcmp(reg_str, "r1") == 0) 
		{
		  reg_num = 1;
		} 
	else if (strcmp(reg_str, "r2") == 0) 
		{
		  reg_num = 2;
		} 
	else if (strcmp(reg_str, "r3") == 0) 
		{
		  reg_num = 3;
		} 
	else if (strcmp(reg_str, "r4") == 0) 
		{
		  reg_num = 4;
		} 
	else if (strcmp(reg_str, "r5") == 0) 
		{
		  reg_num = 5;
		} 
	else if (strcmp(reg_str, "r6") == 0) 
		{
		  reg_num = 6;
		} 
	else if (strcmp(reg_str, "r7") == 0) 
		{
		  reg_num = 7;
		} 
	else if (strcmp(reg_str, "r8") == 0) 
		{
		  reg_num = 8;
		} 
	else if (strcmp(reg_str, "r9") == 0) 
		{
		  reg_num = 9;
		} 
	else if (strcmp(reg_str, "r10") == 0) 
		{
		  reg_num = 10;
		} 
	else if (strcmp(reg_str, "r11") == 0) 
		{
		  reg_num = 11;
		} 
	else if (strcmp(reg_str, "r12") == 0) 
		{
		  reg_num = 12;
		} 
	else if (strcmp(reg_str, "r13") == 0) 
		{
		  reg_num = 13;
		} 
	else if (strcmp(reg_str, "r14") == 0) 
		{
		  reg_num = 14;
		} 
	else if (strcmp(reg_str, "r15") == 0) 
		{
		  reg_num = 15;
		} 
	return reg_num;
}

/* Convierte su entrada (string) a una cadena de caracteres en minúscula. */

char* str_tolower(char *string) {
	for ( ; *string; ++string) *string = tolower(*string);
	return string;
}


