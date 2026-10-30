# Ping Pong interactivo en ensamblador 8086

Videojuego de ping-pong para dos jugadores, desarrollado en lenguaje ensamblador y preparado para ejecutarse en **emu8086**.

Proyecto del curso **Arquitectura de Computadoras, EIF205**, de la **Universidad Nacional, Escuela de Informática**.

**Profesor:** Cesar Valverde  
**Finalidad:** educativa.

## Descripción del proyecto

Cada jugador controla una paleta ubicada en un extremo del tablero y debe devolver la pelota al rival. Cuando uno de los participantes falla, el oponente obtiene un punto. Gana quien alcance primero **cinco puntos**.

El juego incorpora tres mecánicas que modifican la dinámica del ping-pong tradicional:

- Un obstáculo móvil en el centro del campo.
- Paletas que disminuyen de tamaño conforme avanza la partida.
- Un poder de ampliación temporal para cada jugador.

También incluye velocidad progresiva de **5 a 7**, pausa, menú, revancha y récord de devoluciones consecutivas.

## Características

- Dos jugadores en un mismo teclado.
- Controles independientes para ambas paletas.
- Puntuación individual.
- Victoria al alcanzar cinco puntos.
- Pelota con rebotes y cambios de dirección según el impacto.
- Obstáculo central móvil.
- Reducción progresiva de las paletas.
- Habilidad de ampliación con un uso por jugador.
- Aceleración durante los intercambios.
- Pausa y continuación.
- Revancha sin reiniciar el emulador.
- Récord durante la sesión.
- Dibujo incremental para reducir el parpadeo.
- Código organizado mediante procedimientos y una macro.

## Archivos del proyecto

| Archivo o carpeta | Contenido |
|---|---|
| `PINGPONG.ASM` | Código fuente del videojuego. |
| `README.md` | Instrucciones, reglas y explicación técnica. |
| `INFORME_TECNICO.md` | Arquitectura, módulos, pruebas y conclusiones. |
| `pruebas/RESULTADOS.md` | Resultados de las comprobaciones auxiliares. |
| `imagenes/` | Carpeta destinada a las capturas de la interfaz. |

El documento técnico en PDF puede agregarse al repositorio como documentación complementaria.

## Requisitos

- emu8086 instalado.
- Un teclado.
- El archivo `PINGPONG.ASM`.
- Dos participantes.

Para jugar no se necesitan Visual Studio, Python, bibliotecas externas ni conexión a Internet.

## Compilación y ejecución

1. Descarga o clona el repositorio.
2. Si descargaste un archivo ZIP, descomprímelo.
3. Abre **emu8086**.
4. Selecciona **File → Open**.
5. Abre el archivo **PINGPONG.ASM**.
6. Pulsa **Emulate** o **Compile and Emulate**.
7. Si solicita un formato, selecciona **COM**.
8. Coloca **step delay ms** en **0**.
9. Pulsa **Run**.
10. Haz clic dentro de la pantalla del juego y presiona **1**.

**Importante:** `Single Step` ejecuta instrucciones individualmente y sirve para depurar. Para jugar se utiliza `Run`.

Después de modificar el código, guarda el archivo y vuelve a compilarlo.

## Controles

| Jugador o pantalla | Tecla | Acción |
|---|---|---|
| Jugador 1, izquierda | W | Subir la paleta verde. |
| Jugador 1, izquierda | S | Bajar la paleta verde. |
| Jugador 1 | Q | Activar la ampliación temporal. |
| Jugador 2, derecha | Flecha arriba | Subir la paleta magenta. |
| Jugador 2, derecha | Flecha abajo | Bajar la paleta magenta. |
| Jugador 2 | L | Activar la ampliación temporal. |
| Durante la partida | P | Pausar o continuar. |
| Durante la partida | ESC | Regresar al menú. |
| Menú | 1 | Iniciar partida. |
| Menú | 2 o ESC | Salir. |
| Pantalla de resultados | R | Iniciar una revancha. |
| Pantalla de resultados | M | Regresar al menú. |
| Pantalla de resultados | ESC | Salir. |

