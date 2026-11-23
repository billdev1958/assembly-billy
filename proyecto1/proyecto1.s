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
	.ascii "Escribe la instruccion (ej. movb $5, %al): "
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

# ============================================================
# SEGUNDA PARTE: validacion sintactica
# Mensajes y tabla de instrucciones admitidas
# ============================================================

msg_validacion:
	.ascii "Validacion:\n"
lval = . - msg_validacion

msg_valida:
	.ascii "Instruccion valida\n"
lvda = . - msg_valida

msg_no_reconocida:
	.ascii "ERROR: instruccion no reconocida.\n"
lnre = . - msg_no_reconocida

msg_sin_operando:
	.ascii "ERROR: falta el operando.\n"
lsop = . - msg_sin_operando

msg_sin_segundo:
	.ascii "ERROR: falta el segundo operando.\n"
lsse = . - msg_sin_segundo

msg_sobra_operando:
	.ascii "ERROR: la instruccion solo lleva un operando.\n"
lsob = . - msg_sobra_operando

msg_registro_invalido:
	.ascii "ERROR: registro no valido para esta instruccion.\n"
lrin = . - msg_registro_invalido

msg_inmediato_invalido:
	.ascii "ERROR: valor inmediato no valido.\n"
liin = . - msg_inmediato_invalido

# ============================================================
# TERCERA PARTE: traduccion a codigo maquina
# Mensajes, tabla de instrucciones y tabla de registros
# ============================================================

msg_codigo:
	.ascii "Codigo maquina: "
lcod = . - msg_codigo

msg_error_punto:
	.ascii "Error. "
lerr = . - msg_error_punto

msg_requiere16:
	.ascii " requiere un registro de 16 bits.\n"
lr16 = . - msg_requiere16

msg_excede8:
	.ascii "Error. El valor excede el rango de 8 bits.\n"
lex8 = . - msg_excede8

msg_excede16:
	.ascii "Error. El valor excede el rango de 16 bits.\n"
lex16 = . - msg_excede16

msg_operando:
	.ascii "Operando: "
lope = . - msg_operando

msg_sin_porcentaje:
	.ascii "ERROR: el registro debe empezar con %.\n"
lspo = . - msg_sin_porcentaje

msg_sin_pesos:
	.ascii "ERROR: el primer operando debe ser un valor inmediato con $.\n"
lspe = . - msg_sin_pesos

msg_sufijo:
	.ascii "ERROR: el sufijo del mnemonico no corresponde al tamano del registro.\n"
lsuf = . - msg_sufijo

espacio:
	.ascii " "
lesp = . - espacio

# Codificacion de x86-64, la misma que genera GAS
# Cada entrada: mnemonico (8), tipo (1), base de 8 bits (1),
# base de 16 bits (1), byte previo de 16 bits (1)
# tipo 0 = un operando, tipo 1 = registro e inmediato
# base 0 = la instruccion no admite registros de ese tamano
# byte previo 0 = la instruccion no lleva byte antes de la base
# El ultimo byte del codigo se calcula como base + identificador del registro
# Con registros de 16 bits se antepone el prefijo 66
tabla:
	.ascii "MOV\0\0\0\0\0"
	.byte 1, 0xB0, 0xB8, 0

	.ascii "INC\0\0\0\0\0"
	.byte 0, 0, 0xC0, 0xFF

	.ascii "DEC\0\0\0\0\0"
	.byte 0, 0, 0xC8, 0xFF

	.ascii "PUSH\0\0\0\0"
	.byte 0, 0, 0x50, 0

	.ascii "POP\0\0\0\0\0"
	.byte 0, 0, 0x58, 0

# Cada entrada: registro (4), identificador (1), tamano en bits (1)
registros:
	.ascii "AL\0\0"
	.byte 0, 8

	.ascii "CL\0\0"
	.byte 1, 8

	.ascii "DL\0\0"
	.byte 2, 8

	.ascii "BL\0\0"
	.byte 3, 8

	.ascii "AH\0\0"
	.byte 4, 8

	.ascii "CH\0\0"
	.byte 5, 8

	.ascii "DH\0\0"
	.byte 6, 8

	.ascii "BH\0\0"
	.byte 7, 8

	.ascii "AX\0\0"
	.byte 0, 16

	.ascii "CX\0\0"
	.byte 1, 16

	.ascii "DX\0\0"
	.byte 2, 16

	.ascii "BX\0\0"
	.byte 3, 16

	.ascii "SP\0\0"
	.byte 4, 16

	.ascii "BP\0\0"
	.byte 5, 16

	.ascii "SI\0\0"
	.byte 6, 16

	.ascii "DI\0\0"
	.byte 7, 16

	.section .bss
	.lcomm buffer, 64
	.lcomm caracter, 1
	.lcomm mnemonico, 8
	.lcomm operando1, 16
	.lcomm operando2, 16
	.lcomm hayComa, 1

