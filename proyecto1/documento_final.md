# Proyecto 1: Miniensamblador GAS x86

Documento final

## 1. Descripción general

El programa es un miniensamblador que recibe una instrucción escrita por el usuario en la sintaxis del ensamblador GNU (GAS, sintaxis AT&T), la analiza, la valida y la traduce al código máquina de la arquitectura x86-64, es decir, a los mismos bytes que genera GAS. Por ejemplo, si el usuario escribe `movb $5, %al`, el programa muestra `B0 05`.

El programa está escrito en GAS para Linux x86-64 y trabaja en tres etapas, una por cada parte del proyecto:

| Etapa | Qué hace | Rutina principal |
|---|---|---|
| 1. Análisis léxico | Separa la instrucción en mnemónico, operando fuente, coma y operando destino. | `_analiza` |
| 2. Validación sintáctica | Revisa que el mnemónico exista, que lleve el número correcto de operandos y que el registro y el inmediato sean válidos. | `_valida` |
| 3. Traducción a código máquina | Calcula los bytes de la instrucción y los muestra en hexadecimal. | `_genera` y `_writeCodigo` |

Para ensamblar y ejecutar:

```
make          # ensambla y enlaza
make run      # abre el programa
make demo     # traduce todas las instrucciones de ejemplos.txt
```

## 2. Tabla de instrucciones y operandos permitidos

### 2.1 Instrucciones

El código no se guarda por cada combinación de instrucción y registro. Se calcula con dos reglas:

- **último byte del código = base de la instrucción + identificador del registro**
- **si el registro es de 16 bits, se antepone el prefijo `66`**

| Mnemónico | Formas aceptadas | Operandos | Con registro de 8 bits | Con registro de 16 bits |
|---|---|---|---|---|
| `mov` | `mov`, `movb`, `movw` | `$inmediato, %registro` | B0 + id, inmediato | 66, B8 + id, inmediato |
| `inc` | `inc`, `incw` | `%registro` de 16 bits | no admitido | 66, FF, C0 + id |
| `dec` | `dec`, `decw` | `%registro` de 16 bits | no admitido | 66, FF, C8 + id |
| `push` | `push`, `pushw` | `%registro` de 16 bits | no admitido | 66, 50 + id |
| `pop` | `pop`, `popw` | `%registro` de 16 bits | no admitido | 66, 58 + id |

El sufijo del mnemónico es opcional. Si se escribe, debe corresponder al tamaño del registro: `b` para 8 bits y `w` para 16 bits.

### 2.2 Registros

| Identificador | Registro de 8 bits | Registro de 16 bits |
|---|---|---|
| 0 | `%al` | `%ax` |
| 1 | `%cl` | `%cx` |
| 2 | `%dl` | `%dx` |
| 3 | `%bl` | `%bx` |
| 4 | `%ah` | `%sp` |
| 5 | `%ch` | `%bp` |
| 6 | `%dh` | `%si` |
| 7 | `%bh` | `%di` |

### 2.3 Valores inmediatos

| Registro destino | Rango permitido | Bytes que ocupa |
|---|---|---|
| 8 bits | 0 a 255 | 1 |
| 16 bits | 0 a 65535 | 2, primero el byte bajo y después el byte alto |

El inmediato se escribe con el prefijo `$` y se interpreta igual que en GAS:

| Forma | Base | Ejemplo | Valor |
|---|---|---|---|
| Empieza con un dígito del 1 al 9 | decimal | `$258` | 258 |
| Empieza con `0x` | hexadecimal | `$0x0f` | 15 |
| Empieza con `0` | octal | `$010` | 8 |

### 2.4 Reglas de escritura

- El orden de los operandos es el de GAS: primero la fuente y después el destino.
- Los registros llevan el prefijo `%` y los inmediatos el prefijo `$`.
- Los dos operandos de `mov` se separan con una coma.
- Se permiten espacios y tabuladores entre los elementos.
- Se aceptan mayúsculas y minúsculas. El programa convierte la instrucción a mayúsculas para compararla con sus tablas, por eso la muestra así en pantalla.

### 2.5 Ejemplo del cálculo

Para `movw $258, %ax`:

1. `%ax` es un registro de 16 bits, así que el código empieza con el prefijo `66`.
2. `mov` con un registro de 16 bits tiene base B8.
3. `%ax` tiene identificador 0, así que el código de operación es B8 + 0 = `B8`.
4. 258 en hexadecimal es 0102. El byte bajo es `02` y el byte alto es `01`.
5. Resultado: `66 B8 02 01`.

### 2.6 Notas sobre la codificación

- El prefijo `66` indica que el operando es de 16 bits; sin él, el procesador en modo de 64 bits interpreta `B8` como un `mov` a `%eax` y `53` como `push %rbx`.
- En x86-64 los bytes `40` a `4F` son prefijos REX, por eso `inc` y `dec` se codifican como `FF C0 + id` y `FF C8 + id`.

## 3. Descripción de los procedimientos

### 3.1 Entrada y salida

