	.section .rodata
prompt:
	.ascii "Programa para dibujar un triangulo con asteriscos\n"
lp = . - prompt

msg_a: 
	.ascii "Ingresa Altura (1 - 9): "
la = . - msg_a

msg_res:
	.ascii "Resultado:\n"
lr = . - msg_res

msg_error:
        .ascii "Ingresa un numero valido (1-9)\n"
le = . - msg_error

	.section .bss
	.lcomm buffer, 64
	.lcomm cadena, 16
	.lcomm secuencia, 32

	.section .text
	.globl _start

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
	
        cmpb    $'1', %r15b
        jb      _writeError

        cmpb    $'9', %r15b
        ja      _writeError

_limpiaLinea:
	movq	$INPUT, %rax
	movq	$INPUT, %rdi
	movq	$buffer, %rsi
	movq	$1, %rdx
	syscall

	cmpq	$1, %rax
	jne	_limpiaLinea

_scanFin:
	movq	%r15, %rax
	subq	$'0', %rax
	ret

# inicio asc
_writeSecuencia:
	movq	%rdi, %rdx
	subq	$secuencia, %rdx
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$secuencia, %rsi
	syscall
	ret

_imprimeAscendente:
	movq	$secuencia, %rdi
	movq	$1, %r13

_cicloAsc:
	movq	%r13, %rax
	addq	$'0', %rax
	movb	%al, (%rdi)
	incq	%rdi

	cmpq	%r12, %r13
	je	_finAsc

	movb	$',', (%rdi)
	incq	%rdi
	movb	$' ', (%rdi)
	incq	%rdi
	incq	%r13
	jmp	_cicloAsc

_finAsc:
	movb	$'
', (%rdi)
	incq	%rdi
	call	_writeSecuencia
	ret

# fin asc

#inicio desc

_imprimeDescendente:
	movq	$secuencia, %rdi
	movq	%r12, %r13

_cicloDesc:
	movq	%r13, %rax
	addq	$'0', %rax
	movb	%al, (%rdi)
	incq	%rdi

	cmpq	$1, %r13
	je	_finDesc

	movb	$',', (%rdi)
	incq	%rdi
	movb	$' ', (%rdi)
	incq	%rdi
	decq	%r13
	jmp	_cicloDesc

_finDesc:
	movb	$'
', (%rdi)
	incq	%rdi
	call	_writeSecuencia
	ret
#fin desc

_dibujarTriangulo:
	movq	$1, %r13

_cicloFilas:
	movq	%r13, %rcx
	movq	$cadena, %rdi

_cicloColumnas:
	movb	$'*', (%rdi)
	incq	%rdi
	loop	_cicloColumnas

	movq	$'\n', (%rdi)

	movq	%r13, %rdx
	incq	%rdx
	movq	$WRITE,	%rax
	movq	$STDOUT, %rdi
	movq	$cadena, %rsi
	syscall

	incq	%r13
	cmpq	%r12, %r13
	jbe	_cicloFilas
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

	call	_writeMsgRes
	call	_imprimeAscendente
	call	_imprimeDescendente
	call	_dibujarTriangulo
	call	_exit

