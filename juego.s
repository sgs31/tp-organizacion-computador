.data

mapa: .asciz  "_____________________________________________________________________________|\n                                                                            |\n     *** WORMS ARMAGEDON - ORGA 1 ***                                        |\n_____________________________________________________________________________|\n                                                                             |\n                                                                             |\n                                                                             |\n                                                                             |\n                                                                             |\n                                                                             |\n          +------------+                                                     |\n          |            |                                     @               |\n          |            |                                     ####            |\n          |            |                                    +----------------+\n          +------------+                                    |                |\n                                                            |                |\n                                                            |                |\n                                                            |                |\n                                        +--------------+    |                |\n                                        |              |    |                |\n                   @                    |              |    |                |\n                ####                    |              |    |                |\n +------------------------------+       |              |    |                |\n |                              |       |              |    |                |\n |                              |       +--------------+    |                |\n |                              |                           |                |\n |                              |                           |                |\n |                              |                           +----------------+\n |                              |                                            |\n +------------------------------+                                            |\n_____________________________________________________________________________|\n"
longitud =. - mapa
enter: .ascii "\n"
cls: .asciz "\x1b[H\x1b[2J" /*una manera de borrar la pantalla usando ansi escape code*/
longcls = .-cls
Yj1: .word 21
pendiente: .word 0        /*valores de 0 a 9*/
y: .word 0               /*Resultado de la trayectoria*/
x: .word 0

    mensajeX: .ascii "Ingrese un X\n"
    longitudMensajeX= . - mensajeX
    xEnAsci: .ascii "     "

    longx = .-xEnAsci

    mensajePendiente: .ascii "Ingrese una pendiente\n"
    longitudMensajePendiente= . - mensajePendiente
    pendienteEnAsci: .ascii "     "

    longp = .-pendienteEnAsci

.text

disparar: 
.fnstart
push {lr} 
ldr r0,=mapa /*PROHIBIDO USAR R0*/
ldr r1,=Yj1 /*en este caso, esto solo funciona para el jugador 1. Si se desea realizar para dos jugadores entonces se puede crear ubicabj el cual carga la ubicacion de la cabeza del jugador que le toque jugar*/
ldr r1,[r1]   /*remplazar por corchetes*/
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
beq prepararMultiplicacion
sub r2, #1
b avanzarX



prepararMultiplicacion: /*miro si alguno de los valores de la multiplicacion es 1 o 0*/

ldr r2, =x /*cargo el valor de x*/
ldr r2, [r2]
cmp r2, #1 /*si x=1, entonces y=pendiente*/
beq Xvale1
ldr r2, =pendiente
ldr r2, [r2]  /*cargo el valor de la pendiente*/
cmp r2, #0     /*miro si la pendiente es 0, si lo es el dibujo es una recta horizontal*/
beq PendienteVale0
cmp r2, #1
beq PendienteVale1
ldr r3,=x
ldr r4, [r3]
ldr r3, [r3]
b multiplicacion

multiplicacion: /*r2=pendiente*/
add r3, r4
sub r2, #1
cmp r2, #1
bne multiplicacion
ldr r4,=y
str r3, [r4]
b Preparardibujar




Xvale1: /*y=pendiente porque pendiente.1 = pendiente*/
ldr r1,=pendiente
ldr r1, [r1]
ldr r2,=y
str r1, [r2] /*cargo en y el valor de la pendiente*/
b Preparardibujar


PendienteVale1: /*y=x porque x.1=x*/
ldr r1,=y
str r2, [r1] /*cargo en y el valor de x*/
b Preparardibujar

PendienteVale0:
mov r1, #0
ldr r2,=y
str r1, [r2] /*cargo en y el valor de 0*/
b Preparardibujar


Preparardibujar: /*dibuja*/
ldr r1,= Yj1 /*carga cual es la fila de la cabeza del jugador (donde comienza el disparo)*/
ldr r1, [r1]
ldr r2,=y /*carga en r2 las veces que debo subir en Y*/
ldr r2,[r2]
b ciclon

ciclon:   /*r1= ubicacion de cabeza de jugador (usado como contador), r2=veces que debo subir, r3=caracter*/
cmp r2, #0
beq milanesa
cmp r1, #6 /*Si llegamos a la fila 4, entonces quiere decir que estamos fuera del terreno de juego y el juego termina*/
blt salir
sub r0, #79 /*subo una fila*/
sub r1, #1 /*como se subio una fila, entonces el contador de la ubicacion actual disminuye*/
sub r2, #1 /*como se subio una fila, entonces el contador de lo que me falta disminuye*/
b dibujar

milanesa:
ldr r2, =y
ldr r2, [r2] /*reinicio la cantidad de veces que debo seguir subiendo*/
add r0, #1 /*avanzo una columna*/
b ciclon



