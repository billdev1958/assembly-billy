	.section .rodata
prompt:
	.ascii "Micro ensamblador - Analisis lexico\n"
lp = . - prompt

menu:
	.ascii "\n===== MENU =====\n"
	.ascii "1) Analizar instruccion\n"
	.ascii "2) Salir\n"
	.ascii "Elige una opcion (1-2): "
lm = . - menu

msg_instruccion:
	.ascii "Escribe la instruccion (ej. MOV AL, 05): "
lins = . - msg_instruccion

msg_capturada:
	.ascii "Instruccion capturada: "
lcap = . - msg_capturada

msg_vacia:
	.ascii "No escribiste ninguna instruccion\n"
lvac = . - msg_vacia

msg_salir:
	.ascii "Fin del programa\n"
ls = . - msg_salir

msg_error:
	.ascii "Ingresa una opcion valida (1-2)\n"
le = . - msg_error

msg_analisis:
	.ascii "Analisis:\n"
lana = . - msg_analisis

msg_mnemonico:
	.ascii "Mnemonico: "
lmn = . - msg_mnemonico

msg_destino:
	.ascii "Destino: "
ldes = . - msg_destino

msg_coma:
	.ascii "Coma: ,\n"
lcom = . - msg_coma

msg_fuente:
	.ascii "Fuente: "
lfue = . - msg_fuente

msg_inmediato:
	.ascii "Valor inmediato: "
linm = . - msg_inmediato

msg_error_mnemonico:
	.ascii "Error: falta el mnemonico\n"
lemn = . - msg_error_mnemonico

msg_error_operando:
	.ascii "Error: falta un operando junto a la coma\n"
leop = . - msg_error_operando

msg_error_coma:
	.ascii "Error: falta la coma entre los operandos\n"
leco = . - msg_error_coma

msg_error_sobrante:
	.ascii "Error: hay texto de mas al final de la instruccion\n"
leso = . - msg_error_sobrante

salto:
	.ascii "\n"
lsal = . - salto

	.section .bss
	.lcomm buffer, 64
	.lcomm caracter, 1
	.lcomm mnemonico, 8
	.lcomm operando1, 16
	.lcomm operando2, 16
	.lcomm hayComa, 1

	.section .text
	.globl	_start

.equ WRITE,1
.equ STDOUT,1
.equ INPUT,0
.equ EXIT,60
.equ TAM_BUFFER,64
.equ TAM_MNEMONICO,8
.equ TAM_OPERANDO,16
.equ ERROR_MNEMONICO,1
.equ ERROR_OPERANDO,2
.equ ERROR_COMA,3
.equ ERROR_SOBRANTE,4

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

_writeMsgInstruccion:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_instruccion, %rsi
	movq	$lins, %rdx
	syscall
	ret

_writeMsgCapturada:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_capturada, %rsi
	movq	$lcap, %rdx
	syscall
	ret

_writeMsgVacia:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_vacia, %rsi
	movq	$lvac, %rdx
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

_writeMsgAnalisis:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_analisis, %rsi
	movq	$lana, %rdx
	syscall
	ret

_writeMsgMnemonico:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_mnemonico, %rsi
	movq	$lmn, %rdx
	syscall
	ret

_writeMsgDestino:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_destino, %rsi
	movq	$ldes, %rdx
	syscall
	ret

_writeMsgComa:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_coma, %rsi
	movq	$lcom, %rdx
	syscall
	ret

_writeMsgFuente:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_fuente, %rsi
	movq	$lfue, %rdx
	syscall
	ret

_writeMsgInmediato:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_inmediato, %rsi
	movq	$linm, %rdx
	syscall
	ret

_writeErrorMnemonico:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_error_mnemonico, %rsi
	movq	$lemn, %rdx
	syscall
	ret

_writeErrorOperando:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_error_operando, %rsi
	movq	$leop, %rdx
	syscall
	ret

_writeErrorComa:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_error_coma, %rsi
	movq	$leco, %rdx
	syscall
	ret

_writeErrorSobrante:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_error_sobrante, %rsi
	movq	$leso, %rdx
	syscall
	ret

_writeSalto:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$salto, %rsi
	movq	$lsal, %rdx
	syscall
	ret

_writeToken:
	call	_longitud

	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	syscall

	call	_writeSalto
	ret

_writeBuffer:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$buffer, %rsi
	movq	%r12, %rdx
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
	movq	$2, %rax
	ret

_scanInstruccion:
	movq	$TAM_BUFFER, %rcx
	movq	$buffer, %rdi
	movq	$0, %rax
	rep	stosb
	movq	$0, %r15

_cicloInstruccion:
	movq	$INPUT, %rax
	movq	$INPUT, %rdi
	movq	$caracter, %rsi
	movq	$1, %rdx
	syscall

	cmpq	$1, %rax
	jne	_instruccionFin

	movzbq	caracter(%rip), %rax

	cmpb	$'\n', %al
	je	_instruccionFin

	cmpq	$TAM_BUFFER-1, %r15
	jae	_cicloInstruccion

	cmpb	$'a', %al
	jb	_guardaCaracter

	cmpb	$'z', %al
	ja	_guardaCaracter

	subb	$'a'-'A', %al

_guardaCaracter:
	movb	%al, buffer(%r15)
	incq	%r15
	jmp	_cicloInstruccion

_instruccionFin:
	movq	%r15, %rax
	ret

_longitud:
	movq	$0, %rdx

