	.section .rodata
prompt:
	.ascii "Cuantas veces repito la letra? (1-9): "
lp = . - prompt

msg_letra:
	.ascii "Escribe una letra: "
ll = . - msg_letra

msg_res:
	.ascii "Resultado: "
lr = . - msg_res

msg_error:
	.ascii "Ingresa un numero valido (1-9)\n"
le = . - msg_error

msg_error_letra:
	.ascii "Ingresa una letra valida (A-Z o a-z)\n"
lel = . - msg_error_letra

	.section .bss
	.lcomm buffer, 64
	.lcomm letra, 1
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

_writeMsgLetra:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_letra, %rsi
	movq	$ll, %rdx
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

_scanLetra:
	movq	$INPUT, %rax
	movq	$INPUT, %rdi
	movq	$buffer, %rsi
	movq	$1, %rdx
	syscall

	cmpq	$1, %rax
	jne	_writeErrorLetra

	movzbq	buffer(%rip), %r15

	cmpb	$'A', %r15b
	jb	_writeErrorLetra

	cmpb	$'Z', %r15b
	jbe	_guardaLetra

	cmpb	$'a', %r15b
	jb	_writeErrorLetra

	cmpb	$'z', %r15b
	ja	_writeErrorLetra

_guardaLetra:
	movb	%r15b, letra(%rip)

_limpiaLetra:
	movq	$INPUT, %rax
	movq	$INPUT, %rdi
	movq	$buffer, %rsi
	movq	$1, %rdx
	syscall

	cmpq	$1, %rax
	jne	_letraFin

	cmpb	$'\n', buffer(%rip)
	jne	_limpiaLetra

_letraFin:
	ret

_repiteLetra:
	movq	%r12, %rcx
	movq	$cadena, %rdi
	movzbq	letra(%rip), %rax

_cicloLetra:
	movb	%al, (%rdi)
	incq	%rdi
	loop	_cicloLetra

	movb	$'\n', (%rdi)

	movq	%r12, %rdx
	incq	%rdx
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$cadena, %rsi
	syscall
	ret

_writeError:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_error, %rsi
	movq	$le, %rdx
	syscall
	jmp	_exit

_writeErrorLetra:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_error_letra, %rsi
	movq	$lel, %rdx
	syscall
	jmp	_exit

_exit:
	movq	$EXIT, %rax
	movq	$0, %rdi
	syscall

_start:
	call	_writePrompt
	call	_scanDigit
	movq	%rax, %r12

	call	_writeMsgLetra
	call	_scanLetra

	call	_writeMsgRes
	call	_repiteLetra
	call	_exit
