	.section .rodata
prompt:
	.ascii "Detector de palindromos\n"
lp = . - prompt

msg_palabra:
	.ascii "Escribe una palabra: "
lpa = . - msg_palabra

msg_capturada:
	.ascii "Palabra capturada: "
lc = . - msg_capturada

msg_si:
	.ascii "La palabra SI es un palindromo\n"
lsi = . - msg_si

msg_no:
	.ascii "La palabra NO es un palindromo\n"
lno = . - msg_no

msg_error:
	.ascii "Ingresa una palabra valida\n"
le = . - msg_error

salto:
	.ascii "\n"
lsal = . - salto

	.section .bss
	.lcomm palabra, 64
	.lcomm caracter, 1

	.section .text
	.globl	_start

.equ WRITE,1
.equ STDOUT,1
.equ INPUT,0
.equ EXIT,60
.equ TAM_PALABRA,64

_writePrompt:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$prompt, %rsi
	movq	$lp, %rdx
	syscall
	ret

_writeMsgPalabra:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_palabra, %rsi
	movq	$lpa, %rdx
	syscall
	ret

_writeMsgCapturada:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_capturada, %rsi
	movq	$lc, %rdx
	syscall
	ret

_writeMsgSi:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_si, %rsi
	movq	$lsi, %rdx
	syscall
	ret

_writeMsgNo:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_no, %rsi
	movq	$lno, %rdx
	syscall
	ret

_writeSalto:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$salto, %rsi
	movq	$lsal, %rdx
	syscall
	ret

_writePalabra:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$palabra, %rsi
	movq	%r12, %rdx
	syscall
	ret

_scanPalabra:
	movq	$0, %r15

_cicloPalabra:
	movq	$INPUT, %rax
	movq	$INPUT, %rdi
	movq	$caracter, %rsi
	movq	$1, %rdx
	syscall

	cmpq	$1, %rax
	jne	_palabraFin

	movzbq	caracter(%rip), %rax

	cmpb	$'\n', %al
	je	_palabraFin

	cmpq	$TAM_PALABRA, %r15
	jae	_cicloPalabra

	cmpb	$'a', %al
	jb	_guardaCaracter

	cmpb	$'z', %al
	ja	_guardaCaracter

	subb	$'a'-'A', %al

_guardaCaracter:
	movb	%al, palabra(%r15)
	incq	%r15
	jmp	_cicloPalabra

_palabraFin:
	movq	%r15, %rax
	ret

_esPalindromo:
	movq	$0, %r13
	movq	%r12, %r14
	decq	%r14

_cicloCompara:
	cmpq	%r14, %r13
	jae	_siPalindromo

	movb	palabra(%r13), %al
	cmpb	palabra(%r14), %al
	jne	_noPalindromo

	incq	%r13
	decq	%r14
	jmp	_cicloCompara

_siPalindromo:
	movq	$1, %rax
	ret

_noPalindromo:
	movq	$0, %rax
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

	call	_writeMsgPalabra
	call	_scanPalabra
	movq	%rax, %r12

	cmpq	$0, %r12
	je	_writeError

	call	_writeMsgCapturada
	call	_writePalabra
	call	_writeSalto

	call	_esPalindromo

	cmpq	$1, %rax
	je	_resultadoSi

	call	_writeMsgNo
	call	_exit

_resultadoSi:
	call	_writeMsgSi
	call	_exit