# ===== SEGUNDA PARTE: variables =====
	.lcomm cadena, 4

# ===== TERCERA PARTE: variables =====
	.lcomm codigo, 8
	.lcomm sufijo, 1

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

# ===== SEGUNDA PARTE: constantes =====
.equ TAM_REGISTRO,4
.equ TAM_ENTRADA,12
.equ TOTAL_ENTRADAS,5
.equ ENT_TIPO,8
.equ BASE,10
.equ BASE_HEX,16
.equ MAX_INMEDIATO,255

# ===== TERCERA PARTE: constantes =====
.equ ENT_BASE8,9
.equ ENT_BASE16,10
.equ ENT_PREVIO16,11
.equ PREFIJO_16,0x66
.equ BASE_OCT,8
.equ TAM_ENT_REGISTRO,6
.equ TOTAL_REGISTROS,16
.equ REG_ID,4
.equ REG_TAM,5
.equ TAM_16,16
.equ MAX_INMEDIATO16,65535

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

	cmpb	$0, hayComa(%rip)
	je	_imprimeUnOperando

	cmpb	$'$', operando1(%rip)
	jne	_imprimeFuente

	call	_writeMsgInmediato
	jmp	_imprimeOperando1

_imprimeFuente:
	call	_writeMsgFuente

_imprimeOperando1:
	movq	$operando1, %rsi
	movq	$TAM_OPERANDO, %rcx
	call	_writeToken

	call	_writeMsgComa

	call	_writeMsgDestino
	movq	$operando2, %rsi
	movq	$TAM_OPERANDO, %rcx
	call	_writeToken
	ret

_imprimeUnOperando:
	call	_writeMsgOperando
	movq	$operando1, %rsi
	movq	$TAM_OPERANDO, %rcx
	call	_writeToken

_imprimeAnalisisFin:
	ret

# ============================================================
# SEGUNDA PARTE: validacion sintactica
# Rutinas: mensajes, busqueda en la tabla y validacion
# ============================================================

_writeMsgValidacion:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_validacion, %rsi
	movq	$lval, %rdx
	syscall
	ret

_writeMsgValida:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_valida, %rsi
	movq	$lvda, %rdx
	syscall
	ret

_writeErrorNoReconocida:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_no_reconocida, %rsi
	movq	$lnre, %rdx
	syscall
	ret

_writeErrorSinOperando:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_sin_operando, %rsi
	movq	$lsop, %rdx
	syscall
	ret

_writeErrorSinSegundo:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_sin_segundo, %rsi
	movq	$lsse, %rdx
	syscall
	ret

_writeErrorSobraOperando:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_sobra_operando, %rsi
	movq	$lsob, %rdx
	syscall
	ret

_writeErrorRegistro:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_registro_invalido, %rsi
	movq	$lrin, %rdx
	syscall
	ret

_writeErrorInmediato:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_inmediato_invalido, %rsi
	movq	$liin, %rdx
	syscall
	ret

_digitoHex:
	cmpq	$BASE, %rax
	jb	_digitoDecimal

	addq	$'A'-BASE, %rax
	ret

_digitoDecimal:
	addq	$'0', %rax
	ret

_writeHex:
	movzbq	%al, %r15

	movq	%r15, %rax
	shrq	$4, %rax
	call	_digitoHex
	movb	%al, cadena(%rip)

	movq	%r15, %rax
	andq	$15, %rax
	call	_digitoHex
	movb	%al, cadena+1(%rip)

	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$cadena, %rsi
	movq	$2, %rdx
	syscall
	ret

# Si el mnemonico no esta en la tabla y termina en B o W, guarda esa
# letra en sufijo, la quita y vuelve a buscar (MOVB -> MOV, PUSHW -> PUSH)
_buscaMnemonico:
	movb	$0, sufijo(%rip)

_buscaMnemonicoTabla:
	movq	$0, %r12

_cicloMnemonico:
	cmpq	$TOTAL_ENTRADAS, %r12
	jae	_mnemonicoSufijo

	imulq	$TAM_ENTRADA, %r12, %r13
	addq	$tabla, %r13

	movq	$mnemonico, %rsi
	movq	%r13, %rdi
	movq	$TAM_MNEMONICO, %rcx
	repe	cmpsb
	je	_mnemonicoExiste

	incq	%r12
	jmp	_cicloMnemonico

_mnemonicoExiste:
	movq	%r12, %rax
	ret

