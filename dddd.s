.data
mapa: .asciz  "_____________________________________________________________________________|\n                                                                            |\n     *** WORMS ARMAGEDON - ORGA 1 ***                                        |\n_____________________________________________________________________________|\n                                                                             |\n                                                                             |\n                                                                             |\n                                                                             |\n                                                                             |\n                                                                             |\n          +------------+                                                     |\n          |            |                                     @               |\n          |            |                                     ####            |\n          |            |                                    +----------------+\n          +------------+                                    |                |\n                                                            |                |\n                                                            |                |\n                                                            |                |\n                                        +--------------+    |                |\n                                        |              |    |                |\n                    @                   |              |    |                |\n                 ####                   |              |    |                |\n +------------------------------+       |              |    |                |\n |                              |       |              |    |                |\n |                              |       +--------------+    |                |\n |                              |                           |                |\n |                              |                           |                |\n |                              |                           +----------------+\n |                              |                                            |\n +------------------------------+                                            |\n_____________________________________________________________________________|\n"
longitud =. - mapa
enter: .ascii "\n"
cls: .asciz "\x1b[H\x1b[2J" /*una manera de borrar la pantalla usando ansi escape code*/
longcls = .-cls
Yj1: .word 21
Xj1: .word 1
pendiente: .word 0        /*valores de 0 a 9*/
x: .word 1		/*corrimiento*/
signo: .word 1  /*si es positivo el valor es 1, si es negativo es 0*/

mensaje: .ascii "Para continuar, ingrese un numero del 1 - 9 \n"
longitudMensaje= .-mensaje
input: .ascii "w"

enter1: .ascii "\n"

ganaJ1: .asciz "GANO J1"
enter2: .ascii "\n"

ganaJ2: .asciz "GANO J2"
enter3: .ascii "\n"

empate: .asciz "EMPATE"
enter4: .ascii "\n"

sinResultado: .asciz "  "
enter5: .ascii "\n"

cantDisparos: .asciz "Municion: "
enter6: .ascii "\n"

vidaJ1: .byte 3
vidaJ2: .byte 3
cantDisp: .byte 9

coordXInfResFin: .byte 10
coordYInfResFin: .byte 25

coordXCantDisp: .byte 10
coordYCantDisp: .byte 5
.text

disparar:
.fnstart
push {lr}
ldr r0,=mapa /*PROHIBIDO USAR R0*/
ldr r1,=Yj1 /*en este caso, esto solo funciona para el jugador 1. Si se desea realizar para dos jugadores entonces se puede crear ubicabj el cual carga la ubicacion de la cabeza del jugador que le toque jugar*/
ldr r1,[r1]
ldr r2,=x
ldr r2, [r2]

buscarY: /*busca la fila de la cabeza del jugador 1*/
cmp r1, #1 /*miro si llego a la columna de la cabeza del jugador*/
beq buscarX
add r0, #79 /*Avanzo una columna*/
sub r1, #1
b buscarY

buscarX:  /*busca la columna de la cabeza del jugador 1*/
ldrb r3, [r0]
cmp r3, #'@' /*Miro si encontre la cabeza del jugador 1*/
beq avanzarX
add r0, #1    /*Si no lo es mira el caracter de la derecha*/
b buscarX

avanzarX: /*hace el corrimiento de x*/
add r0, #1
cmp r2, #1 /*R2 es el contenido de X*/
beq preparando
sub r2, #1
b avanzarX


preparando: /*cargo los valores necesarios*/
add r0, #79 /*busco el nivel del suelo*/
ldr r1,= Yj1
ldr r1, [r1] /*cargo la ubicacion donde comenzará el disparo*/
add r1, #1 /*como bajé una fila entonces sumo 1 a r1*/
ldr r2,= pendiente
ldr r2, [r2] /*cargo el valor de la pendiente*/
add r2, #2
mov r3, r2 /*copio el valor de la pendiente para luego compararlo*/
ldr r4,= signo /*cargo el signo*/
ldr r4, [r4]  
cmp r4, #0
beq dibujarNeg
b dibujarPos

dibujarPos: /*recorre caracter por caracter*/
cmp r1, #5
blt salir /*si llegamos a un area no jugable entonces deja de dibujar*/
cmp r2, #0
beq reiniciarPendiente
ldrb r12, [r0]
bl detectarColision
cmp r2, r3 
beq corresponde
cmp r11, #1
beq salir
add r0, #1
sub r2, #1
b dibujarPos


