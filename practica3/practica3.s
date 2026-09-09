	.section .rodata
prompt:
	.ascii "Ingresa un digito\n"
lp = . - prompt

msg_ok:
	.ascii "Digito valido\n"
lm = . - msg_ok

msg_error:
	.ascii "Esto no es un digito\n"
le = . - msg_error
	
	.section .bss
	.lcomm buffer, 64
	
	.section .text
	.globl _start

.equ WRITE,1
.equ STDOUT,1
.equ INPUT,0
.equ EXIT,60

	.section .text
	.globl _start

_writePrompt:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$prompt, %rsi
	movq	$lp, %rdx
	syscall
	ret

_scanDigit:
	movq	$0, %rax
	movq	$0, %rdi
	movq	$buffer, %rsi
	movq	$64, %rdx
	syscall	
	
	movb	buffer(%rip), %al
	
	cmpb	$'0', %al
	jb	_writeError

	cmpb	$'9', %al
	ja	_writeError

	jmp	_writeOk

_writeError:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_error, %rsi
	movq	$le, %rdx
	syscall
	ret

_writeOk:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_ok, %rsi
	movq	$lm, %rdx
	syscall
	ret
	

_exit:
	movq	$EXIT, %rax
	movq	$0, %rdi
	syscall

_start:
	call _writePrompt
	call _scanDigit
	call _exit	
