	.section .rodata
prompt:
	.ascii "Sistema de cajero automatico\n"
lp = . - prompt

menu:
	.ascii "\n===== CAJERO AUTOMATICO =====\n"
	.ascii "1) Consultar saldo\n"
	.ascii "2) Depositar\n"
	.ascii "3) Retirar\n"
	.ascii "4) Salir\n"
	.ascii "Elige una opcion (1-4): "
lm = . - menu

msg_saldo:
	.ascii "Saldo actual: $"
lsal = . - msg_saldo

msg_deposito:
	.ascii "Ingresa el monto a depositar: $"
ldep = . - msg_deposito

msg_retiro:
	.ascii "Ingresa el monto a retirar: $"
lret = . - msg_retiro

msg_dep_ok:
	.ascii "Deposito realizado con exito\n"
ldok = . - msg_dep_ok

msg_ret_ok:
	.ascii "Retiro realizado con exito\n"
lrok = . - msg_ret_ok

msg_salir:
	.ascii "Gracias por usar el cajero. Fin del programa\n"
ls = . - msg_salir

msg_error:
	.ascii "Error: ingresa una opcion valida (1-4)\n"
le = . - msg_error

msg_error_monto:
	.ascii "Error: el monto debe ser un numero entero mayor que cero\n"
lem = . - msg_error_monto

msg_error_fondos:
	.ascii "Error: fondos insuficientes para realizar el retiro\n"
lef = . - msg_error_fondos

	.section .data
saldo:
	.quad 1000

	.section .bss
	.lcomm buffer, 64
	.lcomm cadena, 32

	.section .text
	.globl	_start

.equ WRITE,1
.equ STDOUT,1
.equ INPUT,0
.equ EXIT,60
.equ MAXDIGITOS,9
.equ BASE,10

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

_writeMsgSaldo:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_saldo, %rsi
	movq	$lsal, %rdx
	syscall
	ret

_writeMsgDeposito:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_deposito, %rsi
	movq	$ldep, %rdx
	syscall
	ret

_writeMsgRetiro:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_retiro, %rsi
	movq	$lret, %rdx
	syscall
	ret

_writeMsgDepOk:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_dep_ok, %rsi
	movq	$ldok, %rdx
	syscall
	ret

_writeMsgRetOk:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_ret_ok, %rsi
	movq	$lrok, %rdx
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

_writeErrorMonto:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_error_monto, %rsi
	movq	$lem, %rdx
	syscall
	ret

_writeErrorFondos:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_error_fondos, %rsi
	movq	$lef, %rdx
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

_scanMonto:
	xorq	%r12, %r12
	xorq	%r13, %r13
	xorq	%r14, %r14

_cicloMonto:
	movq	$INPUT, %rax
	movq	$INPUT, %rdi
	movq	$buffer, %rsi
	movq	$1, %rdx
	syscall

	cmpq	$1, %rax
	jne	_montoFin

	movzbq	buffer(%rip), %r15

	cmpb	$'
', %r15b
	je	_montoFin

	cmpq	$1, %r12
	je	_cicloMonto

	cmpb	$'0', %r15b
	jb	_montoMarcaInvalido

	cmpb	$'9', %r15b
	ja	_montoMarcaInvalido

	subq	$'0', %r15
	imulq	$BASE, %r13
	addq	%r15, %r13

	incq	%r14
	cmpq	$MAXDIGITOS, %r14
	ja	_montoMarcaInvalido

	jmp	_cicloMonto

_montoMarcaInvalido:
	movq	$1, %r12
	jmp	_cicloMonto

_montoFin:
	cmpq	$1, %r12
	je	_montoInvalido

	cmpq	$0, %r14
	je	_montoInvalido

	movq	%r13, %rax
	ret

_montoInvalido:
	movq	$-1, %rax
	ret

_imprimeNumero:
	movq	$cadena+31, %rdi
	movb	$'\n', (%rdi)
	movq	$1, %r14
	movq	$BASE, %rbx

_cicloDigitos:
	xorq	%rdx, %rdx
	divq	%rbx
	addb	$'0', %dl
	decq	%rdi
	movb	%dl, (%rdi)
	incq	%r14

	cmpq	$0, %rax
	jne	_cicloDigitos

	movq	$WRITE, %rax
	movq	%rdi, %rsi
	movq	%r14, %rdx
	movq	$STDOUT, %rdi
	syscall
	ret

_writeSaldo:
	call	_writeMsgSaldo
	movq	saldo(%rip), %rax
	call	_imprimeNumero
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
	je	_opcionSaldo

	cmpq	$2, %rax
	je	_opcionDepositar

	cmpq	$3, %rax
	je	_opcionRetirar

	cmpq	$4, %rax
	je	_opcionSalir

	call	_writeError
	jmp	_menu

_opcionSaldo:
	call	_writeSaldo
	jmp	_menu

_opcionDepositar:
	call	_writeMsgDeposito
	call	_scanMonto

	cmpq	$0, %rax
	jle	_errorMonto

	addq	%rax, saldo(%rip)
	call	_writeMsgDepOk
	call	_writeSaldo
	jmp	_menu

_opcionRetirar:
	call	_writeMsgRetiro
	call	_scanMonto

	cmpq	$0, %rax
	jle	_errorMonto

	cmpq	saldo(%rip), %rax
	ja	_errorFondos

	subq	%rax, saldo(%rip)
	call	_writeMsgRetOk
	call	_writeSaldo
	jmp	_menu

_errorMonto:
	call	_writeErrorMonto
	jmp	_menu

_errorFondos:
	call	_writeErrorFondos
	call	_writeSaldo
	jmp	_menu

_opcionSalir:
	call	_writeMsgSalir
	call	_exit
