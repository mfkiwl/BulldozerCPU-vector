ezbul: lex.yy.c asm.tab.c
	gcc -g -w lex.yy.c asm.tab.c -o ezbul
	
asm.tab.c: ezbul.y
	yacc -b asm -d ezbul.y

lex.yy.c: asm.tab.c ezbul.l
	lex ezbul.l

clean: 
	rm -f lex.yy.c asm.tab.c asm.tab.h ezbul
