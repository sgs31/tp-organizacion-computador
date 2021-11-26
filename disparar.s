.data
mapa: .asciz  "_____________________________________________________________________________|\n                                                                            |\n     *** WORMS ARMAGEDON - ORGA 1 ***                                        |\n_____________________________________________________________________________|\n                                                                             |\n                                                                             |\n                                                                             |\n                                                                             |\n                                                                             |\n                                                                             |\n          +------------+                                                     |\n          |            |                                     @               |\n          |            |                                     ####            |\n          |            |                                    +----------------+\n          +------------+                                    |                |\n                                                            |                |\n                                                            |                |\n                                                            |                |\n                                        +--------------+    |                |\n                                        |              |    |                |\n                    @                   |              |    |                |\n                 ####                   |              |    |                |\n +------------------------------+       |              |    |                |\n |                              |       |              |    |                |\n |                              |       +--------------+    |                |\n |                              |                           |                |\n |                              |                           |                |\n |                              |                           +----------------+\n |                              |                                            |\n +------------------------------+                                            |\n_____________________________________________________________________________|\n"
longitud =. - mapa
enter: .ascii "\n"
cls: .asciz "\x1b[H\x1b[2J" /*una manera de borrar la pantalla usando ansi escape code*/
longcls = .-cls
YJugadorTurno: .word 21    /*carga el Y del jugador que le toca jugar*/

pendiente: .word 1        /*valores de 0 a 9*/
x: .word 1		/*corrimiento*/
signo: .word 1  /*Signo de la pendiente. Si es positivo el valor es 1, si es negativo es 0*/
direccion: .word 1 /*si dispara a la derecha el valor es 1, si dispara a la izquierda el valor es 0*/
signoCorrimiento: .word 1 /*signo de la pendiente. +=1 y -=0*/
subio: .word 1 /*1 si uso opcion1, 2 si uso opcion2*/

.text

disparar:
.fnstart
push {lr}
ldr r0,=mapa /*PROHIBIDO USAR R0*/
ldr r1,=YJugadorTurno /*en este caso, esto solo funciona para el jugador 1. Si se desea realizar para dos jugadores entonces se puede crear ubicabj el cual carga la ubicacion de la cabeza del jugador que le toque jugar*/
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
beq corrimientoPosNeg
add r0, #1    /*Si no lo es mira el caracter de la derecha*/
b buscarX

corrimientoPosNeg: /*se mueve dependiendo si el corrimeinto es positivo o negativo*/
ldr r1,=signoCorrimiento
ldr r1, [r1]
cmp r1, #1
beq avanzarX
b retrocederX

avanzarX: /*hace el corrimiento de x*/
add r0, #1
ldrb r12, [r0]
bl detectarColision
cmp r11, #1
beq vuelta
cmp r2, #1 /*R2 es el contenido de X*/
beq preparando
sub r2, #1
b avanzarX

retrocederX: /*hace el corrimiento negativo de x*/
sub r0, #1
ldrb r12, [r0]
bl detectarColision
cmp r11, #1
beq vuelta2
cmp r2, #1
beq preparando
sub r2, #1
b retrocederX

vuelta2: /*avanzo 1 si hay colision en el corrimiento*/
add r0, #1
bl preparando


vuelta: /*retrocede 1 si hay colision en el corrimiento*/
sub r0, #1
bl preparando

preparando: /*cargo los valores necesarios*/
add r0, #79 /*busco el nivel del suelo*/
ldr r1,= YJugadorTurno
ldr r1, [r1] /*cargo la ubicacion donde comenzará el disparo*/
add r1, #1 /*como bajé una fila entonces sumo 1 a r1*/
ldr r2,= pendiente
ldr r2, [r2] /*cargo el valor de la pendiente*/
add r2, #2
mov r3, r2 /*copio el valor de la pendiente para luego compararlo*/
ldr r4,=direccion
ldr r4, [r4] /*cargo la direccion de disparo*/
cmp r4, #0
beq preparadoIzq /*salta para disparar a la izquierda*/
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
beq opcion2
add r0, #1
sub r2, #1
b dibujarPos