Las letras también se aceptan en mayúscula.

## Reglas del juego

- Cada participante defiende su extremo con una paleta.
- La pelota rebota en los bordes superior e inferior.
- El contacto con una paleta invierte su dirección horizontal.
- Si un jugador no logra interceptarla, el rival obtiene un punto.
- Gana quien llegue primero a **cinco puntos**.
- Después de cada punto, la pelota reaparece en la zona central y se dirige inicialmente hacia quien falló.
- La barrera central puede interceptar ese saque.
- La parte superior de la paleta dirige la pelota hacia arriba; la inferior, hacia abajo. El centro conserva la dirección vertical.

## Nuevas mecánicas de jugabilidad

### 1. Obstáculo central móvil

Una barrera roja formada por cuatro caracteres `#` se desplaza verticalmente por el centro del tablero.

- Ocupa la columna 33.
- Se mueve una fila cada dos ticks de juego.
- Cambia de dirección al alcanzar los límites.
- Si la pelota choca contra ella, invierte su dirección horizontal.
- La pelota puede pasar cuando su trayectoria no coincide con las filas ocupadas por la barrera.
- Los contactos con el obstáculo no suman puntos ni aumentan el rally.

Esta mecánica obliga a reaccionar a cambios de dirección que no dependen únicamente del golpe del rival.

### 2. Paletas de tamaño progresivo

La altura normal de ambas paletas disminuye según la **suma de los puntos de los dos jugadores**:

| Puntos totales | Altura normal de cada paleta |
|---|---:|
| 0 o 1 | 5 celdas |
| 2 o 3 | 4 celdas |
| 4 o más | 3 celdas |

Por ejemplo:

- Con marcador **1–1**, las paletas miden cuatro celdas.
- Con marcador **2–2**, las paletas miden tres celdas.

La reducción se aplica después de anotarse un punto. Los límites de movimiento y las colisiones se adaptan a la altura real de cada paleta.

### 3. Poder de ampliación temporal

Cada jugador puede activar una habilidad **una sola vez por partida completa**:

- **Q:** jugador 1.
- **L:** jugador 2.

La habilidad amplía la paleta a **siete celdas durante 91 ticks de juego**, aproximadamente cinco segundos en un reloj BIOS normal.

Reglas del poder:

- La pausa no consume su duración.
- Repetir la tecla no prolonga el efecto.
- Anotar un punto no recarga el poder.
- Si continúa activo cuando se anota un punto, conserva el tiempo restante.
- Al terminar, la paleta recupera el tamaño normal correspondiente al marcador.
- Una revancha o una nueva partida restablece los dos usos.

| Estado | Significado |
|---|---|
| `LISTO` | El jugador puede activar su habilidad. |
| `ACTIVO` | La paleta está ampliada temporalmente. |
| `USADO` | La habilidad ya se consumió y no puede reutilizarse en esa partida. |

## Velocidad progresiva

La pelota comienza con velocidad **5** y aumenta durante cada intercambio:

| Devoluciones consecutivas | Valor de VEL |
|---|---:|
| 0 o 1 | 05 |
| 2 o 3 | 06 |
| 4 o más | 07 |

`VEL` indica la cantidad de **subpasos por actualización**, no cuadros por segundo.

Cada subpaso avanza una celda por eje y comprueba las colisiones con los bordes, las paletas y la barrera. El aumento de velocidad se aplica a la siguiente actualización.

Después de cada punto, la velocidad vuelve a **5**.

## Rally y récord

- **RALLY:** devoluciones consecutivas de las paletas durante el intercambio actual.
- **RECORD RALLY:** mayor cantidad de devoluciones consecutivas lograda durante la sesión.

Los rebotes contra el obstáculo no incrementan estos contadores.

El récord se conserva al volver al menú o iniciar una revancha, pero se pierde al cerrar el programa porque no se guarda en disco. Los contadores se limitan a 99.

## Interfaz del juego

### Captura de pantalla

<img width="1197" height="570" alt="image" src="https://github.com/user-attachments/assets/5ecbd3ef-9874-4c9e-b53d-7f4a41f9921a" />

