%{

/* Se incluyen las cabeceras necesarias */

#include "ezbul.c"
#include <errno.h>

/* Variables de soporte (lex-yacc) */

extern int yylex();
extern int yyparse();
extern int err_bool;
extern int linenumber;
extern FILE *yyin;

/* Punteros de archivos */

FILE *asm_output; 	// Puntero al archivo de salida en ensamblador.
FILE *inputf;		// Puntero al archivo con el programa fuente.
FILE *err_file;		// Puntero al archivo de manejo de errores.

/* Variables de control */

int inst = 0x00000000;		// Representación númerica de instrucción actual

%}

/* Definición de los tipos que puede adquirir cada uno de los elementos 
   terminales y no terminales */

%union {int ival; char *string;};

/* Definición del símbolo inicial y de los tokens de la gramática */

%start program

%token NEWLINE
%token NUM
%token NUMH
%token ID

%token REGISTER
%token REGISTER_VECT

%token INSTR_NOP
%token INSTR_ADD
%token INSTR_CMPJ
%token INSTR_EORV
%token INSTR_SUBV
%token INSTR_ADDV
%token INSTR_LSLV
%token INSTR_LSRV
%token INSTR_RORV
%token INSTR_ROLV
%token INSTR_LDV
%token INSTR_STV
%token INSTR_AND

%%

program: 
	instruction newline program
	| NEWLINE program
	|
	;

newline: 
	NEWLINE							{linenumber++;
						 		 fprintf(asm_output, "%X : %08X\n", linenumber - 2, inst);
						 		 inst = 0x00000000;}
	;

Src:	
	REGISTER						{inst = inst | data_reg_code($<string>1, 'm');}
	| immediate						
	;

Src_vect:	
	REGISTER_VECT						{inst = inst | data_reg_code($<string>1, 'm');}
	| immediate						
	;

immediate: 
	NUM							{$<ival>$ = encode_immediate($<ival>1);
								 inst = inst | encode_immediate($<ival>1);
								 inst = inst | 0x00002000;}
	| NUMH							{$<ival>$ = encode_immediate($<ival>1);
								 inst = inst | encode_immediate($<ival>1);
								 inst = inst | 0x00002000;}
	;	

mem_mode: 
	'[' reg_n_vect ',' Src_vect ']'					
	;

reg_d: 
	REGISTER						{inst = inst | data_reg_code($<string>1, 'd');}
	;

reg_n: 
	REGISTER						{inst = inst | data_reg_code($<string>1, 'n');}
	;

reg_d_vect: 
	REGISTER_VECT						{inst = inst | data_reg_code($<string>1, 'd');}
	;

reg_n_vect: 
	REGISTER_VECT						{inst = inst | data_reg_code($<string>1, 'n');}
	;

instruction: 
	instr_nop						{inst = inst | 0x00000000;}
	| instr_add						{inst = inst | 0x01000000;}
	| instr_cmpj						{inst = inst | 0x01800000;}
	| instr_eorv						{inst = inst | 0x08800000;}
	| instr_subv						{inst = inst | 0x08C00000;}
	| instr_addv						{inst = inst | 0x09000000;}
	| instr_lslv						{inst = inst | 0x09C00000;}
	| instr_lsrv						{inst = inst | 0x0A000000;}
	| instr_rorv						{inst = inst | 0x0A400000;}
	| instr_rolv						{inst = inst | 0x0A800000;}
	| instr_ldv						{inst = inst | 0x0B000000;}
	| instr_stv						{inst = inst | 0x0B400000;}
	| instr_and						{inst = inst | 0x00400000;}
	;

instr_nop: 
	INSTR_NOP						{inst = inst | 0x01002000;}
	;

instr_add: 
	INSTR_ADD reg_d ',' reg_n ',' Src
	;

instr_cmpj: 
	INSTR_CMPJ reg_d ',' reg_n ',' immediate
	;

instr_eorv: 
	INSTR_EORV reg_d_vect ',' reg_n_vect ',' Src_vect
	;

instr_subv: 
	INSTR_SUBV reg_d_vect ',' reg_n_vect ',' Src_vect
	;

instr_addv: 
	INSTR_ADDV reg_d_vect ',' reg_n_vect ',' Src_vect
	;

