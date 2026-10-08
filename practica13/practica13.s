	.section .rodata
prompt:
	.ascii "Programa con menu de opciones\n"
lp = . - prompt

menu:
	.ascii "\n===== MENU =====\n"
	.ascii "1) Mostrar abecedario (A-Z)\n"
	.ascii "2) Mostrar simbolos numericos (0-9)\n"
	.ascii "3) Mostrar vocales\n"
	.ascii "4) Salir\n"
	.ascii "Elige una opcion (1-4): "
lm = . - menu

msg_abc:
	.ascii "Abecedario: "
labc = . - msg_abc

msg_num:
	.ascii "Simbolos numericos: "
lnum = . - msg_num

msg_voc:
	.ascii "Vocales: "
lvoc = . - msg_voc

vocales:
	.ascii "AEIOU\n"
lv = . - vocales

msg_salir:
	.ascii "Fin del programa\n"
ls = . - msg_salir

msg_error:
	.ascii "Ingresa una opcion valida (1-4)\n"
le = . - msg_error

	.section .bss
	.lcomm buffer, 64
	.lcomm cadena, 32

	.section .text
	.globl	_start

.equ WRITE,1
.equ STDOUT,1
.equ INPUT,0
.equ EXIT,60
.equ LETRAS,26
.equ DIGITOS,10

_writePrompt:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$prompt, %rsi
	movq	$lp, %rdx
	syscall
	ret

_writeMenu:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$menu, %rsi
	movq	$lm, %rdx
	syscall
	ret

_writeMsgAbc:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_abc, %rsi
	movq	$labc, %rdx
	syscall
	ret

_writeMsgNum:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_num, %rsi
	movq	$lnum, %rdx
	syscall
	ret

_writeMsgVoc:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_voc, %rsi
	movq	$lvoc, %rdx
	syscall
	ret

_writeMsgSalir:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_salir, %rsi
	movq	$ls, %rdx
	syscall
	ret

_writeError:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_error, %rsi
	movq	$le, %rdx
	syscall
	ret

_scanDigit:
	movq	$INPUT, %rax
	movq	$INPUT, %rdi
	movq	$buffer, %rsi
	movq	$1, %rdx
	syscall

	cmpq	$1, %rax
	jne	_scanSinEntrada

	movzbq	buffer(%rip), %r15

	cmpb	$'\n', %r15b
	je	_scanVacio

_limpiaLinea:
	movq	$INPUT, %rax
	movq	$INPUT, %rdi
	movq	$buffer, %rsi
	movq	$1, %rdx
	syscall

	cmpq	$1, %rax
	jne	_scanFin

	cmpb	$'\n', buffer(%rip)
	jne	_limpiaLinea

_scanFin:
	movq	%r15, %rax
	subq	$'0', %rax
	ret

_scanVacio:
	movq	$0, %rax
	ret

_scanSinEntrada:
	movq	$4, %rax
	ret

_muestraAbecedario:
	movq	$LETRAS, %rcx
	movq	$cadena, %rdi
	movb	$'A', %al

_cicloLetras:
	movb	%al, (%rdi)
	incq	%rdi
	incb	%al
	loop	_cicloLetras

	movb	$'\n', (%rdi)

	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$cadena, %rsi
	movq	$LETRAS+1, %rdx
	syscall
	ret

_muestraNumeros:
	movq	$DIGITOS, %rcx
	movq	$cadena, %rdi
	movb	$'0', %al

_cicloDigitos:
	movb	%al, (%rdi)
	incq	%rdi
	incb	%al
	loop	_cicloDigitos

	movb	$'\n', (%rdi)

	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$cadena, %rsi
	movq	$DIGITOS+1, %rdx
	syscall
	ret

_muestraVocales:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$vocales, %rsi
	movq	$lv, %rdx
	syscall
	ret

_exit:
	movq	$EXIT, %rax
	movq	$0, %rdi
	syscall

_start:
	call	_writePrompt

_menu:
	call	_writeMenu
	call	_scanDigit

	cmpq	$1, %rax
	je	_opcionAbecedario

	cmpq	$2, %rax
	je	_opcionNumeros

	cmpq	$3, %rax
	je	_opcionVocales

	cmpq	$4, %rax
	je	_opcionSalir

	call	_writeError
	jmp	_menu

_opcionAbecedario:
	call	_writeMsgAbc
	call	_muestraAbecedario
	jmp	_menu

_opcionNumeros:
	call	_writeMsgNum
	call	_muestraNumeros
	jmp	_menu

_opcionVocales:
	call	_writeMsgVoc
	call	_muestraVocales
	jmp	_menu

_opcionSalir:
	call	_writeMsgSalir
	call	_exit
