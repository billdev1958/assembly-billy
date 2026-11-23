# make                 ensambla y enlaza
# make run             abre el programa de forma interactiva
# make demo            traduce cada linea de ejemplos.txt (salida resumida)
# make demo-completa   lo mismo, con toda la salida del programa
# make uno INS='movb $$5, %al'   traduce una sola instruccion
# make clean           borra los archivos generados

EJEMPLOS = ejemplos.txt
INS = movb $$5, %al

all: proyecto1

proyecto1: proyecto1.o
	ld proyecto1.o -o proyecto1

proyecto1.o: proyecto1.s
	as proyecto1.s -o proyecto1.o

run: proyecto1
	./proyecto1

demo: proyecto1
	@(sed 's/^/1\n/' $(EJEMPLOS); echo 2) | ./proyecto1 | sed -n \
		-e 's/.*Instruccion capturada: /> /p' \
		-e 's/^Codigo maquina: /  /p' \
		-e 's/^E[Rr][Rr][Oo][Rr]/  &/p'

demo-completa: proyecto1
	@(sed 's/^/1\n/' $(EJEMPLOS); echo 2) | ./proyecto1

uno: proyecto1
	@printf '1\n%s\n2\n' '$(INS)' | ./proyecto1

clean:
	rm -f proyecto1 proyecto1.o

.PHONY: all run demo demo-completa uno clean
