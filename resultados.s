/*Imprimir mapa*/
.data
 /* Definicion de datos */
mapa: .asciz  "_____________________________________________________________________________|\n                                                                            |\n     *** WORMS ARMAGEDON - ORGA 1 ***                         Turno player:1 |\n_____________________________________________________________________________|\n                                                                             |\n Municion:                                                                   |\n                                                                             |\n                                                                             |\n                                                                             |\n                                                                             |\n          +------------+                                                     |\n          |            |                                     @               |\n          |            |                                     ####            |\n          |            |                                    +----------------+\n          +------------+                                    |                |\n                                                            |                |\n                                                            |                |\n                                                            |                |\n                                        +--------------+    |                |\n                                        |              |    |                |\n                   @                    |              |    |                |\n                ####                    |              |    |                |\n +------------------------------+       |              |    |                |\n |                              |       |              |    |                |\n |                              |       +--------------+    |                |\n |                              |                           |                |\n |                              |                           |                |\n |                              |                           +----------------+\n |                              |                                            |\n +------------------------------+                                            |\n_____________________________________________________________________________|\n"
longitud =. - mapa
enter: .ascii "\n"

cls: .asciz "\x1b[H\x1b[2J" /*una manera de borrar la pantalla usando ansi escape code*/
longcls = .-cls

ganaJ1: .asciz "GANO J1"

ganaJ2: .asciz "GANO J2"

empate: .asciz "EMPATE"

vidaJ1: .byte 1
vidaJ2: .byte 0
cantDisp: .byte 3
/*agregar cantDispJ2*/

coordXInfResFin: .byte 10
coordYInfResFin: .byte 25

coordXCantDisp: .byte 10
coordYCantDisp: .byte 5

turnoJ: .byte 2
coordXTurno: .byte 74
coordYTurno: .byte 2

/*----------------------------------------------------------*/
.text             /* Defincion de codigo del programa*/
/*----------------------------------------------------------*/

mostrarMunicion:   
   .fnstart
      push {lr}
      ldrb r4, [r4]
	  /*restar 1 por turno*/
	  bl convertAscii
	  ldr r1, =coordXCantDisp
	  ldr r2, =coordYCantDisp
	  ldr r3, =mapa
	  bl calcularCoordenada
	  strb r4, [r3]
	  pop {lr}
	  bx lr
   .fnend

/*----------------------------------------------------------*/

informarResultadoParcial:   /*informa la cantidad de municion disponible y el turno del jugador*/
   .fnstart
      push {lr}
	  ldr r4, =cantDisp
	  bl mostrarMunicion
	  ldr r4, =turnoJ
	  bl asignarTurno
	  pop {lr}
	  bx lr
   .fnend
      

/*----------------------------------------------------------*/

asignarTurno:
   .fnstart
      push {lr}
      ldrb r4, [r4]
	  cmp r4, #1
	  beq juegaJ2
	  b juegaJ1
   cambiarTurno:
      bl convertAscii
	  bl setearTurno
	  pop {lr}
	  bx lr
   .fnend
   
   juegaJ1:
      mov r4, #1
	  b cambiarTurno
	  
   juegaJ2:
      mov r4, #2
	  b cambiarTurno

/*----------------------------------------------------------*/

setearTurno:
   .fnstart
   push {lr}
      ldr r1, =coordXTurno
	  ldr r2, =coordYTurno
	  ldr r3, =mapa
	  bl calcularCoordenada
	  strb r4, [r3]
	  pop {lr}
	  bx lr
   .fnend

/*----------------------------------------------------------*/

convertAscii:
   .fnstart
      add r4, #0x30
	  bx lr
   .fnend

/*----------------------------------------------------------*/


informarResultadoFinal:
   .fnstart
      push {lr}
	  ldrb r1, [r1]
	  ldrb r2, [r2]
	  ldrb r3, [r3]
      bl resultado
	  ldr r1, =coordXInfResFin
	  ldr r2, =coordYInfResFin
	  ldr r3, =mapa
	  bl calcularCoordenada	   
   ciclo:
       ldrb r6, [r4]
	   cmp r6, #0
	   bne reemplazo
	   pop {lr}
	   bx lr
   .fnend
   
   reemplazo:
      strb r6, [r3]
	  add r3, #1
	  add r4, #1
	  b ciclo

/*----------------------------------------------------------*/

resultado:
   .fnstart
      cmp r1, #0
	  beq gj2
	  cmp r2, #0
	  beq gj1
	  cmp r3, #0
	  beq emp
	  b volver
	gj1:
	   ldr r4, =ganaJ1
       b volver
	gj2:
	   ldr r4, =ganaJ2
	   b volver
	emp:
	   ldr r4, =empate
	   b volver
	volver:
	   bx lr
   .fnend

/*------------------------------------------------------------*/

calcularCoordenada:
   .fnstart
	  ldrb r1, [r1] /*coordenada columna*/
	  ldrb r2, [r2] /*coordenada fila*/ 
	   /*calculo el indice a la fila*/
	  mov r5, #79 /*cantidad de elementos por fila*/
	  mul r5, r2  /*nro de filas por cantidad de elementos*/
	   /* calculo el puntero a la fila desde mapa[0,0]*/
	  add r3, r5 /*puntero a la fila indicada en r2*/
	   /* sumo desplazamiento a que columna quiero ir*/
	  add r3, r1 /* r3=puntero a la fila + coordenada de columna*/
	  bx lr
   .fnend

/*------------------------------------------------------------*/

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

      bx lr /*salimos de la funcion mifuncion*/
  .fnend

/*----------------------------------------------------------*/

.global main        @ global, visible en todo el programa
main:
 /*imprimo el mapa para empezar*/

ldr r2,=longitud /*Tamaño de la cadena*/
ldr r1,=mapa   /*Cargamos en r1 la direccion del mensaje*/
bl imprimirString


ldr r1, =vidaJ1
ldr r2, =vidaJ2
ldr r3, =cantDisp
bl informarResultadoFinal


ldr r2,=longitud /*Tamaño de la cadena*/
ldr r1,=mapa   /*Cargamos en r1 la direccion del mensaje*/
bl imprimirString



bl informarResultadoParcial


ldr r2,=longitud /*Tamaño de la cadena*/
ldr r1,=mapa   /*Cargamos en r1 la direccion del mensaje*/
bl imprimirString

finalizo:
mov r7,#1
swi 0






/*Nota:
cuando un jugador elije su sitio, se puede guardar esos valores para calcular la coordenada de donde debe salir el disparo.
o siguiendo la idea de lucas,  dividir el mapa en sectores, el usuario solo elije el numero del sector, con eso tambien conocemos
la coordenada del disparo.*/