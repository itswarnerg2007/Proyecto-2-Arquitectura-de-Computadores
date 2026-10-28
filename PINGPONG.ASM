; PING PONG 2 JUGADORES - Proyecto EIF205 - 8086 / emu8086
#make_COM#
org 100h
jmp inicio

IMPRIMIR macro cadena
    lea dx, cadena
    mov ah, 09h
    int 21h
endm

menuTxt db 13,10,'       PING PONG - DUELO DE 2 JUGADORES',13,10
        db '       1. Jugar | 2. Salir',13,10
        db '       Izquierda: W/S | Derecha: flechas arriba/abajo',13,10
        db '       P: pausa | ESC: menu',13,10
        db '       Gana quien llegue primero a 5 puntos.',13,10
        db '       Velocidad inicial 5, sube hasta 7.',13,10
        db '       Record de devoluciones seguidas de la sesion: $'
pausaTxt db ' PAUSA: P CONTINUA, ESC MENU $'
ganaTxt db 13,10,' JUGADOR 1 GANA! JUGADOR 2: GAME OVER.',13,10
        db ' R: revancha | M: menu | ESC: salir$'
pierdeTxt db 13,10,' JUGADOR 2 GANA! JUGADOR 1: GAME OVER.',13,10
          db ' R: revancha | M: menu | ESC: salir$'
barraTxt db ' J1 W/S: $'
derechaTxt db '   J2 FLECHAS: $'
recordTxt db '   RECORD RALLY: $'
rallyTxt db '   RALLY: $'
velocidadTxt db '  VEL: $'
ayudaTxt db ' Primero a 5 | W/S: izquierda | Flechas: derecha | P pausa | ESC menu$'
puntos db 0
puntos2 db 0
record db 0
rally db 0
velocidad db 5
pasos db 0
marcadorSucio db 1
paleta db 10
paleta2 db 10
pelotaX db 32
pelotaY db 12
anteriorX db 32
anteriorY db 12
anteriorPaleta db 10
anteriorPaleta2 db 10
dxPelota db -1
dyPelota db 1
ultimoTick dw 0
estado db 0                 ; 0 juego, 1 pausa, 2 menu, 3 gana J1, 4 gana J2

inicio:
    push cs
    pop ds
    mov ax, 0003h
    int 10h
menu:
    call limpiar
    IMPRIMIR menuTxt
    mov al, record
    call numero
esperarMenu:
    mov ah, 00h
    int 16h
    cmp al, '1'
    je nuevaPartida
    cmp al, '2'
    je salir
    cmp al, 27
    jne esperarMenu
salir:
    mov ax, 0003h
    int 10h
    mov ax, 4c00h
    int 21h
nuevaPartida:
    call inicializar
bucle:
    call teclado
    cmp estado, 2
    je menu
    cmp estado, 1
    je bucle
    call esperarTiempo
    call actualizar
    call dibujar
    cmp estado, 3
    je victoria
    cmp estado, 4
    je derrota
    jmp bucle
victoria:
    call limpiar
    IMPRIMIR ganaTxt
    jmp finPartida
derrota:
    call limpiar
    IMPRIMIR pierdeTxt
finPartida:
    mov ah, 00h
    int 16h
    cmp al, 'r'
    je nuevaPartida
    cmp al, 'R'
    je nuevaPartida
    cmp al, 'm'
    jne probarMenuMayuscula
    jmp menu
probarMenuMayuscula:
    cmp al, 'M'
    jne probarSalidaFinal
    jmp menu
probarSalidaFinal:
    cmp al, 27
    je salir
    jmp finPartida

; Reinicia la partida; el record se conserva en memoria.
inicializar proc
mov puntos, 0
    mov puntos2, 0
    mov paleta, 10
    mov paleta2, 10
    mov estado, 0
    call centrarPelota
    mov anteriorX, 32
    mov anteriorY, 12
    mov anteriorPaleta, 10
    mov anteriorPaleta2, 10
    call limpiar
    call dibujarBordes
    ; Instrucciones fijas en fila 24.
    mov ah, 02h
    xor bh, bh
    mov dx, 1800h
    int 10h
    IMPRIMIR ayudaTxt
    call leerTick
    mov ultimoTick, ax
    call dibujar
    ret
inicializar endp

centrarPelota proc
mov pelotaX, 32
    mov pelotaY, 12
    mov dxPelota, -1
    mov dyPelota, 1
    mov rally, 0
    mov velocidad, 5
    mov marcadorSucio, 1
    ret
centrarPelota endp

; Entrada no bloqueante por BIOS.
teclado proc
mov ah, 01h
    int 16h
    jnz hayTecla
    ret