corresponde: /*determina que corresponde dibujar*/
strb r12, [r0] /*cargo el contenido que corresponde en el mapa*/
cmp r11, #1
beq salir
add r0, #1 /*AVANZO UN CARACTER*/
sub r2, #1 /*disminuye la pendiente*/
bl dibujarPos


reiniciarPendiente: /*reinicia el valor de la pendiente*/
ldr r2,= pendiente
ldr r2, [r2] /*cargo el valor de la pendiente*/
add r2, #2
ldr r4, =subio
ldr r4, [r4]
cmp r4, #1
beq opcion1 /*si hacemos la opcion 1 deberá subir una fila*/
ldr r4, =subio
mov r5, #1
str r5, [r4] /*reinicio para volver a usar la opcion 1*/
b dibujarPos

opcion1:
sub r0, #79
sub r1, #1
b dibujarPos


opcion2:
sub r0, #79 /*subo una fila*/
sub r1, #1 /*resto 1 a mi ubicacion actual*/
ldrb r12, [r0]
bl detectarColision
cmp r11, #1
beq salir /*comparo, si al recorrer en linea recta hay una colision subo.Si al subir hay colision significa que no se puede graficar porque se va fuera del mapa o queda dentro de un rectangulo */
ldr r4,=subio
mov r5, #2
str r5, [r4] /*cargo que estoy usando la opcion 2*/
add r0, #1
sub r2, #1
bl dibujarPos



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
beq opcion2Neg
add r0, #1
sub r2, #1
b dibujarNeg


correspondeNeg: /*determina que corresponde dibujar*/
strb r12, [r0] /*cargo el contenido que corresponde en el mapa*/
cmp r11, #1
beq salir
add r0, #1
sub r2, #1
bl dibujarNeg


reiniciarPendienteNeg: /*reinicia el valor de la pendiente*/
ldr r2,= pendiente
ldr r2, [r2] /*cargo el valor de la pendiente*/
add r2, #2
ldr r4, =subio
ldr r4, [r4]
cmp r4, #1
beq opcion1Neg /*si hacemos la opcion 1 deberá subir una fila*/
ldr r4, =subio
mov r5, #1
str r5, [r4] /*reinicio para volver a usar la opcion 1*/
b dibujarNeg


opcion1Neg:
add r0, #79
sub r1, #1
b dibujarNeg


opcion2Neg:
add r0, #79 /*bajo una fila*/
add r1, #1 /*sumo 1 a mi ubicacion actual*/
ldrb r12, [r0]
bl detectarColision
cmp r11, #1
beq salir /*comparo, si al recorrer en linea recta hay una colision subo.Si al subir hay colision significa que no se puede graficar porque se va fuera del mapa o queda dentro de un rectangulo */
ldr r4,=subio
mov r5, #2
str r5, [r4] /*cargo que estoy usando la opcion 2*/
add r0, #1
sub r2, #1
bl dibujarNeg










/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/


preparadoIzq:
ldr r4,= signo /*cargo el signo*/
ldr r4, [r4]  
cmp r4, #0
beq dibujarNegIzq
b dibujarPosIzq



dibujarPosIzq: /*recorre caracter por caracter*/
cmp r1, #5
blt salir /*si llegamos a un area no jugable entonces deja de dibujar*/
cmp r2, #0 /*si la pendiente es 0, entonces se debe reiniciar*/
beq reiniciarPendienteIzq
ldrb r12, [r0]
bl detectarColision
cmp r2, r3 
beq correspondeIzq /*mira si corresponde dibujar o no*/
cmp r11, #1
beq opcion2Izq
sub r0, #1 /*avanzo uno a la izquierda*/
sub r2, #1 /*disminuye la pendiente*/
b dibujarPosIzq


correspondeIzq: /*determina que corresponde dibujar*/
strb r12, [r0] /*cargo el contenido que corresponde en el mapa*/
cmp r11, #1
beq salir /*si hubo colision sale*/
sub r0, #1 /*retrocedo un caracter*/
sub r2, #1
bl dibujarPosIzq


