	.section .rodata
titulo:
	.ascii "Numeros del 9 al 1:\n"
lt = . - titulo

msg_fin:
	.ascii "Fin del programa\n"
lf = . - msg_fin

	.section .bss
	.lcomm cadena, 32

	.section .text
	.globl	_start

.equ WRITE,1
.equ STDOUT,1
.equ EXIT,60
.equ VECES,9

_writeTitulo:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$titulo, %rsi
	movq	$lt, %rdx
	syscall
	ret

_writeFin:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_fin, %rsi
	movq	$lf, %rdx
	syscall
	ret

_cuentaRegresiva:
	movq	$VECES, %rcx
	movq	$cadena, %rdi
	movb	$'9', %al

_cicloNumeros:
	movb	%al, (%rdi)
	incq	%rdi
	movb	$'\n', (%rdi)
	incq	%rdi

	decb	%al
	loop	_cicloNumeros

	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$cadena, %rsi
	movq	$VECES*2, %rdx
	syscall
	ret

_exit:
	movq	$EXIT, %rax
	movq	$0, %rdi
	syscall

_start:
	call	_writeTitulo
	call	_cuentaRegresiva
	call	_writeFin
	call	_exit