| Procedimiento | Descripción |
|---|---|
| `_writePrompt`, `_writeMenu`, `_writeMsg...`, `_writeError...` | Cada uno escribe en pantalla un mensaje fijo con la llamada al sistema `write`. |
| `_writeSalto`, `_writeEspacio` | Escriben un salto de línea y un espacio. |
| `_writeToken` | Escribe una cadena terminada en cero (mnemónico u operando) seguida de un salto de línea. |
| `_writeBuffer` | Escribe la instrucción tal como quedó capturada. |
| `_scanDigit` | Lee la opción del menú, descarta el resto de la línea y regresa el dígito como número. |
| `_scanInstruccion` | Lee la instrucción carácter por carácter hasta el salto de línea, la guarda en `buffer` (máximo 63 caracteres) y convierte las minúsculas a mayúsculas. Regresa la longitud. |
| `_longitud` | Cuenta los caracteres de una cadena terminada en cero. |

### 3.2 Primera parte: análisis léxico

| Procedimiento | Descripción |
|---|---|
| `_limpiaTokens` | Pone en cero `mnemonico`, `operando1`, `operando2` y la bandera `hayComa` antes de cada análisis. |
| `_saltaEspacios` | Avanza la posición de lectura mientras haya espacios o tabuladores. |
| `_copiaToken` | Copia caracteres del `buffer` al destino hasta encontrar un espacio, un tabulador, una coma o el final. Regresa cuántos caracteres copió. |
| `_analiza` | Separa la instrucción en mnemónico, primer operando, coma y segundo operando. Regresa 0 si la forma es correcta o un código de error: falta el mnemónico, falta un operando junto a la coma, falta la coma o sobra texto al final. |
| `_imprimeAnalisis` | Muestra los elementos encontrados. Con dos operandos, presenta el primero como "Valor inmediato" si empieza con `$` o como "Fuente" en otro caso, y el segundo como "Destino". Con un solo operando lo presenta como "Operando". |

### 3.3 Segunda parte: validación sintáctica

| Procedimiento | Descripción |
|---|---|
| `_buscaMnemonico` | Recorre `tabla` comparando el mnemónico escrito con el de cada entrada. Si no lo encuentra y termina en `B` o `W`, guarda esa letra en `sufijo`, la quita y busca de nuevo (`MOVB` se busca como `MOV`). Deja en `r13` la dirección de la entrada encontrada o regresa -1 si no existe. |
| `_validaInmediato` | Convierte a número el texto que sigue al `$` del primer operando, en decimal, hexadecimal (`0x`) u octal (cero inicial). Regresa el valor, o -1 si contiene dígitos no válidos para su base. |
| `_valida` | Aplica las reglas en orden: que el mnemónico exista, que tenga operando, que el número de operandos corresponda al tipo de instrucción, que el registro empiece con `%` y exista, que su tamaño sea admitido por la instrucción y coincida con el sufijo, que el primer operando sea un inmediato con `$`, y que el inmediato sea válido y quepa en el registro. Si todo es correcto, llama a la generación de código; si no, muestra el error correspondiente. |
| `_digitoHex`, `_writeHex` | Convierten un byte en sus dos dígitos hexadecimales y los escriben. |

### 3.4 Tercera parte: traducción a código máquina

| Procedimiento | Descripción |
|---|---|
| `_buscaRegistro` | Recibe el operando que contiene el registro y recorre `registros` comparando el nombre escrito después del `%`. Deja en `r14` la dirección de la entrada, que contiene el identificador y el tamaño del registro, o regresa -1 si no existe. |
| `_genera` | Arma los bytes en `codigo`. Si el registro es de 16 bits, coloca primero el prefijo `66` y, si la instrucción lo tiene, su byte previo (`FF` en `inc` y `dec`). Después toma la base de 8 o de 16 bits y le suma el identificador. Si la instrucción lleva inmediato, agrega el byte bajo y, para registros de 16 bits, el byte alto. Regresa la cantidad de bytes generados. |
| `_writeCodigo` | Escribe los bytes generados en hexadecimal, con dos dígitos por byte y un espacio entre ellos. |
| `_writeErrorRequiere16` | Arma el mensaje `Error. <mnemónico> requiere un registro de 16 bits.` usando el mnemónico que escribió el usuario, sin el sufijo. |
| `_writeErrorExcede8`, `_writeErrorExcede16` | Muestran el error cuando el inmediato no cabe en el registro. |
| `_writeErrorSinPorcentaje`, `_writeErrorSinPesos`, `_writeErrorSufijo` | Muestran el error cuando falta el `%` del registro, cuando falta el `$` del inmediato o cuando el sufijo no corresponde al tamaño del registro. |

### 3.5 Programa principal

`_start` muestra el título y entra al ciclo `_menu`. Con la opción 1 captura la instrucción, la analiza, muestra el análisis y llama a `_valida`. Con la opción 2 termina el programa mediante `_exit`.

## 4. Casos de prueba

### 4.1 Instrucciones válidas