*Figura 1. Interfaz con ambas paletas, obstáculo central, pelota, marcadores y estados de los poderes.*


### Indicadores de la pantalla

| Elemento | Significado |
|---|---|
| `J1 W/S` | Puntuación del jugador izquierdo. |
| `J2 FLECHAS` | Puntuación del jugador derecho. |
| `RECORD RALLY` | Mejor intercambio de la sesión. |
| `RALLY` | Devoluciones consecutivas actuales. |
| `VEL` | Velocidad actual: 05, 06 o 07. |
| `TAM J1/J2` | Altura real de ambas paletas. |
| `Q J1` | Estado del poder del jugador 1. |
| `L J2` | Estado del poder del jugador 2. |
| Paleta verde | Jugador 1. |
| Paleta magenta | Jugador 2. |
| Barrera roja | Obstáculo móvil. |
| Pelota amarilla | Objeto que deben devolver. |

## Organización del código

| Procedimiento | Responsabilidad |
|---|---|
| `inicializar` | Reiniciar puntos, posiciones, barrera, tamaños y poderes. |
| `centrarPelota` | Preparar el saque y reiniciar rally y velocidad. |
| `teclado` | Procesar controles, habilidades, pausa y menú. |
| `leerTick` | Consultar el reloj BIOS. |
| `esperarTiempo` | Regular las actualizaciones y calcular el tiempo transcurrido. |
| `actualizar` | Actualizar las mecánicas y ejecutar los subpasos. |
| `moverPelota` | Mover la pelota y comprobar límites y contactos. |
| `tocarPaleta` | Detectar contacto según la altura real. |
| `ajustarTamanos` | Calcular alturas y mantener las paletas dentro del tablero. |
| `activarPoder1` / `activarPoder2` | Activar la ampliación si queda disponible. |
| `actualizarExtras` | Actualizar la barrera y los temporizadores. |
| `descontarPoderes` | Descontar duración y finalizar las ampliaciones. |
| `puntoJ1` / `puntoJ2` | Sumar puntos, ajustar tamaños y comprobar victoria. |
| `dibujar` | Actualizar los objetos sin borrar toda la pantalla. |
| `pintarPaleta` | Dibujar una columna con la altura indicada. |
| `celda` | Escribir un carácter y su atributo en memoria de video. |
| `marcador` / `mostrarExtras` | Mostrar puntuaciones, tamaños y poderes. |
| `mostrarPausa` | Mostrar u ocultar la pausa. |
| `numero` | Presentar valores numéricos de dos dígitos. |

## Fundamentos y sintaxis del ensamblador

### Configuración del programa

```asm
#make_COM#
org 100h
jmp inicio
```

- `#make_COM#` selecciona el formato COM en emu8086.
- `org 100h` establece el desplazamiento de carga.
- `jmp inicio` salta sobre los datos iniciales para comenzar la ejecución.

### Declaración de variables

```asm
tamBase db 5
tam1 db 5
tam2 db 5
usado1 db 0
poder1 dw 0
deltaTick dw 1
```

- `db` reserva un byte.
- `dw` reserva una palabra de dos bytes.
- `tam1` y `tam2` contienen las alturas reales.
- `usado1` indica si se consumió la carga de J1.
- `poder1` contiene la duración restante.
- `deltaTick` almacena el tiempo transcurrido entre actualizaciones.

Una carga consumida y un efecto activo son datos diferentes: al expirar la habilidad, `poder1` queda en cero, pero `usado1` permanece en uno.

### Orden de operandos

Las instrucciones utilizan el orden **destino, origen**:

```asm
mov poder1, 91
```

Esta instrucción asigna 91 ticks de duración al poder del jugador 1.

### Comparaciones y saltos

```asm
cmp usado1, 0
jne finActivarPoder1
```

`cmp` compara los valores y modifica los indicadores del procesador. `jne` evita volver a activar un poder utilizado.

También se emplean `je`, `jb`, `jbe`, `ja`, `jae` y `jnc` para seleccionar caminos según los resultados de las comparaciones.

### Procedimientos y pila