_cicloLongitud:
	cmpb	$0, (%rsi,%rdx)
	je	_longitudFin

	incq	%rdx
	cmpq	%rcx, %rdx
	jb	_cicloLongitud

_longitudFin:
	ret

_limpiaTokens:
	movq	$TAM_MNEMONICO, %rcx
	movq	$mnemonico, %rdi
	movq	$0, %rax
	rep	stosb

	movq	$TAM_OPERANDO, %rcx
	movq	$operando1, %rdi
	rep	stosb

	movq	$TAM_OPERANDO, %rcx
	movq	$operando2, %rdi
	rep	stosb

	movb	$0, hayComa(%rip)
	ret

_saltaEspacios:
	cmpb	$' ', buffer(%r13)
	je	_avanzaEspacio

	cmpb	$'\t', buffer(%r13)
	jne	_saltaFin

_avanzaEspacio:
	incq	%r13
	jmp	_saltaEspacios

_saltaFin:
	ret

_copiaToken:
	movq	$0, %r14
	decq	%rcx

_cicloToken:
	movb	buffer(%r13), %al

	cmpb	$0, %al
	je	_tokenFin

	cmpb	$' ', %al
	je	_tokenFin

	cmpb	$'\t', %al
	je	_tokenFin

	cmpb	$',', %al
	je	_tokenFin

	cmpq	%rcx, %r14
	jae	_tokenSiguiente

	movb	%al, (%rdi,%r14)
	incq	%r14

_tokenSiguiente:
	incq	%r13
	jmp	_cicloToken

_tokenFin:
	movq	%r14, %rax
	ret

_analiza:
	movq	$0, %r13

	call	_saltaEspacios
	movq	$mnemonico, %rdi
	movq	$TAM_MNEMONICO, %rcx
	call	_copiaToken

	cmpq	$0, %rax
	je	_analizaSinMnemonico

	call	_saltaEspacios
	movq	$operando1, %rdi
	movq	$TAM_OPERANDO, %rcx
	call	_copiaToken

	call	_saltaEspacios
	cmpb	$',', buffer(%r13)
	jne	_analizaFinal

	cmpb	$0, operando1(%rip)
	je	_analizaSinOperando

	movb	$1, hayComa(%rip)
	incq	%r13

	call	_saltaEspacios
	movq	$operando2, %rdi
	movq	$TAM_OPERANDO, %rcx
	call	_copiaToken

	cmpq	$0, %rax
	je	_analizaSinOperando

	call	_saltaEspacios

_analizaFinal:
	cmpb	$0, buffer(%r13)
	je	_analizaCorrecto

	cmpb	$0, hayComa(%rip)
	je	_analizaSinComa

	movq	$ERROR_SOBRANTE, %rax
	ret

_analizaCorrecto:
	movq	$0, %rax
	ret

_analizaSinMnemonico:
	movq	$ERROR_MNEMONICO, %rax
	ret

_analizaSinOperando:
	movq	$ERROR_OPERANDO, %rax
	ret

_analizaSinComa:
	movq	$ERROR_COMA, %rax
	ret

_imprimeAnalisis:
	call	_writeMsgAnalisis

	call	_writeMsgMnemonico
	movq	$mnemonico, %rsi
	movq	$TAM_MNEMONICO, %rcx
	call	_writeToken

	cmpb	$0, operando1(%rip)
	je	_imprimeAnalisisFin

	call	_writeMsgDestino
	movq	$operando1, %rsi
	movq	$TAM_OPERANDO, %rcx
	call	_writeToken

	cmpb	$0, hayComa(%rip)
	je	_imprimeAnalisisFin

	call	_writeMsgComa

	movb	operando2(%rip), %al

	cmpb	$'0', %al
	jb	_imprimeFuente

	cmpb	$'9', %al
	ja	_imprimeFuente

	call	_writeMsgInmediato
	jmp	_imprimeOperando2

_imprimeFuente:
	call	_writeMsgFuente

_imprimeOperando2:
	movq	$operando2, %rsi
	movq	$TAM_OPERANDO, %rcx
	call	_writeToken

_imprimeAnalisisFin:
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
	je	_opcionAnalizar

	cmpq	$2, %rax
	je	_opcionSalir

	call	_writeError
	jmp	_menu

_opcionAnalizar:
	call	_writeMsgInstruccion
	call	_scanInstruccion
	movq	%rax, %r12

	cmpq	$0, %r12
	je	_instruccionVacia

	call	_writeMsgCapturada
	call	_writeBuffer
	call	_writeSalto

	call	_limpiaTokens
	call	_analiza

	cmpq	$ERROR_MNEMONICO, %rax
	je	_errorMnemonico

	cmpq	$ERROR_OPERANDO, %rax
	je	_errorOperando

	cmpq	$ERROR_COMA, %rax
	je	_errorComa

	cmpq	$ERROR_SOBRANTE, %rax
	je	_errorSobrante

	call	_imprimeAnalisis
	jmp	_menu

_errorMnemonico:
	call	_writeErrorMnemonico
	jmp	_menu

_errorOperando:
	call	_writeErrorOperando
	jmp	_menu

_errorComa:
	call	_writeErrorComa
	jmp	_menu

_errorSobrante:
	call	_writeErrorSobrante
	jmp	_menu

_instruccionVacia:
	call	_writeMsgVacia
	jmp	_menu

_opcionSalir:
	call	_writeMsgSalir
	call	_exit
