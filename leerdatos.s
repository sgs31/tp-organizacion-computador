.data
mensaje: .ascii "Para continuar, ingrese un numero del 1 - 9 \n"
longitudMensaje= .-mensaje
input: .ascii "w"

longi = .-input

pendiente: .word 0

.text

imprimirString:
    .fnstart
        /*Parametros inputs:*/
        /*r1=puntero al string que queremos imprimir*/
        /*r2=longitud de lo que queremos imprimir*/
        mov r7, #4 /*escribo  */
        mov r0, #2 /*stdout pantalla*/
        swi 0    /* SWI, Software interrup*/
        bx lr /*salimos de la funcion mifuncion*/
    .fnend

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
        ldr r8, [r8]
        mov r9, #48
        sub r8, r9
        bx lr
    .fnend

leerdatos:
    .fnstart
        push {lr}
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
        pop {lr}
        bx lr
    .fnend


.global main
main:

bl leerdatos

ldr r1, =input
ldr r2, =longi
bl imprimirString

ldr r1, =pendiente
ldr r1, [r1]

mov r7, #1
swi 0