instr_lslv: 
	INSTR_LSLV reg_d_vect ',' reg_n_vect ',' Src_vect
	;

instr_lsrv: 
	INSTR_LSRV reg_d_vect ',' reg_n_vect ',' Src_vect
	;

instr_rorv: 
	INSTR_RORV reg_d_vect ',' reg_n_vect ',' Src_vect
	;

instr_rolv: 
	INSTR_ROLV reg_d_vect ',' reg_n_vect ',' Src_vect
	;

instr_ldv: 
	INSTR_LDV reg_d_vect ',' mem_mode
	;

instr_stv: 
	INSTR_STV reg_d_vect ',' mem_mode
	;

instr_and: 
	INSTR_AND reg_d ',' reg_n ',' Src
	;

%%

/* Retorna el código del registro en la respectiva posición de la instrucción, 
   dependiendo del tipo de registro (Rd, Rn, ...). Obsérvese que dicho código
   es con el que debe hacerse OR al valor numérico de la instrucción actual. */

int data_reg_code(char *reg_str, char reg_type) {
	int reg_code;
	int reg_offset;	
	switch (reg_type) {
		  case 'm': 
		    reg_offset = 0;
		    break;
		  case 'd': 
		    reg_offset = 18;
		    break;
		  case 'n': 
		    reg_offset = 14;
		    break;
	}
	reg_code = get_reg_num(reg_str);
	reg_code = reg_code << reg_offset;
	return reg_code;
}

/* Algoritmo de codificación de inmediatos, de acuerdo con la representación 
   basada en rotación que se emplea en la arquitectura ARMv4.
   Su entrada es el valor que se desea codificar. Retorna el valor codificado. */

int encode_immediate(int imm) {
	if (imm <= 255) {
		return imm;
	} else {
		int res = 0;
		int shift = 0;
		while (imm > 255)
		{
			imm = imm >> 1;
			shift++;
			if (shift > 15)
			{
				yyerror("Imposible representar inmediato");
				return 0;
			}
		}
		res = imm | (shift << 8);
		return res;
	}
}

/* Abre los archivos respectivos y los asigna al puntero
   correspondiente. El argumento es el nombre del archivo
   de entrada. Retorna el nombre del archivo de salida en
   ensamblador */

void init_files_asm(char *inputfn) {
	inputf = fopen(inputfn , "r");
	if (inputf == NULL) {
		printf("Error: Archivo inválido.\n");
		exit(-1);
	}
	err_file = fopen("Módulo de Errores Ensamblado.txt", "w");
	asm_output = fopen("out.txt", "w+");
	return;
}

/* Función de manejo de errores por defecto de yacc. La entrada es el mensaje que se desea dar
   cuando ocurre un error. En este caso se implementó de manera tal que se impriman todos los 
   mensajes en un archivo de texto. */

void yyerror (const char *s) {
	if (err_bool == 0) err_bool = 1;
	fprintf(err_file, "Error en la línea %d. Error: %s.\n", linenumber, s);
} 

/* Función principal. Primero se inicializan todos los archivos, con sus respectivas cabeceras.
   Luego se evalúan el archivo de entrada, token por token, hasta agotarlos. Cada vez que coincide
   una regla se ejecutan las acciones que se encuentran a la derecha. Si se provee el argumento -p
   se imprime la tabla de símbolos al archivo "TablaSímbolos.txt". Si existe algún error, se indica 
   mediante un mensaje en consola y se escribe al archivo "Módulo de Errores.txt" y no se genera 
   la salida en ensamblador. Si no hay errores se indica que se realizó la compilación con éxito. */

int main(int argc, char **argv) {
	init_files_asm(argv[1]);
	yyin = inputf;
	
	do {
		yyparse();
		
	} while (!feof(yyin));

	fclose(yyin);

	if (err_bool == 1) {
		fclose(asm_output);
		remove("out.txt");
		printf("Error durante el ensamblado. Ver Módulo de Errores Ensamblado.txt.\n");
		fclose(err_file);
		return 1;
	}

	fprintf(err_file, "¡No hay errores en el archivo %s!", argv[1]);
	fclose(err_file);
	fclose(asm_output);
	printf("Ensamblado exitosamente.\n");

	return 0;
}
