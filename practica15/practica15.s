	.section .rodata
prompt:
	.ascii "Agenda de contactos\n"
lp = . - prompt

menu:
	.ascii "\n===== MENU =====\n"
	.ascii "1) Registrar contacto\n"
	.ascii "2) Mostrar contactos\n"
	.ascii "3) Buscar contacto\n"
	.ascii "4) Eliminar contacto\n"
	.ascii "5) Salir\n"
	.ascii "Elige una opcion (1-5): "
lm = . - menu

msg_nombre:
	.ascii "Nombre: "
ln = . - msg_nombre

msg_telefono:
	.ascii "Telefono: "
lt = . - msg_telefono

msg_buscar:
	.ascii "Nombre a buscar: "
lb = . - msg_buscar

msg_eliminar:
	.ascii "Nombre a eliminar: "
lel = . - msg_eliminar

msg_guardado:
	.ascii "Contacto guardado\n"
lg = . - msg_guardado

msg_lista:
	.ascii "Contactos almacenados:\n"
ll = . - msg_lista

msg_encontrado:
	.ascii "Contacto encontrado:\n"
lenc = . - msg_encontrado

msg_eliminado:
	.ascii "Contacto eliminado\n"
leli = . - msg_eliminado

msg_vacia:
	.ascii "No hay contactos almacenados\n"
lv = . - msg_vacia

msg_llena:
	.ascii "La agenda esta llena (maximo 9 contactos)\n"
lll = . - msg_llena

msg_no_encontrado:
	.ascii "Contacto no encontrado\n"
lne = . - msg_no_encontrado

msg_dato:
	.ascii "Ingresa un dato valido\n"
ld = . - msg_dato

msg_salir:
	.ascii "Fin del programa\n"
ls = . - msg_salir

msg_error:
	.ascii "Ingresa una opcion valida (1-5)\n"
le = . - msg_error

separador:
	.ascii " - "
lsep = . - separador

salto:
	.ascii "\n"
lsal = . - salto

	.section .bss
	.lcomm buffer, 64
	.lcomm caracter, 1
	.lcomm cadena, 16
	.lcomm total, 8
	.lcomm agenda, 288

	.section .text
	.globl	_start

.equ WRITE,1
.equ STDOUT,1
.equ INPUT,0
.equ EXIT,60
.equ TAM_BUFFER,64
.equ TAM_NOMBRE,20
.equ TAM_TELEFONO,12
.equ TAM_CONTACTO,32
.equ MAX_CONTACTOS,9

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

_writeMsgNombre:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_nombre, %rsi
	movq	$ln, %rdx
	syscall
	ret

_writeMsgTelefono:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_telefono, %rsi
	movq	$lt, %rdx
	syscall
	ret

_writeMsgBuscar:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_buscar, %rsi
	movq	$lb, %rdx
	syscall
	ret

_writeMsgEliminar:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_eliminar, %rsi
	movq	$lel, %rdx
	syscall
	ret

_writeMsgGuardado:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_guardado, %rsi
	movq	$lg, %rdx
	syscall
	ret

_writeMsgLista:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_lista, %rsi
	movq	$ll, %rdx
	syscall
	ret

_writeMsgEncontrado:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_encontrado, %rsi
	movq	$lenc, %rdx
	syscall
	ret

_writeMsgEliminado:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_eliminado, %rsi
	movq	$leli, %rdx
	syscall
	ret

_writeMsgVacia:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_vacia, %rsi
	movq	$lv, %rdx
	syscall
	ret

_writeMsgLlena:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_llena, %rsi
	movq	$lll, %rdx
	syscall
	ret

_writeMsgNoEncontrado:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_no_encontrado, %rsi
	movq	$lne, %rdx
	syscall
	ret

_writeMsgDato:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$msg_dato, %rsi
	movq	$ld, %rdx
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

_writeSeparador:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$separador, %rsi
	movq	$lsep, %rdx
	syscall
	ret

_writeSalto:
	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$salto, %rsi
	movq	$lsal, %rdx
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
	movq	$5, %rax
	ret

_scanLinea:
	movq	$TAM_BUFFER, %rcx
	movq	$buffer, %rdi
	movq	$0, %rax
	rep	stosb
	movq	$0, %r15

_cicloLinea:
	movq	$INPUT, %rax
	movq	$INPUT, %rdi
	movq	$caracter, %rsi
	movq	$1, %rdx
	syscall

	cmpq	$1, %rax
	jne	_lineaFin

	movzbq	caracter(%rip), %rax

	cmpb	$'\n', %al
	je	_lineaFin

	cmpq	$TAM_BUFFER-1, %r15
	jae	_cicloLinea

	movb	%al, buffer(%r15)
	incq	%r15
	jmp	_cicloLinea

