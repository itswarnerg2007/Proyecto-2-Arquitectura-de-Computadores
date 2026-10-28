# Ping Pong de dos jugadores en ensamblador 8086

Proyecto 2 del curso **Arquitectura de Computadoras (EIF205)** de la **Universidad Nacional, Escuela de Informática**.

Juego desarrollado en ensamblador para ejecutarse en **emu8086**, con dos jugadores, puntuación independiente y velocidad progresiva de **5 a 7**.

## Contenido

1. Descripción del proyecto
2. Características
3. Requisitos
4. Compilación y ejecución
5. Controles
6. Reglas y velocidad
7. Interfaz del juego
8. Organización del código
9. Sintaxis del lenguaje ensamblador
10. Memoria y representación gráfica
11. Funcionamiento del juego
12. Pruebas
13. Solución de problemas
14. Uso educativo
15. Integrantes

## 1. Descripción del proyecto

El videojuego consiste en un duelo de ping-pong para dos personas que comparten un teclado. Cada jugador controla una paleta vertical ubicada en un extremo del tablero y debe interceptar la pelota para devolverla al rival.

Cuando un jugador no logra devolverla, el oponente obtiene un punto. La partida termina cuando uno de los participantes alcanza cinco puntos.

El proyecto permite aplicar conceptos de arquitectura de computadoras mediante el uso de registros, procedimientos, macros, pila, interrupciones BIOS y DOS y acceso a memoria de video.

## 2. Características

- Juego para dos participantes.
- Paleta izquierda controlada con W y S.
- Paleta derecha controlada con las flechas.
- Menú principal.
- Pausa y continuación de la partida.
- Marcadores independientes.
- Velocidad inicial de 5 y máxima de 7.
- Cambios de trayectoria según la zona de impacto en la paleta.
- Récord de devoluciones consecutivas durante la sesión.
- Pantalla de resultados.
- Revancha sin reiniciar el emulador.
- Dibujo incremental para evitar borrar toda la pantalla en cada movimiento.
- Código organizado en procedimientos y una macro de impresión.

## 3. Requisitos

Para ejecutar el proyecto se necesita:

- emu8086 instalado.
- Un teclado.
- El archivo `PINGPONG.ASM`.
- Dos jugadores para controlar ambos lados.

No se requieren Visual Studio, Python, bibliotecas externas ni conexión a Internet para jugar.

### Archivos del proyecto

| Archivo | Descripción |
|---|---|
| `PINGPONG.ASM` | Código fuente del videojuego. |
| `README.md` | Instrucciones de uso y explicación del funcionamiento. |
| `INFORME_TECNICO.md` | Arquitectura, descripción de módulos, pruebas y conclusiones. |
| `imagenes/interfaz.png` | Captura de la interfaz que debe agregar el equipo. |

## 4. Compilación y ejecución

1. Descarga o clona el repositorio.
2. Si descargaste un ZIP, descomprímelo.
3. Abre emu8086.
4. Selecciona **File → Open**.
5. Busca y abre `PINGPONG.ASM`.
6. Pulsa **Emulate** o **Compile and Emulate**, según la versión de emu8086.
7. Si se solicita el formato de salida, selecciona **COM**.
8. En la ventana del emulador, coloca **step delay ms** en **0**.
9. Pulsa **Run**.
10. Haz clic dentro de la pantalla del juego y presiona **1** para comenzar.

**Nota:** `Single Step` ejecuta las instrucciones una por una y se utiliza para depurar. Para jugar se debe utilizar `Run`.

Después de modificar el código, guarda el archivo y vuelve a compilarlo para ejecutar la versión actualizada.

## 5. Controles

| Pantalla o jugador | Tecla | Acción |
|---|---|---|
| Menú principal | 1 | Iniciar partida. |
| Menú principal | 2 o ESC | Salir del programa. |
| Jugador 1, izquierda | W | Subir la paleta verde. |
| Jugador 1, izquierda | S | Bajar la paleta verde. |
| Jugador 2, derecha | Flecha arriba | Subir la paleta magenta. |
| Jugador 2, derecha | Flecha abajo | Bajar la paleta magenta. |
| Durante la partida | P | Pausar o continuar. |
| Durante la partida | ESC | Volver al menú. |
| Pantalla de resultados | R | Iniciar una revancha. |
| Pantalla de resultados | M | Volver al menú. |
| Pantalla de resultados | ESC | Salir del programa. |

Las letras de los controles también se aceptan en mayúscula.

La entrada utiliza eventos de teclado mediante BIOS. El comportamiento al mantener varias teclas presionadas depende de la repetición del teclado y del emulador, porque el programa no instala un controlador para registrar pulsaciones y liberaciones simultáneas.

