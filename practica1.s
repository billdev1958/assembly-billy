	.section .data
fullname:
	.ascii "Billy Rivera Salinas\n"
long_name = . - fullname

subject:
        .ascii "Ensambladores\n"
long_subject = . - subject

career:
        .ascii "ICO\n"
long_career = . - career

.equ WRITE,1
.equ STDOUT,1
.equ EXIT,60

	.section .text
	.globl _start

_writeFullName:
        // ACTION 
	movq	$WRITE, %rax
        // CHANEL
        movq    $STDOUT, %rdi
        // ORIGIN POINTER
        movq    $fullname, %rsi
        // SIZE PRINT
        movq    $long_name, %rdx
        syscall
        ret
        
_writeSubject:
        movq    $WRITE, %rax
        movq    $STDOUT, %rdi
        movq    $subject, %rsi
        movq    $long_subject, %rdx
        syscall
        ret

_writeCareer:
        movq    $WRITE, %rax
        movq    $STDOUT, %rdi
        movq    $career, %rsi
        movq    $long_career, %rdx
        syscall
        ret

_exit:
        movq    $EXIT, %rax
        movq    $0, %rdi
        syscall

_start:
         
        call _writeFullName
        call _writeSubject
        call _writeCareer
        call _exit