_lineaFin:
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

_registraContacto:
	movq	total(%rip), %r12
	imulq	$TAM_CONTACTO, %r12, %r13
	addq	$agenda, %r13

	call	_writeMsgNombre
	call	_scanLinea

	cmpq	$0, %rax
	je	_datoInvalido

	movq	$buffer, %rsi
	movq	%r13, %rdi
	movq	$TAM_NOMBRE, %rcx
	rep	movsb
	movb	$0, TAM_NOMBRE-1(%r13)

	call	_writeMsgTelefono
	call	_scanLinea

	cmpq	$0, %rax
	je	_datoInvalido

	movq	$buffer, %rsi
	movq	%r13, %rdi
	addq	$TAM_NOMBRE, %rdi
	movq	$TAM_TELEFONO, %rcx
	rep	movsb
	movb	$0, TAM_NOMBRE+TAM_TELEFONO-1(%r13)

	incq	total(%rip)
	call	_writeMsgGuardado
	ret

_datoInvalido:
	call	_writeMsgDato
	ret

_imprimeContacto:
	imulq	$TAM_CONTACTO, %r12, %r13
	addq	$agenda, %r13

	movq	%r12, %rax
	addq	$'1', %rax
	movb	%al, cadena(%rip)
	movb	$')', cadena+1(%rip)
	movb	$' ', cadena+2(%rip)

	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	movq	$cadena, %rsi
	movq	$3, %rdx
	syscall

	movq	%r13, %rsi
	movq	$TAM_NOMBRE, %rcx
	call	_longitud

	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	syscall

	call	_writeSeparador

	movq	%r13, %rsi
	addq	$TAM_NOMBRE, %rsi
	movq	$TAM_TELEFONO, %rcx
	call	_longitud

	movq	$WRITE, %rax
	movq	$STDOUT, %rdi
	syscall

	call	_writeSalto
	ret

_muestraContactos:
	cmpq	$0, total(%rip)
	je	_agendaVacia

	call	_writeMsgLista
	movq	$0, %r12

_cicloLista:
	call	_imprimeContacto

	incq	%r12
	cmpq	total(%rip), %r12
	jb	_cicloLista
	ret

_agendaVacia:
	call	_writeMsgVacia
	ret

_buscaContacto:
	movq	$0, %r12

_cicloBusca:
	cmpq	total(%rip), %r12
	jae	_noEncontrado

	imulq	$TAM_CONTACTO, %r12, %r13
	addq	$agenda, %r13

	movq	$buffer, %rsi
	movq	%r13, %rdi
	movq	$TAM_NOMBRE-1, %rcx
	repe	cmpsb
	je	_encontrado

	incq	%r12
	jmp	_cicloBusca

_encontrado:
	movq	%r12, %rax
	ret

_noEncontrado:
	movq	$-1, %rax
	ret

_eliminaContacto:
	movq	total(%rip), %r14
	decq	%r14
	movq	%r14, total(%rip)

_cicloElimina:
	cmpq	%r14, %r12
	jae	_eliminaFin

	imulq	$TAM_CONTACTO, %r12, %rdi
	addq	$agenda, %rdi
	movq	%rdi, %rsi
	addq	$TAM_CONTACTO, %rsi
	movq	$TAM_CONTACTO, %rcx
	rep	movsb

	incq	%r12
	jmp	_cicloElimina

_eliminaFin:
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
	je	_opcionRegistrar

	cmpq	$2, %rax
	je	_opcionMostrar

	cmpq	$3, %rax
	je	_opcionBuscar

	cmpq	$4, %rax
	je	_opcionEliminar

	cmpq	$5, %rax
	je	_opcionSalir

	call	_writeError
	jmp	_menu

_opcionRegistrar:
	cmpq	$MAX_CONTACTOS, total(%rip)
	jae	_agendaLlena

	call	_registraContacto
	jmp	_menu

_agendaLlena:
	call	_writeMsgLlena
	jmp	_menu

_opcionMostrar:
	call	_muestraContactos
	jmp	_menu

_opcionBuscar:
	call	_writeMsgBuscar
	call	_scanLinea
	call	_buscaContacto

	cmpq	$-1, %rax
	je	_noExiste

	call	_writeMsgEncontrado
	call	_imprimeContacto
	jmp	_menu

_opcionEliminar:
	call	_writeMsgEliminar
	call	_scanLinea
	call	_buscaContacto

	cmpq	$-1, %rax
	je	_noExiste

	call	_eliminaContacto
	call	_writeMsgEliminado
	jmp	_menu

_noExiste:
	call	_writeMsgNoEncontrado
	jmp	_menu

_opcionSalir:
	call	_writeMsgSalir
	call	_exit