## 6. Reglas y velocidad

### Reglas generales

- Cada jugador controla una paleta de cinco celdas de altura.
- Las paletas no pueden salir de los límites verticales del tablero.
- La pelota rebota en los bordes superior e inferior.
- Al tocar una paleta, cambia su dirección horizontal.
- Si un jugador falla, el rival recibe un punto.
- Gana quien llegue primero a **5 puntos**.
- Después de cada punto, la pelota vuelve al centro y sale hacia quien acaba de fallar.

### Dirección de la pelota

La zona de impacto influye en la trayectoria:

- Un golpe en la parte superior de la paleta dirige la pelota hacia arriba.
- Un golpe en la parte inferior la dirige hacia abajo.
- Un golpe en el centro conserva la dirección vertical.

### Velocidad progresiva

| Devoluciones consecutivas | Velocidad |
|---|---:|
| 0 o 1 | 5 |
| 2 o 3 | 6 |
| 4 o más | 7 |

La velocidad indica cuántos **subpasos** realiza la pelota en cada actualización. Cada subpaso avanza una celda por eje y comprueba las colisiones.

La actualización se solicita una vez por tick del reloj BIOS. La rapidez efectiva también depende del rendimiento del emulador.

El aumento de velocidad se aplica al número de subpasos de la siguiente actualización. Después de cada punto, la velocidad vuelve a 5.

### Rally y récord

- **RALLY:** cantidad de devoluciones consecutivas del intercambio actual.
- **RECORD RALLY:** mayor cantidad de devoluciones consecutivas lograda durante la sesión.

Ambos contadores se limitan a 99. El récord se conserva al volver al menú o iniciar una revancha, pero se pierde al cerrar el programa porque no se almacena en disco.

## 7. Interfaz del juego

### Captura de la interfaz

<img width="1201" height="577" alt="image" src="https://github.com/user-attachments/assets/b4df61c4-3bcb-4587-aa06-4c493b4fc858" />


*Figura 1. Interfaz de Ping Pong con las dos paletas, la pelota y los marcadores.*


### Elementos de la pantalla

| Elemento | Descripción |
|---|---|
| J1 W/S | Puntuación del jugador izquierdo. |
| J2 FLECHAS | Puntuación del jugador derecho. |
| RECORD RALLY | Mejor intercambio de la sesión. |
| RALLY | Devoluciones consecutivas del intercambio actual. |
| VEL | Velocidad actual: 05, 06 o 07. |
| Paleta verde | Jugador 1. |
| Paleta magenta | Jugador 2. |
| Pelota amarilla | Objeto que deben devolver ambos participantes. |
| Líneas horizontales | Límites superior e inferior. |
| Instrucciones inferiores | Recordatorio de controles y condición de victoria. |

Durante la pausa se muestra un mensaje. Al finalizar la partida aparece una pantalla que identifica al ganador y al perdedor y ofrece revancha, menú o salida.

## 8. Organización del código

| Procedimiento | Función |
|---|---|
| `inicializar` | Reinicia los puntos, las paletas y el estado de la partida. |
| `centrarPelota` | Coloca la pelota en el centro y restablece el intercambio. |
| `teclado` | Atiende los controles de los jugadores y las opciones de pausa y menú. |
| `leerTick` | Consulta el reloj BIOS. |
| `esperarTiempo` | Regula el avance mientras sigue atendiendo el teclado. |
| `actualizar` | Ejecuta los subpasos correspondientes a la velocidad. |
| `moverPelota` | Actualiza la posición y comprueba límites y extremos. |
| `tocarPaleta` | Comprueba el contacto y actualiza dirección, rally y velocidad. |
| `puntoJ1` | Suma un punto al jugador 1 y comprueba si ganó. |
| `puntoJ2` | Suma un punto al jugador 2 y comprueba si ganó. |
| `mostrarPausa` | Muestra o elimina el mensaje de pausa. |
| `limpiar` | Limpia la pantalla al cambiar de pantalla principal. |
| `dibujarBordes` | Dibuja los límites al iniciar una partida. |
| `dibujar` | Actualiza la pelota y las paletas. |
| `celda` | Escribe un carácter y su atributo en memoria de video. |
| `pintarPaleta` | Dibuja una paleta de cinco celdas. |
| `marcador` | Actualiza los indicadores de la partida. |
| `numero` | Muestra un valor de 0 a 99 con dos dígitos. |

La macro `IMPRIMIR` agrupa las instrucciones utilizadas para mostrar mensajes.

## 9. Sintaxis del lenguaje ensamblador

### Configuración inicial

```asm
#make_COM#
org 100h
jmp inicio
```

