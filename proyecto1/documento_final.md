# Proyecto 1: Miniensamblador GAS x86

Documento final

## 1. Descripción general

El programa es un miniensamblador que recibe una instrucción escrita por el usuario, la analiza, la valida y la traduce al código máquina del procesador 8086. Por ejemplo, si el usuario escribe `MOV AL, 05`, el programa muestra `B0 05`.

El programa está escrito en ensamblador GNU (GAS) para Linux x86-64 y trabaja en tres etapas, una por cada parte del proyecto:

| Etapa | Qué hace | Rutina principal |
|---|---|---|
| 1. Análisis léxico | Separa la instrucción en mnemónico, operando destino, coma y operando fuente. | `_analiza` |
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

El código de operación no se guarda por cada combinación de instrucción y registro. Se calcula con una regla:

**código de operación = base de la instrucción + identificador del registro**

| Mnemónico | Operandos | Base con registro de 8 bits | Base con registro de 16 bits | Bytes generados |
|---|---|---|---|---|
| `MOV` | registro, inmediato | B0 | B8 | 2 (8 bits) o 3 (16 bits) |
| `INC` | registro de 16 bits | no admitido | 40 | 1 |
| `DEC` | registro de 16 bits | no admitido | 48 | 1 |
| `PUSH` | registro de 16 bits | no admitido | 50 | 1 |
| `POP` | registro de 16 bits | no admitido | 58 | 1 |

### 2.2 Registros

| Identificador | Registro de 8 bits | Registro de 16 bits |
|---|---|---|
| 0 | `AL` | `AX` |
| 1 | `CL` | `CX` |
| 2 | `DL` | `DX` |
| 3 | `BL` | `BX` |
| 4 | `AH` | `SP` |
| 5 | `CH` | `BP` |
| 6 | `DH` | `SI` |
| 7 | `BH` | `DI` |

### 2.3 Valores inmediatos

| Registro destino | Rango permitido | Bytes que ocupa |
|---|---|---|
| 8 bits | 0 a 255 | 1 |
| 16 bits | 0 a 65535 | 2, primero el byte bajo y después el byte alto |

- El inmediato se escribe en decimal (`05`, `258`).
- También se acepta en hexadecimal con el sufijo `H`, siempre que empiece con un dígito (`0FH`).

### 2.4 Reglas de escritura

- Las minúsculas se convierten a mayúsculas, así que `mov al, 05` equivale a `MOV AL, 05`.
- Se permiten espacios y tabuladores entre los elementos.
- Los dos operandos de `MOV` se separan con una coma.

### 2.5 Ejemplo del cálculo

Para `MOV AX, 258`:

1. `MOV` con un registro de 16 bits tiene base B8.
2. `AX` tiene identificador 0, así que el código de operación es B8 + 0 = `B8`.
3. 258 en hexadecimal es 0102. El byte bajo es `02` y el byte alto es `01`.
4. Resultado: `B8 02 01`.

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
| `_imprimeAnalisis` | Muestra los elementos encontrados. Si el segundo operando empieza con un dígito lo presenta como "Valor inmediato"; en otro caso, como "Fuente". |

### 3.3 Segunda parte: validación sintáctica

| Procedimiento | Descripción |
|---|---|
| `_buscaMnemonico` | Recorre `tabla` comparando el mnemónico escrito con el de cada entrada. Deja en `r13` la dirección de la entrada encontrada o regresa -1 si no existe. |
| `_validaInmediato` | Convierte el segundo operando de texto a número, en decimal o en hexadecimal si termina en `H`. Regresa el valor, o -1 si contiene caracteres no válidos. |
| `_valida` | Aplica las reglas en orden: que el mnemónico exista, que tenga operando, que el número de operandos corresponda al tipo de instrucción, que el registro exista, que su tamaño sea admitido por la instrucción y que el inmediato sea válido y quepa en el registro. Si todo es correcto, llama a la generación de código; si no, muestra el error correspondiente. |
| `_digitoHex`, `_writeHex` | Convierten un byte en sus dos dígitos hexadecimales y los escriben. |

### 3.4 Tercera parte: traducción a código máquina

| Procedimiento | Descripción |
|---|---|
| `_buscaRegistro` | Recorre `registros` comparando el primer operando con cada nombre. Deja en `r14` la dirección de la entrada, que contiene el identificador y el tamaño del registro, o regresa -1 si no existe. |
| `_genera` | Arma los bytes en `codigo`. Toma la base de 8 o de 16 bits según el tamaño del registro y le suma el identificador. Si la instrucción lleva inmediato, agrega el byte bajo y, para registros de 16 bits, el byte alto. Regresa la cantidad de bytes generados. |
| `_writeCodigo` | Escribe los bytes generados en hexadecimal, con dos dígitos por byte y un espacio entre ellos. |
| `_writeErrorRequiere16` | Arma el mensaje `Error. <mnemónico> requiere un registro de 16 bits.` usando el mnemónico que escribió el usuario. |
| `_writeErrorExcede8`, `_writeErrorExcede16` | Muestran el error cuando el inmediato no cabe en el registro. |