hayTecla:
    mov ah, 00h
    int 16h
    cmp al, 27
    jne probarPausa
    mov estado, 2
    ret
probarPausa:
    cmp al, 'p'
    je alternarPausa
    cmp al, 'P'
    je alternarPausa
    cmp estado, 0
    je teclaMovimiento
    ret
alternarPausa:
    xor estado, 1
    call mostrarPausa
    call leerTick
    mov ultimoTick, ax
    ret
teclaMovimiento:
    ; Cada tecla pertenece a un solo jugador.
    cmp al, 'w'
    je arribaJ1
    cmp al, 'W'
    je arribaJ1
    cmp al, 's'
    je abajoJ1
    cmp al, 'S'
    je abajoJ1
    cmp ah, 48h
    je arribaJ2
    cmp ah, 50h
    je abajoJ2
    ret
arribaJ1:
    cmp paleta, 3
    jbe finMovimiento
    dec paleta
    ret
abajoJ1:
    cmp paleta, 17
    jae finMovimiento
    inc paleta
    ret
arribaJ2:
    cmp paleta2, 3
    jbe finMovimiento
    dec paleta2
    ret
abajoJ2:
    cmp paleta2, 17
    jae finMovimiento
    inc paleta2
finMovimiento:
    ret
teclado endp

; Palabra baja del contador BIOS (aproximadamente 18.2 ticks/s).
leerTick proc
    ; BIOS devuelve el contador de ticks en CX:DX.
    ; Usar el servicio BIOS evita depender de leer directamente 0040:006C.
    mov ah, 00h
    int 1ah
    mov ax, dx
    ret
leerTick endp

; Espera un tick atendiendo teclado.
esperarTiempo proc
espera:
    call teclado
    cmp estado, 0
    jne finEspera
    call leerTick
    sub ax, ultimoTick
    cmp ax, 1
    jb espera
    call leerTick
    mov ultimoTick, ax
finEspera:
    ret
esperarTiempo endp

; Movimiento por celdas, rebotes y colision con paleta.
actualizar proc
cmp estado, 0
    je empezarMovimiento
    ret
empezarMovimiento:
    mov al, velocidad
    mov pasos, al
siguientePaso:
    call moverPelota
    cmp estado, 0
    jne finActualizar
    cmp pasos, 0
    je finActualizar
    dec pasos
    jnz siguientePaso
finActualizar:
    ret
actualizar endp

; Cada subpaso recorre una celda y comprueba colisiones.
moverPelota proc
    mov al, pelotaY
    add al, dyPelota
    cmp al, 3
    jae probarBordeInferior
    mov al, 4
    neg dyPelota
probarBordeInferior:
    cmp al, 21
    jbe nuevaFila
    mov al, 20
    neg dyPelota
nuevaFila:
    mov pelotaY, al
    mov al, pelotaX
    add al, dxPelota
    mov pelotaX, al
    cmp al, 3
    jne comprobarDerecha
    mov bl, paleta
    call tocarPaleta
    jnc reboteIzquierdo
    call puntoJ2
    ret
reboteIzquierdo:
    mov dxPelota, 1
    ret
comprobarDerecha:
    cmp al, 62
    jne finMoverPelota
    mov bl, paleta2
    call tocarPaleta
    jnc reboteDerecho
    call puntoJ1
    ret
reboteDerecho:
    mov dxPelota, -1
finMoverPelota:
    ret
moverPelota endp

; BL = primera fila de la paleta. CF=0 contacto, CF=1 fallo.
; Devuelve la pelota hacia arriba o abajo segun el punto de impacto.
tocarPaleta proc
    mov al, pelotaY
    cmp al, bl
    jb noContacto
    sub al, bl
    cmp al, 4
    ja noContacto
    cmp al, 2
    jb golpeSuperior
    ja golpeInferior
    jmp contarRebote
golpeSuperior:
    mov dyPelota, -1
    jmp contarRebote
golpeInferior:
    mov dyPelota, 1
contarRebote:
    ; Saturacion a 99 para no desbordar el marcador de dos digitos.
    cmp rally, 99
    jae actualizarRecord
    inc rally
actualizarRecord:
    mov al, rally
    cmp al, record
    jbe comprobarVelocidad
    mov record, al
comprobarVelocidad:
    ; Aceleracion por intercambio: 5, 6 y 7 celdas por tick.
    cmp rally, 4
    jae velocidadMaxima
    cmp rally, 2
    jb terminarContacto
    mov velocidad, 6
    jmp terminarContacto
velocidadMaxima:
    mov velocidad, 7
terminarContacto:
    mov marcadorSucio, 1
    clc
    ret
noContacto:
    stc
    ret
tocarPaleta endp

