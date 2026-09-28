	.section .rodata
prompt:
	.ascii "Programa para dibujar un rectangulo con asteriscos\n"
lp = . - prompt

msg_a:
	.ascii "Ingresa Base (1-9): "
la = . - msg_a

msg_b:
	.ascii "Ingresa Altura (1-9): "
lb = . - msg_b

msg_res:
	.ascii "Resultado:\n"
lr = . - msg_res

msg_error:
	.ascii "Ingresa un numero valido (1-9)\n"
le = . - msg_error

	.section .bss
	.lcomm buffer, 64
	.lcomm cadena, 16

	.section .text
	.globl	_start

.equ WRITE,1
.equ STDOUT,1
.equ INPUT,0
.equ EXIT,60

_writePrompt:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$prompt, %rsi
	movq	$lp, %rdx
	syscall
	ret

_writeMsgA:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_a, %rsi
	movq	$la, %rdx
	syscall
	ret

_writeMsgB:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_b, %rsi
	movq	$lb, %rdx
	syscall
	ret

_writeMsgRes:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_res, %rsi
	movq	$lr, %rdx
	syscall
	ret

_scanDigit:
	movq	$INPUT, %rax
	movq	$INPUT, %rdi
	movq	$buffer, %rsi
	movq	$1, %rdx
	syscall

	cmpq	$1, %rax
	jne	_writeError

	movzbq	buffer(%rip), %r15

	cmpb	$'1', %r15b
	jb	_writeError

	cmpb	$'9', %r15b
	ja	_writeError

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

_dibujaRectangulo:
	movq	%r13, %r14

_cicloFilas:
	movq	%r12, %rcx
	movq	$cadena, %rdi

_cicloColumnas:
	movb	$'*', (%rdi)
	incq	%rdi
	loop	_cicloColumnas

	movb	$'\n', (%rdi)

	movq	%r12, %rdx
	incq	%rdx
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$cadena, %rsi
	syscall

	decq	%r14
	jnz	_cicloFilas
	ret

_writeError:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_error, %rsi
	movq	$le, %rdx
	syscall
	jmp	_exit

_exit:
	movq	$EXIT, %rax
	movq	$0, %rdi
	syscall

_start:
	call	_writePrompt

	call	_writeMsgA
	call	_scanDigit
	movq	%rax, %r12

	call	_writeMsgB
	call	_scanDigit
	movq	%rax, %r13

	call	_writeMsgRes
	call	_dibujaRectangulo
	call	_exit