### 3.5 Programa principal

`_start` muestra el título y entra al ciclo `_menu`. Con la opción 1 captura la instrucción, la analiza, muestra el análisis y llama a `_valida`. Con la opción 2 termina el programa mediante `_exit`.

## 4. Casos de prueba

### 4.1 Instrucciones válidas

| Entrada | Salida esperada | Qué comprueba |
|---|---|---|
| `MOV AL, 05` | `B0 05` | `MOV` con registro de 8 bits |
| `MOV CL, 05` | `B1 05` | La regla base + identificador con otro registro |
| `MOV BH, 255` | `B7 FF` | Valor máximo de 8 bits |
| `MOV AX, 258` | `B8 02 01` | Inmediato de dos bytes, byte bajo primero |
| `MOV CX, 5` | `B9 05 00` | Valor pequeño en registro de 16 bits |
| `MOV DX, 65535` | `BA FF FF` | Valor máximo de 16 bits |
| `mov al, 0fh` | `B0 0F` | Minúsculas e inmediato hexadecimal |
| `PUSH BX` | `53` | `PUSH` con registro de 16 bits |
| `POP BX` | `5B` | `POP` con registro de 16 bits |
| `PUSH SI` | `56` | Registro índice |
| `INC AX` | `40` | `INC` |
| `DEC BX` | `4B` | `DEC` |

### 4.2 Instrucciones inválidas

| Entrada | Salida esperada | Etapa que lo detecta |
|---|---|---|
| `MOV AL, 300` | `Error. El valor excede el rango de 8 bits.` | Traducción |
| `MOV AX, 65536` | `Error. El valor excede el rango de 16 bits.` | Traducción |
| `PUSH AL` | `Error. PUSH requiere un registro de 16 bits.` | Traducción |
| `POP CL` | `Error. POP requiere un registro de 16 bits.` | Traducción |
| `ADD AL, 05` | `ERROR: instruccion no reconocida.` | Validación |
| `PUSH` | `ERROR: falta el operando.` | Validación |
| `MOV AL` | `ERROR: falta el segundo operando.` | Validación |
| `PUSH AX, 5` | `ERROR: la instruccion solo lleva un operando.` | Validación |
| `MOV ZZ, 5` | `ERROR: registro no valido para esta instruccion.` | Validación |
| `MOV AL, BL` | `ERROR: valor inmediato no valido.` | Validación |
| `MOV AL 05` | `Error: falta la coma entre los operandos` | Análisis léxico |
| `MOV AL,` | `Error: falta un operando junto a la coma` | Análisis léxico |
| `MOV AL, 05 07` | `Error: hay texto de mas al final de la instruccion` | Análisis léxico |

## 5. Ejecución paso a paso

<!-- PENDIENTE: guardar las capturas en la carpeta capturas/ con los nombres indicados -->

### Paso 1. Ensamblado y enlace

Se ejecuta `make`, que ensambla `proyecto1.s` con `as` y lo enlaza con `ld`.

![Ensamblado con make](capturas/01-make.png)

### Paso 2. Menú principal

Al ejecutar `./proyecto1` aparece el título y el menú. La opción 1 analiza una instrucción y la opción 2 termina el programa.

![Menú principal](capturas/02-menu.png)

### Paso 3. Instrucción válida

Se elige la opción 1 y se escribe `MOV AX, 258`. El programa muestra la instrucción capturada, el resultado del análisis léxico, el resultado de la validación y los bytes generados:

```
Instruccion capturada: MOV AX, 258
Analisis:
Mnemonico: MOV
Destino: AX
Coma: ,
Valor inmediato: 258
Validacion:
Instruccion valida
Codigo maquina: B8 02 01
```

![MOV AX, 258](capturas/03-mov-ax.png)

### Paso 4. Instrucción de un operando

Se escribe `PUSH BX`. El análisis solo encuentra mnemónico y destino, y el resultado es un byte: `53`.

![PUSH BX](capturas/04-push-bx.png)

### Paso 5. Valor fuera de rango

Se escribe `MOV AL, 300`. La instrucción tiene la forma correcta, pero 300 no cabe en un registro de 8 bits, así que no se genera código y se muestra el error.

![MOV AL, 300](capturas/05-error-rango.png)

### Paso 6. Registro de tamaño incorrecto

Se escribe `PUSH AL`. `PUSH` solo admite registros de 16 bits y `AL` es de 8, por lo que se muestra el error.

![PUSH AL](capturas/06-error-registro.png)

### Paso 7. Demostración completa

Con `make demo` se traducen de una vez todas las instrucciones de `ejemplos.txt`.

![make demo](capturas/07-demo.png)

## 6. Conclusiones individuales

### Billy Rivera Salinas

Al desarrollar este proyecto en ensamblador logré entender mejor, y de forma más profunda, cómo funcionan la programación y el hardware.