- `#make_COM#` indica a emu8086 que genere un programa COM.
- `org 100h` establece el desplazamiento de carga utilizado por este formato.
- `jmp inicio` evita ejecutar los datos iniciales y salta al comienzo del programa.

Las directivas orientan al ensamblador; no son instrucciones ejecutadas por la CPU.

### Declaración de datos

```asm
puntos db 0
velocidad db 5
dxPelota db -1
ultimoTick dw 0
```

- `db` reserva un byte.
- `dw` reserva una palabra de dos bytes.
- `dxPelota` utiliza 1 o -1 para representar la dirección horizontal.
- `ultimoTick` guarda una referencia del reloj.

Los mensajes también se definen con `db`:

```asm
barraTxt db ' J1 W/S: $'
```

El símbolo `$` marca el final de las cadenas mostradas mediante la función 09h de DOS. Los valores 13 y 10 presentes en otros mensajes representan retorno de carro y salto de línea.

### Orden de los operandos

La sintaxis sigue el orden:

```asm
instruccion destino, origen
```

Por ejemplo:

```asm
mov al, velocidad
mov pasos, al
```

La primera instrucción copia la velocidad en AL. La segunda copia AL en la variable `pasos`. El origen conserva su valor.

### Registros

| Registro | Uso dentro del programa |
|---|---|
| AX | Operaciones y selección de servicios de interrupción. |
| BX | Valores auxiliares, caracteres y atributos. |
| CX | Contadores de repeticiones. |
| DX | Coordenadas, direcciones de mensajes y resultados del reloj. |
| DI | Desplazamientos en memoria de video. |
| CS | Segmento de código. |
| DS | Segmento utilizado para acceder a los datos. |
| ES | Segmento utilizado para escribir en video. |
| SP | Posición superior de la pila. |

AX, BX, CX y DX tienen 16 bits. Sus mitades de 8 bits pueden utilizarse por separado; por ejemplo, AX se divide en AH y AL.

### Comentarios y números hexadecimales

```asm
mov ax, 0b800h   ; Segmento de memoria de video
```

El punto y coma inicia un comentario. El sufijo `h` identifica un número hexadecimal. Se antepone un cero cuando el número hexadecimal empieza con una letra.

### Comparaciones y saltos

```asm
cmp puntos, 5
jb puntoJ1Fin
mov estado, 3
```

`cmp` compara los valores y modifica los indicadores del procesador sin guardar la resta. `jb` salta si el primer valor es menor en una comparación sin signo.

Si el puntaje ya no es menor que cinco, se establece el estado de victoria del jugador 1.

| Instrucción | Significado |
|---|---|
| `jmp` | Salto incondicional. |
| `je` | Salta si los valores son iguales. |
| `jne` / `jnz` | Salta si el indicador de cero está desactivado. |
| `jb` | Salta si es menor, sin signo. |
| `jbe` | Salta si es menor o igual, sin signo. |
| `ja` | Salta si es mayor, sin signo. |
| `jae` | Salta si es mayor o igual, sin signo. |
| `jnc` | Salta si no hay acarreo. |

### Operaciones utilizadas

| Instrucción | Función |
|---|---|
| `add` | Suma. |
| `sub` | Resta. |
| `inc` | Incrementa en uno. |
| `dec` | Decrementa en uno. |
| `neg` | Cambia el signo. |
| `xor` | Operación lógica; se utiliza también para poner registros en cero. |
| `mul` | Multiplicación sin signo. |
| `div` | División sin signo. |
| `shl` | Desplazamiento de bits a la izquierda. |
| `loop` | Reduce CX y repite mientras no sea cero. |

### Procedimientos y pila

```asm
leerTick proc
    mov ah, 00h
    int 1ah
    mov ax, dx
    ret
leerTick endp
```

`proc` y `endp` delimitan un procedimiento en el código fuente.

```asm
call leerTick
```

`call` guarda la dirección de retorno en la pila y transfiere el control al procedimiento. `ret` recupera esa dirección para continuar.

`push` guarda una palabra en la pila y `pop` la recupera. Los registros deben restaurarse en orden inverso:

```asm
push ax
push bx

; Operaciones del procedimiento

pop bx
pop ax
ret
```

### Macro de impresión

```asm
IMPRIMIR macro cadena
    lea dx, cadena
    mov ah, 09h
    int 21h
endm
```

`lea` obtiene la dirección del mensaje. La macro prepara la función 09h y llama a DOS para mostrar la cadena.

Se utiliza así:

```asm
IMPRIMIR menuTxt
```

Una macro se expande en el lugar donde se utiliza; no requiere `call` ni `ret`.

### Interrupciones