_mnemonicoSufijo:
	cmpb	$0, sufijo(%rip)
	jne	_mnemonicoNoExiste

	movq	$mnemonico, %rsi
	movq	$TAM_MNEMONICO, %rcx
	call	_longitud

	movb	mnemonico-1(%rdx), %al

	cmpb	$'B', %al
	je	_quitaSufijo

	cmpb	$'W', %al
	jne	_mnemonicoNoExiste

_quitaSufijo:
	movb	%al, sufijo(%rip)
	movb	$0, mnemonico-1(%rdx)
	jmp	_buscaMnemonicoTabla

_mnemonicoNoExiste:
	movq	$-1, %rax
	ret

# ============================================================
# TERCERA PARTE: traduccion a codigo maquina
# Rutinas: mensajes, busqueda del registro y generacion de bytes
# ============================================================

_writeMsgCodigo:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_codigo, %rsi
	movq	$lcod, %rdx
	syscall
	ret

_writeEspacio:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$espacio, %rsi
	movq	$lesp, %rdx
	syscall
	ret

_writeErrorExcede8:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_excede8, %rsi
	movq	$lex8, %rdx
	syscall
	ret

_writeErrorExcede16:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_excede16, %rsi
	movq	$lex16, %rdx
	syscall
	ret

_writeErrorRequiere16:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_error_punto, %rsi
	movq	$lerr, %rdx
	syscall

	movq	$mnemonico, %rsi
	movq	$TAM_MNEMONICO, %rcx
	call	_longitud

	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	syscall

	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_requiere16, %rsi
	movq	$lr16, %rdx
	syscall
	ret

_writeMsgOperando:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_operando, %rsi
	movq	$lope, %rdx
	syscall
	ret

_writeErrorSinPorcentaje:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_sin_porcentaje, %rsi
	movq	$lspo, %rdx
	syscall
	ret

_writeErrorSinPesos:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_sin_pesos, %rsi
	movq	$lspe, %rdx
	syscall
	ret

_writeErrorSufijo:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_sufijo, %rsi
	movq	$lsuf, %rdx
	syscall
	ret

# Entrada: rsi = operando que empieza con %
# Deja en r14 la entrada del registro escrito despues del %
_buscaRegistro:
	movq	%rsi, %r15
	incq	%r15
	movq	$0, %r12

_cicloRegistro:
	cmpq	$TOTAL_REGISTROS, %r12
	jae	_registroNoExiste

	imulq	$TAM_ENT_REGISTRO, %r12, %r14
	addq	$registros, %r14

	movq	%r15, %rsi
	movq	%r14, %rdi
	movq	$TAM_REGISTRO, %rcx
	repe	cmpsb
	je	_registroExiste

	incq	%r12
	jmp	_cicloRegistro

_registroExiste:
	movq	%r12, %rax
	ret

_registroNoExiste:
	movq	$-1, %rax
	ret

# Entrada: r13 = entrada de la instruccion, r14 = entrada del registro,
# r15 = valor inmediato. Salida: bytes en codigo y su cantidad en rax
_genera:
	movq	$0, %r12

	cmpb	$TAM_16, REG_TAM(%r14)
	jne	_generaBase8

	movb	$PREFIJO_16, codigo(%r12)
	incq	%r12

	movb	ENT_PREVIO16(%r13), %al

	cmpb	$0, %al
	je	_generaBase16

	movb	%al, codigo(%r12)
	incq	%r12

_generaBase16:
	movb	ENT_BASE16(%r13), %al
	jmp	_generaOpcode

_generaBase8:
	movb	ENT_BASE8(%r13), %al

_generaOpcode:
	addb	REG_ID(%r14), %al
	movb	%al, codigo(%r12)
	incq	%r12

	cmpb	$1, ENT_TIPO(%r13)
	jne	_generaFin

	movb	%r15b, codigo(%r12)
	incq	%r12

	cmpb	$TAM_16, REG_TAM(%r14)
	jne	_generaFin

	movq	%r15, %rax
	shrq	$8, %rax
	movb	%al, codigo(%r12)
	incq	%r12

_generaFin:
	movq	%r12, %rax
	ret

_writeCodigo:
	movq	%rax, %r14

	call	_writeMsgCodigo
	movq	$0, %r12

_cicloCodigo:
	movb	codigo(%r12), %al
	call	_writeHex

	incq	%r12
	cmpq	%r14, %r12
	jae	_codigoFin

	call	_writeEspacio
	jmp	_cicloCodigo

_codigoFin:
	call	_writeSalto
	ret

