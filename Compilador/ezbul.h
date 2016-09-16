#include <ctype.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int data_reg_code(char*, char);

int encode_immediate(int);

int get_reg_num(char*);

void init_files_asm(char*);

char* str_tolower(char*);

void yyerror (const char*);