| Interrupción | Función utilizada |
|---|---|
| `INT 10h` | Configuración de video, cursor y limpieza de pantalla. |
| `INT 16h` | Consulta y lectura del teclado. |
| `INT 1Ah` | Consulta del reloj BIOS. |
| `INT 21h` | Impresión de mensajes y caracteres y finalización del programa. |

La función concreta se selecciona colocando un valor en AH. Por ejemplo:

```asm
mov ah, 01h
int 16h
```

Consulta si existe una tecla disponible sin esperar a que el usuario presione una.

## 10. Memoria y representación gráfica

El programa utiliza el modo texto de **80 columnas por 25 filas**.

Al iniciar, establece DS igual a CS:

```asm
push cs
pop ds
```

Para acceder a la memoria de video utiliza el segmento B800h.

Cada celda ocupa dos bytes:

- Un byte para el carácter.
- Un byte para el atributo de color.

La posición se calcula mediante:

```text
desplazamiento = 2 × (fila × 80 + columna)
```

Los índices empiezan en cero. Por ejemplo, la fila 12 y la columna 32 corresponden al desplazamiento:

```text
2 × (12 × 80 + 32) = 1984 bytes = 07C0h
```

La pelota se escribe usando el valor `0E4Fh`: 4Fh corresponde al carácter O y 0Eh al atributo amarillo.

### Dibujo incremental

Para reducir el parpadeo:

1. Se borra la posición anterior de la pelota y las paletas.
2. Se dibujan sus nuevas posiciones.
3. Se actualiza el marcador únicamente cuando cambia.
4. Los bordes se dibujan al iniciar la partida.

No se limpia toda la pantalla en cada movimiento.

## 11. Funcionamiento del juego

### Estados

| Valor de `estado` | Significado |
|---:|---|
| 0 | Partida en ejecución. |
| 1 | Pausa. |
| 2 | Solicitud de regreso al menú. |
| 3 | Gana el jugador 1. |
| 4 | Gana el jugador 2. |

### Ciclo principal

Durante la partida, el programa:

1. Atiende el teclado.
2. Comprueba si se solicitó pausa o menú.
3. Espera el siguiente tick.
4. Ejecuta los subpasos de movimiento.
5. Actualiza la pantalla.
6. Comprueba si terminó la partida.

### Colisiones

La pelota se mueve entre las filas 3 y 21. Si intenta superar estos límites, cambia su dirección vertical.

La paleta izquierda se evalúa en la columna 3 y la derecha en la columna 62. Existe contacto cuando:

```text
primera fila de la paleta ≤ fila de la pelota ≤ primera fila de la paleta + 4
```

Cada subpaso comprueba esta condición, incluso cuando aumenta la velocidad.

`tocarPaleta` utiliza el indicador de acarreo como resultado:

- `clc`: hubo contacto.
- `stc`: hubo fallo.

Cuando se anota un punto, se cancelan los subpasos restantes del cuadro y se prepara un nuevo saque.

## 12. Pruebas

Las pruebas deben ejecutarse en emu8086 y sus resultados reales deben registrarse en el informe técnico.

| Prueba | Resultado esperado | Resultado real |
|---|---|---|
| Compilación | El archivo se compila sin errores. | Pendiente |
| Controles | Cada jugador mueve su paleta. | Pendiente |
| Límites | Las paletas permanecen dentro del tablero. | Pendiente |
| Rebotes | La pelota rebota en ambos bordes horizontales. | Pendiente |
| Colisiones | Ambas paletas devuelven la pelota. | Pendiente |
| Puntuación | Cada fallo suma un punto al rival. | Pendiente |
| Aceleración | VEL cambia de 05 a 06 y a 07. | Pendiente |
| Pausa | La partida se detiene y continúa. | Pendiente |
| Victoria | Gana quien alcanza cinco puntos. | Pendiente |
| Revancha | Se reinician los puntajes sin cerrar el emulador. | Pendiente |
| Récord | Se conserva durante la sesión. | Pendiente |

Las comprobaciones aisladas de lógica no sustituyen las pruebas de pantalla, teclado y rendimiento dentro de emu8086.

### El récord desaparece al cerrar

Es el comportamiento actual: el récord se conserva únicamente durante la ejecución del programa.

## 14. Uso educativo

Este proyecto fue desarrollado **con fines educativos** como parte del curso Arquitectura de Computadoras.

Su propósito es aplicar conocimientos de programación en ensamblador, arquitectura 8086, manejo de memoria, interrupciones, procedimientos y lógica de videojuegos.

La documentación describe la versión para dos jugadores con velocidad inicial 5 y máxima 7.

## 15. Integrantes

- **Warner Guevara C**
- **Jordana Montoya G**