puntoJ1 proc
    inc puntos
    mov pasos, 0
    call centrarPelota
    mov dxPelota, 1
    cmp puntos, 5
    jb puntoJ1Fin
    mov estado, 3
puntoJ1Fin:
    ret
puntoJ1 endp

puntoJ2 proc
    inc puntos2
    mov pasos, 0
    call centrarPelota
    cmp puntos2, 5
    jb puntoJ2Fin
    mov estado, 4
puntoJ2Fin:
    ret
puntoJ2 endp

; Mensaje de pausa en fila 1, sin reconstruir el tablero.
mostrarPausa proc
    push es
    mov ax, 0b800h
    mov es, ax
    mov di, 160
    mov ax, 0720h
    mov cx, 80
    cld
    rep stosw
    pop es
    cmp estado, 1
    jne finMostrarPausa
    mov ah, 02h
    xor bh, bh
    mov dx, 0100h
    int 10h
    IMPRIMIR pausaTxt
finMostrarPausa:
    ret
mostrarPausa endp

limpiar proc
    mov ax, 0600h
    mov bh, 07h
    mov cx, 0000h
    mov dx, 184fh
    int 10h
    mov ah, 02h
    xor bh, bh
    xor dx, dx
    int 10h
    ret
limpiar endp

; Imprime AL en decimal de 00 a 99.
numero proc
    push ax
    push bx
    push dx
    xor ah, ah
    mov bl, 10
    div bl
    mov bl, ah
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    mov dl, bl
    add dl, '0'
    mov ah, 02h
    int 21h
    pop dx
    pop bx
    pop ax
    ret
numero endp

; Dibuja los bordes una sola vez al comenzar la partida.
dibujarBordes proc
push es
    mov ax, 0b800h
    mov es, ax
    mov di, 320
    mov cx, 66
    mov ax, 0b3dh
    cld
    rep stosw
    mov di, 3520
    mov cx, 66
    rep stosw
    pop es
    ret
dibujarBordes endp

; Modo texto B800:0000: dos bytes por celda.
; Desplazamiento = 2 * (fila * 80 + columna).
dibujar proc
; El marcador se actualiza solo si cambia: menos interrupciones.
    cmp marcadorSucio, 0
    je dibujarObjetos
    call marcador
dibujarObjetos:
    push es
    mov ax, 0b800h
    mov es, ax
    ; Borra posiciones anteriores; nunca borra el tablero completo.
    mov dl, anteriorX
    mov dh, anteriorY
    mov ax, 0720h
    call celda
    mov dh, anteriorPaleta
    mov dl, 3
    mov ax, 0720h
    call pintarPaleta
    mov dh, anteriorPaleta2
    mov dl, 62
    call pintarPaleta
    ; Paletas actuales, verde y magenta.
    mov dh, paleta
    mov dl, 3
    mov ax, 0a7ch
    call pintarPaleta
    mov dh, paleta2
    mov dl, 62
    mov ax, 0d7ch
    call pintarPaleta
    mov dl, pelotaX
    mov dh, pelotaY
    mov ax, 0e4fh
    call celda
    mov al, pelotaX
    mov anteriorX, al
    mov al, pelotaY
    mov anteriorY, al
    mov al, paleta
    mov anteriorPaleta, al
    mov al, paleta2
    mov anteriorPaleta2, al
    pop es
    ret
dibujar endp


; AX = caracter/atributo, DL = columna, DH = fila. ES = video.
; Conserva registros y usa solo instrucciones 8086.
celda proc
    push ax
    push bx
    push dx
    push di
    mov bx, ax
    push dx
    xor ax, ax
    mov al, dh
    mov di, 160
    mul di
    mov di, ax
    pop dx
    xor ax, ax
    mov al, dl
    shl ax, 1
    add di, ax
    mov es:[di], bx
    pop di
    pop dx
    pop bx
    pop ax
    ret
celda endp

; Pinta cinco celdas verticales; conserva todos los registros usados.
pintarPaleta proc
    push cx
    push dx
    mov cx, 5
pintarCinco:
    call celda
    inc dh
    loop pintarCinco
    pop dx
    pop cx
    ret
pintarPaleta endp

marcador proc
    mov ah, 02h
    xor bh, bh
    xor dx, dx
    int 10h
    IMPRIMIR barraTxt
    mov al, puntos
    call numero
    IMPRIMIR derechaTxt
    mov al, puntos2
    call numero
    IMPRIMIR recordTxt
    mov al, record
    call numero
    IMPRIMIR rallyTxt
    mov al, rally
    call numero
    IMPRIMIR velocidadTxt
    mov al, velocidad
    call numero
    mov marcadorSucio, 0
    ret
marcador endp