`proc` y `endp` delimitan procedimientos. `call` guarda la dirección de retorno en la pila y `ret` la recupera.

`push` y `pop` permiten preservar registros, restaurándolos en orden inverso.

### Macro de impresión

```asm
IMPRIMIR macro cadena
    lea dx, cadena
    mov ah, 09h
    int 21h
endm
```

La macro obtiene la dirección del mensaje y utiliza DOS para mostrarlo. Las cadenas terminan con el símbolo `$`.

### Interrupciones utilizadas

| Interrupción | Uso |
|---|---|
| `INT 10h` | Video, cursor y limpieza. |
| `INT 16h` | Consulta y lectura del teclado. |
| `INT 1Ah` | Consulta del reloj BIOS. |
| `INT 21h` | Impresión de mensajes y finalización del programa. |

## Memoria de video y dibujo

El programa utiliza modo texto de **80 columnas por 25 filas** y memoria de video en el segmento **B800h**.

Cada celda ocupa dos bytes:

- Carácter.
- Atributo de color.

El desplazamiento se calcula mediante:

```text
desplazamiento = 2 × (fila × 80 + columna)
```

Para reducir el parpadeo, se borran las posiciones anteriores y se dibujan las actuales. Los bordes se presentan al iniciar la partida y el marcador se actualiza cuando cambia.

Las variables `anteriorTam1` y `anteriorTam2` permiten borrar completamente una paleta grande antes de dibujarla más pequeña, evitando restos al finalizar una habilidad.

## Pruebas

Los siguientes estados corresponden a la validación manual reportada por los integrantes en emu8086.

| Caso de prueba | Estado |
|---|---|
| Compilación y ejecución | Verificado y correcto |
| Controles de ambos jugadores | Verificado y correcto |
| Límites de las paletas | Verificado y correcto |
| Rebotes superior e inferior | Verificado y correcto |
| Colisiones con ambas paletas | Verificado y correcto |
| Asignación de puntos | Verificado y correcto |
| Aceleración de 5 a 7 | Verificado y correcto |
| Movimiento y colisiones del obstáculo | Verificado y correcto |
| Reducción progresiva de tamaños | Verificado y correcto |
| Activación y expiración de poderes | Verificado y correcto |
| Uso único de cada habilidad | Verificado y correcto |
| Pausa y continuación | Verificado y correcto |
| Condición de victoria | Verificado y correcto |
| Revancha y recarga de poderes | Verificado y correcto |
| Conservación del récord durante la sesión | Verificado y correcto |
| Rendimiento y dibujo | Verificado y correcto |

También se realizaron comprobaciones auxiliares de lógica, memoria de video y pila, incluyendo 1500 actualizaciones de estabilidad y un flujo completo con revancha y salida. Su método y alcance se describen en el informe técnico.

## Problemas corregidos durante el desarrollo

- **Pelota inmóvil:** se sustituyó la lectura directa del reloj por `INT 1Ah`.
- **Parpadeo:** se eliminó el borrado completo de pantalla en cada movimiento.
- **Lentitud:** se redujeron esperas y operaciones repetidas de dibujo.
- **Salto condicional fuera de rango:** se utilizó una condición inversa seguida de un salto incondicional.
- **Restos al cambiar de tamaño:** se incorporó el registro de alturas anteriores.
- **Expiración de poderes:** se evita restar un intervalo mayor al tiempo restante.
- **Reutilización del poder:** se separó la carga consumida de la duración activa.

## Limitaciones conocidas

- El récord se conserva únicamente durante la sesión.
- La velocidad efectiva depende del rendimiento del emulador.
- La entrada por eventos BIOS puede limitar la repetición de varias teclas mantenidas simultáneamente.
- La duración de cinco segundos del poder es aproximada según el reloj y la ejecución del entorno.

## Uso educativo

Este proyecto fue desarrollado **con fines educativos** como parte del curso Arquitectura de Computadoras.

Su propósito es aplicar conocimientos de arquitectura 8086, programación en ensamblador, manejo de registros, pila, interrupciones, memoria de video y lógica de videojuegos.

## Integrantes

- **Warner Guevara C**
- **Jordana Montoya G**