corresponde: /*determina que corresponde dibujar*/
strb r12, [r0] /*cargo el contenido que corresponde en el mapa*/
cmp r11, #1
beq salir
sub r0, #79 /*subo una fila*/
sub r1, #1 /*resto 1 a mi ubicacion actual*/
sub r2, #1
bl dibujarPos


reiniciarPendiente: /*reinicia el valor de la pendiente*/
ldr r2,= pendiente
ldr r2, [r2] /*cargo el valor de la pendiente*/
add r2, #2
b dibujarPos

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

dibujarNeg: /*recorre caracter por caracter*/
cmp r1, #31
beq salir /*si llegamos a un area no jugable entonces deja de dibujar*/
cmp r2, #0
beq reiniciarPendienteNeg
ldrb r12, [r0]
bl detectarColision
cmp r2, r3 
beq correspondeNeg
cmp r11, #1
beq salir
add r0, #1
sub r2, #1
b dibujarNeg


correspondeNeg: /*determina que corresponde dibujar*/
strb r12, [r0] /*cargo el contenido que corresponde en el mapa*/
cmp r11, #1
beq salir
add r0, #79 /*bajo una fila*/
add r1, #1 /*sumo 1 a mi ubicacion actual*/
sub r2, #1
bl dibujarNeg


reiniciarPendienteNeg: /*reinicia el valor de la pendiente*/
ldr r2,= pendiente
ldr r2, [r2] /*cargo el valor de la pendiente*/
add r2, #2
b dibujarNeg

salir:
pop {lr}
bx lr

.fnend

/*_______________________________________________________*/
detectarColision:
	.fnstart
        cmp r12, #' '
        beq colisionEspacio

        cmp r12, #'|'
        beq colisionMuro

        cmp r12, #'+'
        beq colisionMuro

        cmp r12, #'-'
        beq colisionMuro

        cmp r12, #'@'
        beq colisionCabeza
	
	mov r11, #1
	b finDetectarColision

        colisionEspacio:
            mov r12, #'*'
	    mov r11, #0
            b finDetectarColision

        colisionMuro:
            mov r12, #' '
            mov r11, #1
            b finDetectarColision

        colisionCabeza:
            mov r12, #'X'
            mov r11, #1
            mov r9, #0
            /* ldr r10, =vidaJ2 */
            str r9, [r10]
            b finDetectarColision

        finDetectarColision:
 	bx lr
    .fnend


/*_____________________________________________________*/

imprimirString:
   .fnstart
      /*Parametros inputs:
      /* r1=puntero al string que queremos imprimir
      /*r2=longitud de lo que queremos imprimir*/
      push {lr}
push {r1}
push {r2}
      bl clearScreen
      pop {r2}
      pop {r1}
      mov r7,#4   /* Salida por pantalla */
      mov r0,#1  /* Indicamos a SWI que sera una cadena*/
      swi 0       /* SWI, Software interrup*/
      pop {lr}
      bx lr        /*salimos de la funcion mifuncion*/
   .fnend
/*---------------------------------------------------------*/
clearScreen:
	.fnstart
mov r0, #1
ldr r1, =cls
ldr r2, =longcls
mov r7, #4
swi 0

bx lr
	.fnend


/*______________________________________________________*/

leerTecla:
    .fnstart

        /*voy a usar una sys call R7 ;#3 leo entrada x teclado*/
        mov r7, #3    /* Lectura */
        mov r0, #0      /*stdin keyboard teclado*/
        mov r2, #1    /*maxima cantidad de caracteres que leo*/
        swi 0    /* SWI, Software interrup*/
        bx lr /*volvemos al lugar desde donde salimos*/
    .fnend

pasarinteger:
    .fnstart
        push {r9}
        ldr r8, [r8]
        mov r9, #48
        sub r8, r9
        pop {r9}
        bx lr
    .fnend

leerdatos:
    .fnstart
        push {lr}
        push {r8}
        ldr r1, =mensaje
        ldr r2, =longitudMensaje
        bl imprimirString
        ldr r1, =input
        bl leerTecla

        mov r7, #0
        ldr r9, =pendiente @limpio lo que pueda haber en desplazamiento
        str r7, [r9]

        ldr r8, =input
        bl pasarinteger
        ldr r9, =pendiente
        str r8, [r9]
        pop {r8}
        pop {lr}
        bx lr
    .fnend

.global main        @ global, visible en todo el programa
main:

ldr r2,=longitud /*Tama�o de la cadena*/
ldr r1,=mapa   /*Cargamos en r1 la direccion del mensaje*/
bl imprimirString

bl leerdatos

bl disparar

ldr r2, =longitud
ldr r1,=mapa
bl imprimirString

gameover:
mov r7,#1
swi 0