reiniciarPendienteIzq: /*reinicia el valor de la pendiente*/
ldr r2,= pendiente
ldr r2, [r2] /*cargo el valor de la pendiente*/
add r2, #2
ldr r4, =subio
ldr r4, [r4]
cmp r4, #1
beq opcion1Izq /*si hacemos la opcion 1 deber� subir una fila*/
ldr r4, =subio
mov r5, #1
str r5, [r4] /*reinicio para volver a usar la opcion 1*/
b dibujarPosIzq



opcion1Izq:
sub r0, #79
sub r1, #1
b dibujarPosIzq


opcion2Izq:
sub r0, #79 /*subo una fila*/
sub r1, #1 /*resto 1 a mi ubicacion actual*/
ldrb r12, [r0]
bl detectarColision
cmp r11, #1
beq salir /*comparo, si al recorrer en linea recta hay una colision subo.Si al subir hay colision significa que no se puede graficar porque se va fuera del mapa o queda dentro de un rectangulo */
ldr r4,=subio
mov r5, #2
str r5, [r4] /*cargo que estoy usando la opcion 2*/
sub r0, #1
sub r2, #1
bl dibujarPosIzq




/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

dibujarNegIzq: /*recorre caracter por caracter*/
cmp r1, #31
beq salir /*si llegamos a un area no jugable entonces deja de dibujar*/
cmp r2, #0
beq reiniciarPendienteNegIzq
ldrb r12, [r0]
bl detectarColision
cmp r2, r3 
beq correspondeNegIzq
cmp r11, #1
beq opcion2NegIzq
sub r0, #1
sub r2, #1
b dibujarNegIzq


correspondeNegIzq: /*determina que corresponde dibujar*/
strb r12, [r0] /*cargo el contenido que corresponde en el mapa*/
cmp r11, #1
beq salir
sub r0, #1 
sub r2, #1
bl dibujarNegIzq


reiniciarPendienteNegIzq: /*reinicia el valor de la pendiente*/
ldr r2,= pendiente
ldr r2, [r2] /*cargo el valor de la pendiente*/
add r2, #2
ldr r4, =subio
ldr r4, [r4]
cmp r4, #1
beq opcion1NegIzq /*si hacemos la opcion 1 deber� subir una fila*/
ldr r4, =subio
mov r5, #1
str r5, [r4] /*reinicio para volver a usar la opcion 1*/
b dibujarNegIzq

opcion1NegIzq:
add r0, #79
sub r1, #1
b dibujarNegIzq


opcion2NegIzq:
add r0, #79 /*bajo una fila*/
add r1, #1 /*resto 1 a mi ubicacion actual*/
ldrb r12, [r0]
bl detectarColision
cmp r11, #1
beq salir /*comparo, si al recorrer en linea recta hay una colision subo.Si al subir hay colision significa que no se puede graficar porque se va fuera del mapa o queda dentro de un rectangulo */
ldr r4,=subio
mov r5, #2
str r5, [r4] /*cargo que estoy usando la opcion 2*/
add r0, #1
sub r2, #1
bl dibujarNegIzq
























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

	cmp r12, #'#'
	beq colisionCuerpo

	cmp r12, #'*'
	beq colisionDisparo

	mov r11, #1
	b finDetectarColision



        colisionEspacio:
            mov r12, #'*'
	    mov r11, #0
            b finDetectarColision

	colisionCuerpo: /*si un gusano coloca un corrimiento negativo y dispara a su propio cuero, no se toma como colision*/
	    mov r11, #0
	    b finDetectarColision

	colisionDisparo:/*Si un disparo colisiona con otro disparo sigue dibujando*/
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






.global main        @ global, visible en todo el programa
main:
 /*imprimo el mapa para empezar*/

ldr r2,=longitud /*Tamaño de la cadena*/
ldr r1,=mapa   /*Cargamos en r1 la direccion del mensaje*/
bl imprimirString
bl disparar
ldr r2, =longitud
ldr r1,=mapa
bl imprimirString
finalizo:
mov r7,#1
swi 0





