dibujar:
ldrb r12, [r0]
bl detectarColision
strb r12, [r0] /*intercambio el caracter que colisiona por el que correspone en el mapa*/
cmp r11, #1 /*si hubo una colision, intercambio lo que debe y sale*/
beq salir
b ciclon



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

 /* r1 recibe que mensaje y r2 la longitud del mensaje */
    mostrarMensaje:
        .fnstart
            mov r7, #4
            mov r0, #1
            swi 0
            bx lr
        .fnend

    /* en r1, recibe donde se guarda la cadena a ingresar */
    leerTecla:
        .fnstart
            mov r7, #3
            mov r0, #0
            mov r2, #4 /* cuantos caracteres lee */
            swi 0   
            ldr r0, [r1] /* r1 con la direccion del registro */ 
            bx lr
        .fnend
    
    /* en r1 recibe la direccion y en r2 devuelve la longitud */
    longitudCad:
	    .fnstart
            push {r1, r4}
            mov r2, #0     @ inicializo contador
            cicloLongCad:
                ldrb r4, [r1]   @ obtengo primer caracter de la cadena
                cmp r4, #' '
                beq salirLongCad
                add r1, #1 	
                add r2, #1
                bal cicloLongCad
            salirLongCad:
                pop {r1, r4}
                bx lr
	    .fnend

    /* recibe en r1 una direccion de cadena y retorna en r8 el numero */
    convertirAscii2Integer:
	.fnstart
        push {lr}
		mov r0, #1	@ Unidad, decena, centena, etc...
		mov r5, #10     @ Base
		mov r8, #0	@ Numero de destino
		mov r10, #0	@ Caracter a recorrer
		mov r11, #0	@ Contador

		bl longitudCad		@ en r2 tenemos la longitud de cadena1

		cicloConvertir:
			cmp r11, r2		@ comparo el contador con la longitud de cadena
			beq finConvertir
			add r11, #1		@ aumento el contador
			add r1, r2		@ me desplazo al caracter nulo
			sub r1, r11		@ retrocedo al caracter necesario
			ldrb r10, [r1]	@ cargar en r10 el caracter que estoy recorriendo

			sub r10, #0x30  @ le resto lo necesario para transformar ascii->num
			mul r10, r0     @ multiplico al numero para ubicarlo en la posicion
			add r8, r10     @ lo sumo al numero que ya venia teniendo

			mul r0, r5      @ "desplazo" el 1 hacia izquierda, 1, 10, 100 

			bal cicloConvertir

		finConvertir:
            pop {lr}
			bx lr
	.fnend

    /* resetXyPendiente:
        .fnstart
            mov r5, #' '
            mov r2, #5
            ldr r3, =xEnAsci
            ldr r4, =pendienteEnAsci
            resetXyPendienteCiclo:
            cmp r2, #0
            beq resetXyPendienteSalir
            strb r5, [r3]
            strb r5, [r4]
            add r3, #1
            add r4, #1
            sub r2, #1
            b resetXyPendienteCiclo
            resetXyPendienteSalir:
            bx lr
        .fnend */

    cargarDatos:
        .fnstart
            push {lr}
            
            ldr r1, =xEnAsci
            bl convertirAscii2Integer
            ldr r11, =x
            str r8, [r11]

            ldr r1, =pendienteEnAsci
            bl convertirAscii2Integer
            ldr r11, =pendiente
            str r8, [r11]
            
            pop {lr}
            bx lr
        .fnend

    secuencia:
        .fnstart
            push {lr}

            /* bl resetXyPendiente */

            /* Primer bloque para cargar X en ascii */
            ldr r1, =mensajeX
            ldr r2, =longitudMensajeX
            bl mostrarMensaje
            ldr r1, =xEnAsci
            bl leerTecla

            /* Segundo bloque para cargar la Pendiente en ascii */
            ldr r1, =mensajePendiente
            ldr r2, =longitudMensajePendiente
            bl mostrarMensaje
            ldr r1, =pendienteEnAsci
            bl leerTecla

            /* Cargar datos llena las variables x y pendiente con integers */
            bl cargarDatos
            
            pop {lr}
            bx lr
        .fnend



.global main
main:

    mov r1, #0
    mov r2, #0

    ldr r2,=longitud /*Tama�o de la cadena*/
    ldr r1,=mapa   /*Cargamos en r1 la direccion del mensaje*/
    bl imprimirString

    bl secuencia /* HASTA ACA YO CARGUE MIS VALORES EN X Y EN PENDIENTE */

    bl disparar

    ldr r2,=longitud /*Tama�o de la cadena*/
    ldr r1,=mapa   /*Cargamos en r1 la direccion del mensaje*/
    bl imprimirString

    mov r7, #1
    swi 0
