	.section .rodata
prompt:
	.ascii "Selecciona operacion (1=suma, 2=resta)\n"
lp = . - prompt

msg_a:
	.ascii "Primer numero: "
la = . - msg_a

msg_b:
	.ascii "Segundo numero: "
lb = . - msg_b

msg_res:
	.ascii "Resultado: "
lr = . - msg_res

msg_error:
	.ascii "Ingresa un numero valido\n"
le = . - msg_error
	
	.section .bss
	.lcomm buffer, 64
	.lcomm numero, 32

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
        movq    $WRITE, %rax
        movq    $STDOUT, %rdi
        movq    $msg_a, %rsi
        movq    $la, %rdx
        syscall
        ret

_writeMsgB:
        movq    $WRITE, %rax
        movq    $STDOUT, %rdi
        movq    $msg_b, %rsi
        movq    $lb, %rdx
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
        movq    $INPUT, %rax
        movq    $INPUT, %rdi
        movq    $buffer, %rsi
        movq    $1, %rdx
        syscall

        cmpq    $1, %rax
        jne     _writeError

        movzbq  buffer(%rip), %r15

        cmpb    $'0', %r15b
        jb      _writeError

        cmpb    $'9', %r15b
        ja      _writeError

_limpiaLinea:
        movq    $INPUT, %rax
        movq    $INPUT, %rdi
        movq    $buffer, %rsi
        movq    $1, %rdx
        syscall

        cmpq    $1, %rax
        jne     _scanFin

        cmpb    $'\n', buffer(%rip)
        jne     _limpiaLinea

_scanFin:
	movq	%r15, %rax
	subq	$'0', %rax
	ret

_suma:
	movq	%r12, %rax
	addq	%r13, %rax
	ret

_resta:
	movq	%r12, %rax
	subq	%r13, %rax
	ret

_writeNumber:
        movq    $numero+31, %rdi
        movb    $'\n', (%rdi)
        decq    %rdi

        movq    $0, %r8
        cmpq    $0, %rax
        jge     _numCiclo
        negq    %rax
        movq    $1, %r8

_numCiclo:
        movq    $0, %rdx
        movq    $10, %rcx
        divq    %rcx
        addb    $'0', %dl
        movb    %dl, (%rdi)
        decq    %rdi
        cmpq    $0, %rax
        jne     _numCiclo

        cmpq    $0, %r8
        je      _numEscribe
        movb    $'-', (%rdi)
        decq    %rdi

_numEscribe:
        incq    %rdi
        movq    $numero+32, %rdx
        subq    %rdi, %rdx
        movq    %rdi, %rsi
        movq    $WRITE, %rax
        movq    $STDOUT, %rdi
        syscall
        ret

_writeError:
        movq    $WRITE, %rax
        movq    $STDOUT, %rdi
        movq    $msg_error, %rsi
        movq    $le, %rdx
        syscall
        jmp	_exit


_exit:
        movq    $EXIT, %rax
        movq    $0, %rdi
        syscall

_start:
        call    _writePrompt
        call    _scanDigit
        movq    %rax, %r14

        cmpq    $1, %r14
        je      _pideNumeros
        cmpq    $2, %r14
        jne     _writeError

_pideNumeros:
        call    _writeMsgA
        call    _scanDigit
        movq    %rax, %r12

        call    _writeMsgB
        call    _scanDigit
        movq    %rax, %r13

        call    _writeMsgRes

        cmpq    $1, %r14
        je      _haceSuma
        call    _resta
        jmp     _escribe

_haceSuma:
        call    _suma

_escribe:
        call    _writeNumber
        call    _exit