| Entrada | Salida esperada | Qué comprueba |
|---|---|---|
| `movb $5, %al` | `B0 05` | `mov` con registro de 8 bits |
| `movb $5, %cl` | `B1 05` | La regla base + identificador con otro registro |
| `movb $255, %bh` | `B7 FF` | Valor máximo de 8 bits |
| `movw $258, %ax` | `66 B8 02 01` | Prefijo `66` e inmediato de dos bytes, byte bajo primero |
| `movw $5, %cx` | `66 B9 05 00` | Valor pequeño en registro de 16 bits |
| `movw $65535, %dx` | `66 BA FF FF` | Valor máximo de 16 bits |
| `mov $5, %al` | `B0 05` | Mnemónico sin sufijo |
| `MOVB $5, %AL` | `B0 05` | Mayúsculas |
| `movb $0x0f, %al` | `B0 0F` | Inmediato hexadecimal |
| `movb $010, %al` | `B0 08` | Inmediato octal |
| `pushw %bx` | `66 53` | `push` con registro de 16 bits |
| `popw %bx` | `66 5B` | `pop` con registro de 16 bits |
| `push %si` | `66 56` | Registro índice, sin sufijo |
| `incw %ax` | `66 FF C0` | `inc` |
| `decw %bx` | `66 FF CB` | `dec` |

### 4.2 Instrucciones inválidas

| Entrada | Salida esperada | Etapa que lo detecta |
|---|---|---|
| `movb $300, %al` | `Error. El valor excede el rango de 8 bits.` | Traducción |
| `movw $65536, %ax` | `Error. El valor excede el rango de 16 bits.` | Traducción |
| `pushw %al` | `Error. PUSH requiere un registro de 16 bits.` | Traducción |
| `pop %cl` | `Error. POP requiere un registro de 16 bits.` | Traducción |
| `movw $5, %al` | `ERROR: el sufijo del mnemonico no corresponde al tamano del registro.` | Validación |
| `movb $5, al` | `ERROR: el registro debe empezar con %.` | Validación |
| `movb 5, %al` | `ERROR: el primer operando debe ser un valor inmediato con $.` | Validación |
| `movb $09, %al` | `ERROR: valor inmediato no valido.` | Validación |
| `movb $5, %zz` | `ERROR: registro no valido para esta instruccion.` | Validación |
| `addb $5, %al` | `ERROR: instruccion no reconocida.` | Validación |
| `push` | `ERROR: falta el operando.` | Validación |
| `movb $5` | `ERROR: falta el segundo operando.` | Validación |
| `pushw %ax, %bx` | `ERROR: la instruccion solo lleva un operando.` | Validación |
| `movb $5 %al` | `Error: falta la coma entre los operandos` | Análisis léxico |
| `movb $5,` | `Error: falta un operando junto a la coma` | Análisis léxico |
| `movb $5, %al %bl` | `Error: hay texto de mas al final de la instruccion` | Análisis léxico |

## 5. Ejecución paso a paso

<!-- PENDIENTE: guardar las capturas en la carpeta capturas/ con los nombres indicados -->

### Paso 1. Ensamblado y enlace

Se ejecuta `make`, que ensambla `proyecto1.s` con `as` y lo enlaza con `ld`.

![Ensamblado con make](capturas/01-make.png)

### Paso 2. Menú principal

Al ejecutar `./proyecto1` aparece el título y el menú. La opción 1 analiza una instrucción y la opción 2 termina el programa.

![Menú principal](capturas/02-menu.png)

### Paso 3. Instrucción válida

Se elige la opción 1 y se escribe `movw $258, %ax`. El programa muestra la instrucción capturada, el resultado del análisis léxico, el resultado de la validación y los bytes generados:

```
Instruccion capturada: MOVW $258, %AX
Analisis:
Mnemonico: MOVW
Valor inmediato: $258
Coma: ,
Destino: %AX
Validacion:
Instruccion valida
Codigo maquina: 66 B8 02 01
```

![movw $258, %ax](capturas/03-mov-ax.png)

### Paso 4. Instrucción de un operando

Se escribe `pushw %bx`. El análisis solo encuentra mnemónico y un operando, y el resultado son dos bytes: `66 53`.

![pushw %bx](capturas/04-push-bx.png)

### Paso 5. Valor fuera de rango

Se escribe `movb $300, %al`. La instrucción tiene la forma correcta, pero 300 no cabe en un registro de 8 bits, así que no se genera código y se muestra el error.

![movb $300, %al](capturas/05-error-rango.png)

### Paso 6. Registro de tamaño incorrecto

Se escribe `pushw %al`. `push` solo admite registros de 16 bits y `%al` es de 8, por lo que se muestra el error.

![pushw %al](capturas/06-error-registro.png)

### Paso 7. Demostración completa

Con `make demo` se traducen de una vez todas las instrucciones de `ejemplos.txt`.

![make demo](capturas/07-demo.png)

## 6. Conclusiones individuales

### Billy Rivera Salinas

Al desarrollar este proyecto en ensamblador logré entender mejor, y de forma más profunda, cómo funcionan la programación y el hardware.
