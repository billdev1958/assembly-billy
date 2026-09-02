# Guía de GNU Assembler (GAS) — x86-64 en Linux

Guía práctica para aprender ensamblador con las herramientas GNU (`as`, `ld`, `gcc`, `gdb`),
desde el "Hola mundo" hasta funciones, arreglos y llamadas al sistema.

Todos los ejemplos de esta guía fueron **compilados y ejecutados** en:

- Arquitectura: `x86_64`
- Ensamblador: GNU `as` (binutils 2.46)
- Sistema: Linux (Fedora)
- Sintaxis: **AT&T** (la nativa de GAS)

---

## Índice

1. [Instalación de herramientas](#1-instalación-de-herramientas)
2. [Sintaxis AT&T](#2-sintaxis-att)
3. [Hola mundo (llamadas al sistema)](#3-hola-mundo-llamadas-al-sistema)
4. [Anatomía de un programa](#4-anatomía-de-un-programa)
5. [Ciclo de trabajo: ensamblar, enlazar, ejecutar](#5-ciclo-de-trabajo-ensamblar-enlazar-ejecutar)
6. [Registros](#6-registros)
7. [Sufijos de tamaño](#7-sufijos-de-tamaño)
8. [Modos de direccionamiento](#8-modos-de-direccionamiento)
9. [Instrucciones de movimiento de datos](#9-instrucciones-de-movimiento-de-datos)
10. [Operaciones aritméticas](#10-operaciones-aritméticas)
11. [Operaciones lógicas y de bits](#11-operaciones-lógicas-y-de-bits)
12. [Banderas, comparaciones y saltos](#12-banderas-comparaciones-y-saltos)
13. [La pila](#13-la-pila)
14. [Funciones y convención de llamada (System V ABI)](#14-funciones-y-convención-de-llamada-system-v-abi)
15. [Programa 2: Hola mundo con printf (libc)](#15-programa-2-hola-mundo-con-printf-libc)
16. [Programa 3: operaciones aritméticas completas](#16-programa-3-operaciones-aritméticas-completas)
17. [Programa 4: bucles, condicionales, arreglos y recursión](#17-programa-4-bucles-condicionales-arreglos-y-recursión)
18. [Programa 5: entrada de datos](#18-programa-5-entrada-de-datos)
19. [Tabla de llamadas al sistema](#19-tabla-de-llamadas-al-sistema)
20. [Directivas de GAS (referencia)](#20-directivas-de-gas-referencia)
21. [Depuración con GDB](#21-depuración-con-gdb)
22. [Ver el ensamblador que genera el compilador](#22-ver-el-ensamblador-que-genera-el-compilador)
23. [Makefile](#23-makefile)
24. [Modo 32 bits](#24-modo-32-bits)
25. [Errores comunes](#25-errores-comunes)
26. [Referencias](#26-referencias)

---

## 1. Instalación de herramientas

Todo lo necesario viene en `binutils` (contiene `as`, `ld`, `objdump`, `readelf`), más `gcc` y `gdb`.

```bash
# Fedora / RHEL
sudo dnf install binutils gcc gdb make

# Debian / Ubuntu
sudo apt install binutils gcc gdb make

# Arch
sudo pacman -S binutils gcc gdb make
```

Verifica que todo esté instalado:

```bash
as --version | head -1
ld --version | head -1
gcc --version | head -1
gdb --version | head -1
uname -m          # debe imprimir: x86_64
```

---

## 2. Sintaxis AT&T

GAS usa **sintaxis AT&T**, la única que se emplea en esta guía. Sus reglas son pocas y
conviene tenerlas presentes desde el principio:

| Regla | Forma | Ejemplo |
|---|---|---|
| El destino va **al final** | `mov origen, destino` | `movq %rax, %rbx`  → `rbx = rax` |
| Los registros llevan `%` | `%rax` | `addq %rcx, %rdx` |
| Los inmediatos llevan `$` | `$5` | `movq $5, %rax` → `rax = 5` |
| El tamaño va como sufijo | `q` `l` `w` `b` | `movq` (8 bytes), `movl` (4 bytes) |
| La memoria se escribe con paréntesis | `desp(base, indice, escala)` | `movq 8(%rbx,%rcx,8), %rax` |
| Sin `$`, una etiqueta significa su **contenido** | `var(%rip)` | `movq var(%rip), %rax` → `rax = var` |
| Con `$` (o con `lea`), significa su **dirección** | `$var` / `leaq var(%rip), %rax` | `rax = &var` |
| Comentarios | `#` o `/* ... */` | `movq $1, %rax   # syscall write` |

```gas
        movq    $5, %rax                # rax = 5              (inmediato -> registro)
        movq    %rax, contador(%rip)    # contador = rax       (registro -> memoria)
        movq    contador(%rip), %rbx    # rbx = contador       (memoria -> registro)
        leaq    contador(%rip), %rbx    # rbx = &contador      (la direccion, no el dato)
```

> **Regla de oro:** en AT&T el destino siempre va al final. Si vienes de leer
> pseudocódigo o de otras notaciones, esta es la única inversión que hay que interiorizar.

Ésta es además la sintaxis que produce `gcc -S` y la que muestra `objdump -d`, así que
todo lo que leas del compilador coincidirá con lo que escribas.

---

## 3. Hola mundo (llamadas al sistema)

Este programa **no usa la biblioteca C**: habla directo con el kernel de Linux. Es el punto
de partida más honesto para aprender.

Archivo `hola.s`:

```gas
        .section .data
mensaje:
        .ascii  "Hola, mundo!\n"
long_msg = . - mensaje          # el ensamblador calcula la longitud

        .section .text
        .globl  _start          # punto de entrada visible para el enlazador

_start:
        # write(1, mensaje, long_msg)
        movq    $1, %rax        # numero de syscall: 1 = write
        movq    $1, %rdi        # arg1: descriptor 1 = stdout
        movq    $mensaje, %rsi  # arg2: direccion del texto
        movq    $long_msg, %rdx # arg3: cuantos bytes escribir
        syscall

        # exit(0)
        movq    $60, %rax       # numero de syscall: 60 = exit
        movq    $0, %rdi        # arg1: codigo de salida
        syscall
```

Compilar y ejecutar (comandos exactos):

```bash
as --64 -g -o hola.o hola.s     # ensamblar: .s  -> .o
ld -o hola hola.o               # enlazar:   .o  -> ejecutable
./hola                          # ejecutar
echo $?                         # ver el codigo de salida (debe ser 0)
```

Salida:

```
Hola, mundo!
```

### Qué hace cada línea

| Línea | Explicación |
|---|---|
| `.section .data` | Inicia la sección de datos inicializados |
| `mensaje:` | Etiqueta = nombre simbólico de una dirección de memoria |
| `.ascii "..."` | Reserva los bytes del texto (sin agregar `\0`) |
| `long_msg = . - mensaje` | `.` es "la posición actual"; la resta da el número de bytes |
| `.section .text` | Inicia la sección de código |
| `.globl _start` | Exporta el símbolo para que `ld` lo encuentre |
| `_start:` | Donde el kernel comienza a ejecutar |
| `syscall` | Transfiere el control al kernel |

> **Importante:** sin la llamada a `exit` el programa se cae con *Segmentation fault*,
> porque después de `syscall` seguiría ejecutando basura. En ensamblador **tú** debes
> terminar el programa explícitamente.

---

## 4. Anatomía de un programa

```gas
        .section .rodata        # datos SOLO LECTURA (cadenas, constantes)
texto:  .asciz "hola"

        .section .data          # datos inicializados y modificables
contador: .quad 0

        .section .bss           # datos sin inicializar (ceros, no ocupan espacio en el binario)
        .lcomm buffer, 64       # reserva 64 bytes llamados "buffer"

        .section .text          # codigo ejecutable
        .globl _start
_start:
        # instrucciones
```

| Sección | Contenido | ¿Modificable? |
|---|---|---|
| `.text` | Instrucciones | No (solo lectura/ejecución) |
| `.data` | Variables con valor inicial | Sí |
| `.rodata` | Constantes, cadenas de formato | No |
| `.bss` | Variables sin valor inicial (buffers) | Sí |

### Directivas para declarar datos

```gas
        .byte   65              # 1 byte
        .word   1000            # 2 bytes
        .long   100000          # 4 bytes  (equivale a .int)
        .quad   1234567890123   # 8 bytes
        .ascii  "sin nulo"      # cadena SIN terminador
        .asciz  "con nulo"      # cadena CON \0 al final (= .string)
        .space  32              # 32 bytes en cero
        .space  16, 0xFF        # 16 bytes con valor 0xFF
        .zero   8               # 8 bytes en cero
        .align  8               # alinea la siguiente etiqueta a 8 bytes
        .equ    MAX, 100        # constante simbolica (tambien: MAX = 100)
```

Ejemplo de un arreglo y una matriz:

```gas
arreglo:  .quad  4, 8, 15, 16, 23, 42        # 6 enteros de 64 bits
matriz:   .long  1, 2, 3,  4, 5, 6           # 2x3 guardada por renglones
tam:      .quad  6
```

---

## 5. Ciclo de trabajo: ensamblar, enlazar, ejecutar

Hay **dos rutas** según si usas o no la biblioteca C.

### Ruta A — sin libc (`_start`, syscalls)

```bash
as --64 -g -o programa.o programa.s
ld -o programa programa.o
./programa
```

- El punto de entrada se llama `_start`.
- No puedes usar `printf`, `scanf`, `malloc`, etc.
- El binario es diminuto y no depende de nada.

### Ruta B — con libc (`main`, `printf`, `scanf`)

```bash
gcc -no-pie -g -o programa programa.s
./programa
```

- El punto de entrada se llama `main` (gcc enlaza el arranque de la libc).
- Puedes llamar cualquier función de C.
- `-no-pie` evita complicaciones de código independiente de posición; es lo recomendable
  mientras aprendes. Si omites `-no-pie`, debes llamar con `call printf@PLT` y acceder a
  datos con direccionamiento relativo a `%rip` (esta guía ya lo hace así, por buena costumbre).

### Opciones útiles

| Comando | Para qué sirve |
|---|---|
| `as -g` | Incluye información de depuración (para `gdb`) |
| `as -al=lista.lst` | Genera un listado con código objeto al lado del fuente |
| `as --32` / `--64` | Fuerza modo de 32 o 64 bits |
| `gcc -c programa.s` | Solo ensambla, produce el `.o` |
| `gcc -S programa.c` | Traduce C a ensamblador (excelente para aprender) |
| `objdump -d programa` | Desensambla el ejecutable |
| `readelf -a programa` | Muestra encabezados, secciones y símbolos ELF |
| `nm programa` | Lista los símbolos |
| `size programa` | Tamaño de `.text`, `.data`, `.bss` |

---

## 6. Registros

x86-64 tiene 16 registros de propósito general de 64 bits. Cada uno se puede usar con
distintos tamaños:

| 64 bits | 32 bits | 16 bits | 8 bits | Uso convencional |
|---|---|---|---|---|
| `%rax` | `%eax` | `%ax`  | `%al`   | Acumulador; valor de retorno |
| `%rbx` | `%ebx` | `%bx`  | `%bl`   | Base (**preservado**) |
| `%rcx` | `%ecx` | `%cx`  | `%cl`   | Contador; 4º argumento |
| `%rdx` | `%edx` | `%dx`  | `%dl`   | Datos; 3er argumento |
| `%rsi` | `%esi` | `%si`  | `%sil`  | Origen; 2º argumento |
| `%rdi` | `%edi` | `%di`  | `%dil`  | Destino; 1er argumento |
| `%rbp` | `%ebp` | `%bp`  | `%bpl`  | Base del marco de pila (**preservado**) |
| `%rsp` | `%esp` | `%sp`  | `%spl`  | Puntero de pila |
| `%r8`–`%r15` | `%r8d`… | `%r8w`… | `%r8b`… | Generales (`%r12`–`%r15` **preservados**) |

Además:

- `%rip` — puntero de instrucción (no se escribe directo; se usa para direccionar datos).
- `%rflags` — registro de banderas (ZF, SF, CF, OF...).

> **Ojo:** al escribir en un registro de 32 bits (`movl $5, %eax`) los 32 bits altos del
> registro de 64 se **ponen en cero** automáticamente. Escribir en `%ax` o `%al` **no**
> borra el resto. Por eso `xorl %eax, %eax` es la forma idiomática de poner `%rax = 0`.

---

## 7. Sufijos de tamaño

| Sufijo | Nombre | Bits | Bytes | Tipo en C |
|---|---|---|---|---|
| `b` | byte | 8 | 1 | `char` |
| `w` | word | 16 | 2 | `short` |
| `l` | long | 32 | 4 | `int` |
| `q` | quad | 64 | 8 | `long`, punteros |

```gas
movb    $65, %al          # 1 byte
movw    $1000, %ax        # 2 bytes
movl    $100000, %eax     # 4 bytes
movq    $10000000000, %rax# 8 bytes
```

El sufijo es **obligatorio** cuando el tamaño no se puede deducir de los operandos:

```gas
movq    $0, (%rsi)        # correcto: escribe 8 bytes de ceros
mov     $0, (%rsi)        # ERROR: "operand size mismatch" / ambiguo
```

### Conversiones con extensión

```gas
movzbl  %al, %eax         # zero-extend: byte -> long (rellena con ceros)
movsbl  %al, %eax         # sign-extend: byte -> long (rellena con el signo)
movslq  %eax, %rax        # sign-extend: long -> quad
cltq                      # %eax -> %rax con signo (equivale a movslq %eax,%rax)
cqto                      # %rax -> %rdx:%rax  (obligatorio antes de idivq)
```

---

## 8. Modos de direccionamiento

Forma general de un operando de memoria:

```
desplazamiento(base, indice, escala)     ->    desplazamiento + base + indice*escala
```

donde `escala` ∈ {1, 2, 4, 8}.

| Modo | Sintaxis | Significado |
|---|---|---|
| Inmediato | `$42` | La constante 42 |
| Registro | `%rax` | El contenido de `%rax` |
| Directo (absoluto) | `var` | El contenido de la variable `var` |
| Relativo a RIP | `var(%rip)` | El contenido de `var` (forma recomendada) |
| Indirecto | `(%rax)` | El contenido de la dirección que guarda `%rax` |
| Con desplazamiento | `8(%rax)` | Contenido de `%rax + 8` |
| Indexado | `(%rax, %rcx)` | Contenido de `%rax + %rcx` |
| Indexado escalado | `(%rax, %rcx, 8)` | Contenido de `%rax + %rcx*8` ← **arreglos** |
| Completo | `-16(%rax, %rcx, 4)` | `%rax + %rcx*4 - 16` |

Ejemplos comentados:

```gas
        leaq    arreglo(%rip), %rbx     # rbx = DIRECCION del arreglo
        movq    (%rbx), %rax            # rax = arreglo[0]
        movq    8(%rbx), %rax           # rax = arreglo[1]  (8 bytes por elemento)
        movq    $3, %rcx
        movq    (%rbx,%rcx,8), %rax     # rax = arreglo[3]
        movq    $99, (%rbx,%rcx,8)      # arreglo[3] = 99
```

### `lea` vs `mov` — la confusión más común

```gas
        leaq    var(%rip), %rax         # rax = la DIRECCION de var        (&var)
        movq    var(%rip), %rax         # rax = el CONTENIDO de var        (var)
```

`lea` (*load effective address*) calcula la dirección pero **no toca la memoria**.
También sirve como calculadora rápida:

```gas
        leaq    (%rax,%rax,4), %rax     # rax = rax*5  ¡sin usar imul!
        leaq    5(%rbx), %rax           # rax = rbx + 5, sin alterar banderas
```

---

## 9. Instrucciones de movimiento de datos

| Instrucción | Efecto |
|---|---|
| `mov  origen, destino` | Copia |
| `movz`/`movs` | Copia con extensión de ceros / de signo |
| `lea  mem, reg` | Carga la dirección efectiva |
| `xchg a, b` | Intercambia |
| `push origen` | Empuja a la pila (`rsp -= 8`) |
| `pop  destino` | Saca de la pila (`rsp += 8`) |
| `cmov<cc> o, d` | Copia solo si se cumple la condición (evita saltos) |

Restricción fundamental: **no existe `mov memoria, memoria`**. Siempre pasa por un registro.

```gas
        movq    a(%rip), %rax           # correcto
        movq    %rax, b(%rip)
        # movq  a(%rip), b(%rip)        # ERROR
```

---

## 10. Operaciones aritméticas

| Instrucción | Sintaxis | Efecto |
|---|---|---|
| `add` | `addq o, d` | `d = d + o` |
| `sub` | `subq o, d` | `d = d - o` |
| `inc` | `incq d` | `d = d + 1` |
| `dec` | `decq d` | `d = d - 1` |
| `neg` | `negq d` | `d = -d` |
| `imul` | `imulq o, d` | `d = d * o` (con signo) |
| `imul` | `imulq $c, o, d` | `d = o * c` |
| `mul` | `mulq o` | `%rdx:%rax = %rax * o` (sin signo) |
| `idiv` | `idivq o` | `%rax = %rdx:%rax / o`, `%rdx =` residuo |
| `div` | `divq o` | Igual, sin signo |
| `adc` / `sbb` | | Suma / resta con acarreo |

### La división: el caso especial

`idivq` **no** toma un dividendo explícito: usa el par `%rdx:%rax` (128 bits). Por eso
**siempre** hay que preparar `%rdx` antes:

```gas
        movq    $17, %rax
        cqto                    # extiende el signo de %rax a %rdx  (IMPRESCINDIBLE)
        movq    $5, %rcx
        idivq   %rcx            # %rax = 3 (cociente), %rdx = 2 (residuo)
```

> Si olvidas `cqto` (o `xorq %rdx,%rdx` para división sin signo) el programa aborta con
> *Floating point exception* (SIGFPE), aunque no haya flotantes de por medio.

---

## 11. Operaciones lógicas y de bits

| Instrucción | Efecto |
|---|---|
| `andq o, d` | `d = d AND o` |
| `orq  o, d` | `d = d OR o` |
| `xorq o, d` | `d = d XOR o` |
| `notq d` | Complemento a uno |
| `testq o, d` | Como `and`, pero **solo** actualiza banderas |
| `shlq $n, d` / `salq` | Desplaza a la izquierda `n` bits (`d * 2^n`) |
| `shrq $n, d` | Desplaza a la derecha **lógico** (rellena con ceros) |
| `sarq $n, d` | Desplaza a la derecha **aritmético** (conserva el signo) |
| `rolq` / `rorq` | Rotación izquierda / derecha |

Trucos idiomáticos:

```gas
        xorq    %rax, %rax      # rax = 0  (mas rapido y corto que movq $0,%rax)
        shlq    $3, %rax        # rax = rax * 8
        sarq    $1, %rax        # rax = rax / 2  (con signo)
        andq    $1, %rax        # rax = bit menos significativo -> paridad
        testq   %rax, %rax      # ¿rax es cero? (sin modificar rax)
        andq    $0xF, %rax      # se queda con los 4 bits bajos (mascara)
```

---

## 12. Banderas, comparaciones y saltos

Las instrucciones aritméticas actualizan el registro de banderas:

| Bandera | Nombre | Se activa cuando |
|---|---|---|
| ZF | Zero | El resultado fue cero |
| SF | Sign | El resultado es negativo |
| CF | Carry | Hubo acarreo/préstamo (sin signo) |
| OF | Overflow | Desbordamiento (con signo) |

`cmpq b, a` calcula `a - b` **sin guardar** el resultado, solo para fijar banderas
(cuidado con el orden AT&T: se lee "compara `a` contra `b`").

### Tabla de saltos condicionales

| Con signo | Sin signo | Salta si | Después de `cmpq b, a` |
|---|---|---|---|
| `je` / `jz` | `je` | Iguales / cero | `a == b` |
| `jne` / `jnz` | `jne` | Distintos | `a != b` |
| `jg` / `jnle` | `ja` | Mayor | `a > b` |
| `jge` / `jnl` | `jae` | Mayor o igual | `a >= b` |
| `jl` / `jnge` | `jb` | Menor | `a < b` |
| `jle` / `jng` | `jbe` | Menor o igual | `a <= b` |
| `js` | — | Negativo | SF = 1 |
| `jo` | — | Desbordamiento | OF = 1 |
| `jmp` | | Siempre (incondicional) | |

> Usa `jg/jl` para números **con signo** y `ja/jb` para **sin signo**. Confundirlos es
> una fuente clásica de bugs.

### Traducción de estructuras de C

**if / else**

```c
if (a > b) x = 1; else x = 2;
```
```gas
        cmpq    %rbx, %rax      # compara a(%rax) con b(%rbx)
        jle     .Lelse
        movq    $1, %rcx
        jmp     .Lfin_if
.Lelse:
        movq    $2, %rcx
.Lfin_if:
```

**while**

```c
while (i < n) { ...; i++; }
```
```gas
        xorq    %rcx, %rcx      # i = 0
.Lwhile:
        cmpq    %rsi, %rcx      # i vs n
        jge     .Lfin_while
        # cuerpo
        incq    %rcx
        jmp     .Lwhile
.Lfin_while:
```

**for con contador descendente (el más eficiente)**

```gas
        movq    $10, %rcx       # 10 iteraciones
.Lfor:
        # cuerpo
        decq    %rcx            # dec ya actualiza ZF
        jnz     .Lfor
```

> Las etiquetas que empiezan con `.L` son **locales**: no aparecen en la tabla de
> símbolos del binario. Es la convención para etiquetas internas.

---

## 13. La pila

La pila crece hacia **direcciones menores**. `%rsp` siempre apunta al tope.

```gas
        pushq   %rax            # rsp -= 8 ; memoria[rsp] = rax
        popq    %rbx            # rbx = memoria[rsp] ; rsp += 8
```

Reservar espacio local (variables locales de una función):

```gas
        subq    $32, %rsp       # reserva 32 bytes
        movq    $7, -8(%rbp)    # variable local 1
        movq    $9, -16(%rbp)   # variable local 2
        addq    $32, %rsp       # libera
```

Marco de pila estándar (prólogo y epílogo):

```gas
funcion:
        pushq   %rbp            # guarda el marco anterior
        movq    %rsp, %rbp      # establece el marco nuevo
        subq    $16, %rsp       # espacio local
        # ... cuerpo ...
        leave                   # equivale a: movq %rbp,%rsp ; popq %rbp
        ret
```

---

## 14. Funciones y convención de llamada (System V ABI)

Es el contrato que hace que tu ensamblador y el código C se entiendan. En Linux x86-64:

### Paso de argumentos (enteros y punteros)

| Argumento | 1º | 2º | 3º | 4º | 5º | 6º | 7º en adelante |
|---|---|---|---|---|---|---|---|
| Registro | `%rdi` | `%rsi` | `%rdx` | `%rcx` | `%r8` | `%r9` | en la pila |

- El **valor de retorno** va en `%rax`.
- Para funciones **variádicas** (como `printf`), `%al` debe contener el número de
  registros vectoriales usados: si no pasas flotantes, pon `xorl %eax, %eax`.

### Registros preservados vs volátiles

| Tipo | Registros | Quién los cuida |
|---|---|---|
| **Volátiles** (caller-saved) | `%rax %rcx %rdx %rsi %rdi %r8`–`%r11` | Si te importan, **guárdalos tú antes de llamar** |
| **Preservados** (callee-saved) | `%rbx %rbp %r12`–`%r15` | Si los usas en tu función, **guárdalos y restáuralos** |

### Alineación de la pila (regla que rompe programas)

En el momento de ejecutar `call`, `%rsp` debe ser **múltiplo de 16**.

Al entrar a tu función, `call` ya empujó la dirección de retorno, así que `%rsp ≡ 8 (mod 16)`.
Por eso el prólogo típico funciona:

```gas
funcion:
        pushq   %rbp            # rsp vuelve a ser multiplo de 16  ✔
        movq    %rsp, %rbp
        pushq   %rbx            # ¡ahora rsp ≡ 8, DESALINEADO!
        subq    $8, %rsp        # lo corriges: rsp multiplo de 16  ✔
        # ... aqui ya puedes hacer call printf ...
        addq    $8, %rsp
        popq    %rbx
        popq    %rbp
        ret
```

> Síntoma de pila desalineada: tu programa funciona hasta que llamas a `printf` con un
> `%f`, y ahí revienta con SIGSEGV dentro de la libc. Cuenta tus `push`.

---

## 15. Programa 2: Hola mundo con printf (libc)

Archivo `hola_libc.s`:

```gas
        .section .rodata
fmt:    .asciz  "Hola, %s! Tienes %d anios.\n"
nombre: .asciz  "mundo"

        .section .text
        .globl  main
main:
        pushq   %rbp
        movq    %rsp, %rbp

        leaq    fmt(%rip), %rdi     # arg1: cadena de formato
        leaq    nombre(%rip), %rsi  # arg2: %s
        movl    $20, %edx           # arg3: %d
        xorl    %eax, %eax          # 0 registros vectoriales (obligatorio en printf)
        call    printf@PLT

        movl    $0, %eax            # return 0
        popq    %rbp
        ret
```

```bash
gcc -no-pie -o hola_libc hola_libc.s
./hola_libc
```

Salida:

```
Hola, mundo! Tienes 20 anios.
```

**Especificadores de `printf` más usados:** `%d` (int), `%ld` (long), `%s` (cadena),
`%c` (carácter), `%x` (hexadecimal), `%p` (puntero), `%f` (double), `%%` (signo de %).

---

## 16. Programa 3: operaciones aritméticas completas

Archivo `operaciones.s` — suma, resta, producto, cociente y residuo, cada uno impreso
por una subrutina propia.

```gas
        .section .rodata
fmt:    .asciz  "%s = %ld\n"
s_sum:  .asciz  "suma"
s_res:  .asciz  "resta"
s_mul:  .asciz  "producto"
s_div:  .asciz  "cociente"
s_mod:  .asciz  "residuo"

        .section .data
a:      .quad   17
b:      .quad   5

        .section .text
        .globl  main
main:
        pushq   %rbp
        movq    %rsp, %rbp
        subq    $16, %rsp               # espacio local (y mantiene la alineacion)

        # --- SUMA ---
        movq    a(%rip), %rax
        addq    b(%rip), %rax
        leaq    s_sum(%rip), %rdi
        call    imprime

        # --- RESTA ---
        movq    a(%rip), %rax
        subq    b(%rip), %rax
        leaq    s_res(%rip), %rdi
        call    imprime

        # --- MULTIPLICACION ---
        movq    a(%rip), %rax
        imulq   b(%rip), %rax
        leaq    s_mul(%rip), %rdi
        call    imprime

        # --- DIVISION ENTERA ---
        movq    a(%rip), %rax
        cqto                            # extiende el signo a %rdx (obligatorio)
        idivq   b(%rip)                 # %rax = cociente, %rdx = residuo
        movq    %rdx, -8(%rbp)          # guarda el residuo antes de que printf lo pise
        leaq    s_div(%rip), %rdi
        call    imprime

        # --- RESIDUO ---
        movq    -8(%rbp), %rax
        leaq    s_mod(%rip), %rdi
        call    imprime

        xorl    %eax, %eax
        leave
        ret

# ---------------------------------------------------------------
# imprime:  %rdi = etiqueta (cadena),  %rax = valor a mostrar
# ---------------------------------------------------------------
imprime:
        pushq   %rbp
        movq    %rsp, %rbp
        movq    %rdi, %rsi              # etiqueta pasa a ser el 2do argumento
        movq    %rax, %rdx              # valor pasa a ser el 3er argumento
        leaq    fmt(%rip), %rdi         # formato es el 1er argumento
        xorl    %eax, %eax
        call    printf@PLT
        popq    %rbp
        ret
```

```bash
gcc -no-pie -g -o operaciones operaciones.s
./operaciones
```

Salida:

```
suma = 22
resta = 12
producto = 85
cociente = 3
residuo = 2
```

> Nota didáctica: el residuo se guarda en la pila (`-8(%rbp)`) porque `%rdx` es un
> registro **volátil** y `printf` lo destruye.

---

## 17. Programa 4: bucles, condicionales, arreglos y recursión

Archivo `control.s`.

```gas
        .section .rodata
f_sum:  .asciz  "suma del arreglo = %ld\n"
f_par:  .asciz  "%ld es %s\n"
f_fac:  .asciz  "%ld! = %ld\n"
s_par:  .asciz  "par"
s_imp:  .asciz  "impar"

        .section .data
arr:    .quad   4, 8, 15, 16, 23, 42
n:      .quad   6

        .section .text
        .globl  main
main:
        pushq   %rbp
        movq    %rsp, %rbp
        pushq   %rbx                    # rbx es preservado: hay que guardarlo
        subq    $8, %rsp                # realinea la pila a 16 bytes

        # ============ BUCLE: sumar el arreglo ============
        xorq    %rax, %rax              # acumulador = 0
        xorq    %rcx, %rcx              # i = 0
        leaq    arr(%rip), %rbx         # rbx = &arr[0]
.Lwhile:
        cmpq    n(%rip), %rcx
        jge     .Lfin_while
        addq    (%rbx,%rcx,8), %rax     # acumulador += arr[i]
        incq    %rcx
        jmp     .Lwhile
.Lfin_while:
        movq    %rax, %rsi
        leaq    f_sum(%rip), %rdi
        xorl    %eax, %eax
        call    printf@PLT

        # ============ IF / ELSE: paridad ============
        movq    $7, %rbx
        testq   $1, %rbx                # revisa el bit 0
        jz      .Les_par
        leaq    s_imp(%rip), %rdx
        jmp     .Lmuestra
.Les_par:
        leaq    s_par(%rip), %rdx
.Lmuestra:
        movq    %rbx, %rsi
        leaq    f_par(%rip), %rdi
        xorl    %eax, %eax
        call    printf@PLT

        # ============ LLAMADA A FUNCION RECURSIVA ============
        movq    $5, %rdi
        call    factorial
        movq    %rax, %rdx              # resultado
        movq    $5, %rsi
        leaq    f_fac(%rip), %rdi
        xorl    %eax, %eax
        call    printf@PLT

        xorl    %eax, %eax
        addq    $8, %rsp
        popq    %rbx
        popq    %rbp
        ret

# ---------------------------------------------------------------
# long factorial(long n)    ->  %rdi = n, resultado en %rax
# ---------------------------------------------------------------
factorial:
        pushq   %rbp
        movq    %rsp, %rbp
        pushq   %rbx
        subq    $8, %rsp

        cmpq    $1, %rdi
        jle     .Lbase                  # caso base: n <= 1 -> 1
        movq    %rdi, %rbx              # guarda n en un registro preservado
        decq    %rdi                    # n - 1
        call    factorial               # recursion
        imulq   %rbx, %rax              # n * factorial(n-1)
        jmp     .Lsalir
.Lbase:
        movq    $1, %rax
.Lsalir:
        addq    $8, %rsp
        popq    %rbx
        popq    %rbp
        ret
```

```bash
gcc -no-pie -g -o control control.s
./control
```

Salida:

```
suma del arreglo = 108
7 es impar
5! = 120
```

---

## 18. Programa 5: entrada de datos

### Con la libc (`scanf`)

Archivo `entrada.s`:

```gas
        .section .rodata
p1:     .asciz  "Dame un numero: "
fmt_in: .asciz  "%ld"
fmt_out:.asciz  "El doble de %ld es %ld\n"

        .section .bss
        .lcomm  num, 8                  # variable de 8 bytes sin inicializar

        .section .text
        .globl  main
main:
        pushq   %rbp
        movq    %rsp, %rbp

        leaq    p1(%rip), %rdi
        xorl    %eax, %eax
        call    printf@PLT

        leaq    fmt_in(%rip), %rdi
        leaq    num(%rip), %rsi         # scanf necesita la DIRECCION (&num)
        xorl    %eax, %eax
        call    scanf@PLT

        movq    num(%rip), %rsi
        movq    %rsi, %rdx
        addq    %rdx, %rdx              # doble = num + num
        leaq    fmt_out(%rip), %rdi
        xorl    %eax, %eax
        call    printf@PLT

        xorl    %eax, %eax
        popq    %rbp
        ret
```

```bash
gcc -no-pie -o entrada entrada.s
./entrada
```

```
Dame un numero: 21
El doble de 21 es 42
```

### Sin libc (syscall `read`)

Archivo `lee.s`:

```gas
        .section .rodata
prompt: .ascii  "Tu nombre: "
lp = . - prompt
saludo: .ascii  "Hola, "
ls = . - saludo

        .section .bss
        .lcomm  buffer, 64

        .section .text
        .globl  _start
_start:
        # write(1, prompt, lp)
        movq    $1, %rax
        movq    $1, %rdi
        leaq    prompt(%rip), %rsi
        movq    $lp, %rdx
        syscall

        # read(0, buffer, 64)
        movq    $0, %rax                # syscall 0 = read
        movq    $0, %rdi                # descriptor 0 = stdin
        leaq    buffer(%rip), %rsi
        movq    $64, %rdx
        syscall
        movq    %rax, %r12              # read devuelve los bytes leidos

        # write(1, saludo, ls)
        movq    $1, %rax
        movq    $1, %rdi
        leaq    saludo(%rip), %rsi
        movq    $ls, %rdx
        syscall

        # write(1, buffer, bytes_leidos)
        movq    $1, %rax
        movq    $1, %rdi
        leaq    buffer(%rip), %rsi
        movq    %r12, %rdx
        syscall

        # exit(0)
        movq    $60, %rax
        xorq    %rdi, %rdi
        syscall
```

```bash
as -g -o lee.o lee.s
ld -o lee lee.o
./lee
```

```
Tu nombre: Bill
Hola, Bill
```

---

## 19. Tabla de llamadas al sistema

Convención de `syscall` en Linux x86-64:

| Rol | Registro |
|---|---|
| Número de syscall | `%rax` |
| Argumentos 1–6 | `%rdi`, `%rsi`, `%rdx`, `%r10`, `%r8`, `%r9` |
| Valor de retorno | `%rax` (negativo = error) |
| Destruidos | `%rcx` y `%r11` |

> Nota: el 4º argumento es `%r10`, **no** `%rcx` (ahí difiere de las funciones de C).

| Nº | Nombre | Firma en C |
|---|---|---|
| 0 | `read` | `read(fd, buf, count)` |
| 1 | `write` | `write(fd, buf, count)` |
| 2 | `open` | `open(ruta, flags, modo)` |
| 3 | `close` | `close(fd)` |
| 8 | `lseek` | `lseek(fd, offset, whence)` |
| 9 | `mmap` | reservar memoria |
| 12 | `brk` | ajustar el heap |
| 35 | `nanosleep` | dormir |
| 39 | `getpid` | id del proceso |
| 57 | `fork` | crear proceso |
| 59 | `execve` | ejecutar programa |
| 60 | `exit` | `exit(codigo)` |
| 62 | `kill` | enviar señal |
| 257 | `openat` | abrir relativo a un directorio |

La lista completa está en tu sistema:

```bash
grep '' /usr/include/asm/unistd_64.h | head -70
# o bien
ausyscall --dump 2>/dev/null | head -70
```

Descriptores estándar: `0` = stdin, `1` = stdout, `2` = stderr.

---

## 20. Directivas de GAS (referencia)

| Directiva | Uso |
|---|---|
| `.section nombre` | Cambia de sección |
| `.text` / `.data` / `.bss` | Atajos de las secciones habituales |
| `.globl sim` | Hace el símbolo visible al enlazador |
| `.extern sim` | Declara un símbolo externo (opcional en GAS) |
| `.type sim, @function` | Marca el símbolo como función (útil en `gdb`) |
| `.size sim, . - sim` | Registra el tamaño del símbolo |
| `.byte/.word/.long/.quad` | Reserva datos de 1/2/4/8 bytes |
| `.ascii` / `.asciz` / `.string` | Cadenas sin / con terminador nulo |
| `.space n[, val]` / `.zero n` | Reserva `n` bytes |
| `.comm sim, tam` | Símbolo común global (en `.bss`) |
| `.lcomm sim, tam` | Símbolo común local (en `.bss`) |
| `.align n` / `.balign n` | Alinea a `n` bytes |
| `.equ NOM, val` o `NOM = val` | Constante simbólica |
| `.include "archivo.s"` | Incluye otro fuente |
| `.macro` / `.endm` | Define una macro |
| `.rept n` / `.endr` | Repite un bloque `n` veces |
| `.if` / `.else` / `.endif` | Ensamblado condicional |

Ejemplo de macro:

```gas
        .macro  SALIR codigo=0
        movq    $60, %rax
        movq    $\codigo, %rdi
        syscall
        .endm

        # uso:
        SALIR 0
```

Comentarios: `#` hasta fin de línea, o `/* ... */` en bloque.

---

## 21. Depuración con GDB

Ensambla **siempre** con `-g` mientras aprendes.

```bash
as -g -o programa.o programa.s && ld -o programa programa.o
gdb ./programa
```

Comandos esenciales dentro de `gdb`:

```gdb
(gdb) layout asm            # ventana con el codigo desensamblado
(gdb) layout regs           # agrega la ventana de registros
(gdb) break _start          # punto de ruptura (o: break main)
(gdb) run                   # ejecuta
(gdb) stepi                 # ejecuta UNA instruccion (abrev: si)
(gdb) nexti                 # igual, pero sin entrar a las funciones (ni)
(gdb) continue              # continua hasta el siguiente breakpoint (c)
(gdb) info registers        # todos los registros (i r)
(gdb) info registers rax rdi# solo algunos
(gdb) p $rax                # imprime un registro en decimal
(gdb) p/x $rax              # en hexadecimal
(gdb) x/8xb &buffer         # 8 bytes en hex a partir de buffer
(gdb) x/s $rsi              # la cadena apuntada por rsi
(gdb) x/4dg $rsp            # 4 "giant words" (8 bytes) de la pila en decimal
(gdb) x/6i $rip             # las 6 siguientes instrucciones
(gdb) disassemble main      # desensambla una funcion
(gdb) info frame            # informacion del marco de pila
(gdb) set $rax = 5          # modifica un registro en caliente
(gdb) quit                  # salir (q)
```

Formatos de `x`: `x/NFU dir` → `N` = cantidad, `F` = formato (`x` hex, `d` decimal,
`s` cadena, `i` instrucción, `c` carácter), `U` = unidad (`b`=1, `h`=2, `w`=4, `g`=8 bytes).

Sesión típica:

```bash
gdb ./operaciones
(gdb) break main
(gdb) run
(gdb) layout regs
(gdb) si          # avanza instruccion por instruccion viendo cambiar los registros
```

---

## 22. Ver el ensamblador que genera el compilador

La mejor manera de aprender idioms correctos: escribe el algoritmo en C y mira su traducción.

```bash
gcc -S -O0 -fno-asynchronous-unwind-tables -masm=att ejemplo.c -o ejemplo.s
cat ejemplo.s
```

- `-O0` — sin optimizar, se parece línea por línea al C.
- `-O2` — optimizado, para ver los trucos del compilador.
- `-fno-asynchronous-unwind-tables` — elimina las directivas `.cfi_*` que estorban al leer.

También:

```bash
objdump -d --no-show-raw-insn ./programa | less
gcc -c programa.s && objdump -dr programa.o     # con reubicaciones
```

---

## 23. Makefile

Guarda esto como `Makefile` en la carpeta de tus prácticas:

```make
# make hola          -> ensambla y enlaza sin libc (usa _start)
# make LIBC=1 hola   -> enlaza con la biblioteca C (usa main)
# make run-hola      -> compila y ejecuta
# make clean

AS      = as
ASFLAGS = --64 -g
LD      = ld
CC      = gcc
CFLAGS  = -no-pie -g

FUENTES = $(wildcard *.s)
PROGS   = $(FUENTES:.s=)

all: $(PROGS)

ifdef LIBC
%: %.s
	$(CC) $(CFLAGS) -o $@ $<
else
%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

%: %.o
	$(LD) -o $@ $<
endif

run-%: %
	./$<

lista-%: %.s
	$(AS) $(ASFLAGS) -al=$*.lst -o /dev/null $<
	@cat $*.lst

clean:
	rm -f *.o *.lst $(PROGS)

.PHONY: all clean
.PRECIOUS: %.o
```

Uso:

```bash
make hola            # programa con syscalls
make LIBC=1 control  # programa que usa printf
make run-hola
make clean
```

---

## 24. Modo 32 bits

Si tu curso trabaja con IA-32 (registros `%eax`, interrupción `int $0x80`):

```gas
        .section .data
mensaje: .ascii "Hola en 32 bits!\n"
long = . - mensaje

        .section .text
        .globl  _start
_start:
        movl    $4, %eax        # sys_write (numeracion de 32 bits)
        movl    $1, %ebx
        movl    $mensaje, %ecx
        movl    $long, %edx
        int     $0x80

        movl    $1, %eax        # sys_exit
        movl    $0, %ebx
        int     $0x80
```

```bash
as --32 -o prog32.o prog32.s
ld -m elf_i386 -o prog32 prog32.o
./prog32
```

Diferencias contra 64 bits:

| | 32 bits | 64 bits |
|---|---|---|
| Registros | `%eax`, `%ebx`, `%ecx`, `%edx`… | `%rax`, `%rbx`… + `%r8`–`%r15` |
| Llamada al kernel | `int $0x80` | `syscall` |
| Nº de syscall | `%eax` (write=4, exit=1) | `%rax` (write=1, exit=60) |
| Argumentos | `%ebx %ecx %edx %esi %edi %ebp` | `%rdi %rsi %rdx %r10 %r8 %r9` |
| Argumentos en C | todos en la pila | primeros 6 en registros |

Para enlazar con libc en 32 bits necesitas las bibliotecas multilib
(`sudo dnf install glibc-devel.i686`) y compilar con `gcc -m32`.

---

## 25. Errores comunes

| Mensaje / síntoma | Causa | Solución |
|---|---|---|
| `Segmentation fault` al terminar | Falta `exit` al final de `_start` | Agrega la syscall 60 |
| `undefined reference to '_start'` | Enlazaste con `ld` un programa cuya etiqueta es `main` | Usa `gcc` o renombra a `_start` |
| `undefined reference to 'main'` | Enlazaste con `gcc` un programa con `_start` | Usa `ld`, o renombra a `main` |
| `operand type mismatch` | Mezclas tamaños (`movq %eax, %rbx`) | Usa registros del mismo tamaño |
| `too many memory references` | Dos operandos en memoria | Pasa por un registro |
| `Floating point exception` en una división | Olvidaste `cqto` / `xorq %rdx,%rdx` | Prepara `%rdx` antes de `idivq` |
| SIGSEGV dentro de `printf` | Pila desalineada a 16 bytes | Cuenta tus `push`; agrega `subq $8,%rsp` |
| Se imprime basura después del texto | Usaste `.ascii` donde `printf` espera `\0` | Usa `.asciz` |
| El valor "se pierde" tras un `call` | Usaste un registro volátil | Guárdalo en la pila o en `%rbx`/`%r12`–`%r15` |
| `relocation R_X86_64_32S ... recompile with -fPIE` | Enlace PIE con direcciones absolutas | Compila con `-no-pie` o usa `var(%rip)` |
| El programa "no hace nada" | Escribiste a stdout sin `\n` y sin `exit` | Revisa longitud y descriptor |

Truco: para ver hasta dónde llegó tu programa:

```bash
strace ./programa        # muestra cada syscall ejecutada
```

---

## 26. Referencias

- Manual oficial de GAS: `info as` — o https://sourceware.org/binutils/docs/as/
- Página del manual: `man as`, `man ld`, `man gdb`, `man 2 syscall`
- System V AMD64 ABI (convención de llamada): https://gitlab.com/x86-psABIs/x86-64-ABI
- Manual del juego de instrucciones x86-64 (volumen 2): https://www.intel.com/sdm
- Tabla de syscalls de Linux: https://filippo.io/linux-syscall-table/
- *Programming from the Ground Up*, Jonathan Bartlett (libro libre, usa GAS)
- *Computer Systems: A Programmer's Perspective*, Bryant & O'Hallaron (capítulo 3)
- Consulta rápida de instrucciones: https://www.felixcloutier.com/x86/