# Convierte el inmediato escrito despues del $ en operando1
# Como en GAS: 0x indica hexadecimal, un 0 inicial indica octal
# y cualquier otro caso es decimal. La base queda en rbx
_validaInmediato:
	movq	$operando1+1, %rsi
	movq	$TAM_OPERANDO-1, %rcx
	call	_longitud

	movq	$0, %r15
	movq	$0, %r12
	movq	$BASE, %rbx

	cmpq	$0, %rdx
	je	_inmediatoInvalido

	cmpb	$'0', operando1+1(%rip)
	jne	_cicloInmediato

	movq	$BASE_OCT, %rbx

	cmpb	$'X', operando1+2(%rip)
	jne	_cicloInmediato

	movq	$BASE_HEX, %rbx
	movq	$2, %r12

	cmpq	%rdx, %r12
	jae	_inmediatoInvalido

_cicloInmediato:
	cmpq	%rdx, %r12
	jae	_inmediatoFin

	movzbq	operando1+1(%r12), %rax

	cmpb	$'0', %al
	jb	_inmediatoInvalido

	cmpb	$'9', %al
	jbe	_digitoNumero

	cmpb	$'A', %al
	jb	_inmediatoInvalido

	cmpb	$'F', %al
	ja	_inmediatoInvalido

	subq	$'A'-BASE, %rax
	jmp	_digitoAcumula

_digitoNumero:
	subq	$'0', %rax

_digitoAcumula:
	cmpq	%rbx, %rax
	jae	_inmediatoInvalido

	imulq	%rbx, %r15
	addq	%rax, %r15

	incq	%r12
	jmp	_cicloInmediato

_inmediatoFin:
	movq	%r15, %rax
	ret

_inmediatoInvalido:
	movq	$-1, %rax
	ret

_valida:
	call	_writeMsgValidacion

	call	_buscaMnemonico

	cmpq	$-1, %rax
	je	_validaNoReconocida

	cmpb	$0, operando1(%rip)
	je	_validaSinOperando

	cmpb	$1, ENT_TIPO(%r13)
	je	_validaDosOperandos

	cmpb	$0, hayComa(%rip)
	jne	_validaSobraOperando

	movq	$operando1, %rsi
	jmp	_validaRegistro

_validaDosOperandos:
	cmpb	$0, hayComa(%rip)
	je	_validaSinSegundo

	movq	$operando2, %rsi

_validaRegistro:
	cmpb	$'%', (%rsi)
	jne	_validaSinPorcentaje

	call	_buscaRegistro

	cmpq	$-1, %rax
	je	_validaRegistroInvalido

	cmpb	$TAM_16, REG_TAM(%r14)
	je	_validaSufijo16

	cmpb	$0, ENT_BASE8(%r13)
	je	_validaRequiere16

	cmpb	$'W', sufijo(%rip)
	je	_validaSufijoIncorrecto

	jmp	_validaTipo

_validaSufijo16:
	cmpb	$'B', sufijo(%rip)
	je	_validaSufijoIncorrecto

_validaTipo:
	cmpb	$1, ENT_TIPO(%r13)
	jne	_validaCorrecta

	cmpb	$'$', operando1(%rip)
	jne	_validaSinPesos

	call	_validaInmediato

	cmpq	$-1, %rax
	je	_validaInmediatoInvalido

	cmpb	$TAM_16, REG_TAM(%r14)
	je	_validaRango16

	cmpq	$MAX_INMEDIATO, %rax
	ja	_validaExcede8

	jmp	_validaCorrecta

_validaRango16:
	cmpq	$MAX_INMEDIATO16, %rax
	ja	_validaExcede16

# ===== TERCERA PARTE: traduccion a codigo maquina =====
_validaCorrecta:
	call	_writeMsgValida
	call	_genera
	call	_writeCodigo
	ret

_validaRequiere16:
	call	_writeErrorRequiere16
	ret

_validaExcede8:
	call	_writeErrorExcede8
	ret

_validaExcede16:
	call	_writeErrorExcede16
	ret

_validaSinPorcentaje:
	call	_writeErrorSinPorcentaje
	ret

_validaSinPesos:
	call	_writeErrorSinPesos
	ret

_validaSufijoIncorrecto:
	call	_writeErrorSufijo
	ret

_validaNoReconocida:
	call	_writeErrorNoReconocida
	ret

_validaSinOperando:
	call	_writeErrorSinOperando
	ret

_validaSinSegundo:
	call	_writeErrorSinSegundo
	ret

_validaSobraOperando:
	call	_writeErrorSobraOperando
	ret

_validaRegistroInvalido:
	call	_writeErrorRegistro
	ret

_validaInmediatoInvalido:
	call	_writeErrorInmediato
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

# ===== SEGUNDA PARTE: validacion sintactica =====
	call	_valida
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
