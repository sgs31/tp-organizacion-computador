.data
    mensajeLeerDatos: .ascii "Ingrese un valor entre 1-9 para el desplazamiento y para la pendiente separados por una ',' y finalizado con ';'. Ejemplo: 2,5; \n"
    longitudMensajeLeerDatos= . - mensajeLeerDatos
    datos: .ascii "1,3;"

    x: .word 0
    pendiente: .word 0

.text

    mostrarMensajeLeerDatos:
        .fnstart
            ldr r1, =mensajeLeerDatos
            ldr r2, =longitudMensajeLeerDatos
            mov r7, #4 /*escribo  */
            mov r0, #1 /*stdout pantalla*/
            swi 0    /* SWI, Software interrup*/
            bx lr /*salimos de la funcion mifuncion*/
        .fnend

    leerdatos:
        .fnstart
            push {lr, r1, r2, r3}
            ldr r1, =mensajeLeerDatos
            ldr r2, =longitudMensajeLeerDatos
            bl mostrarMensajeLeerDatos
            pop {lr, r1, r2, r3}
            bx lr
        .fnend
    
    /* Convertir recibe por r8 el ascii y lo pasa a decimal */
    convertir:
        .fnstart
            sub r8, #48
            bx lr
        .fnend

    cargarDatos:
        .fnstart
            push {lr, r2, r3, r4, r5, r6, r8}
                /* Me traigo las direcciones de memoria */
                ldr r2, =x 
                ldr r3, =pendiente
                ldr r5, =datos
                
                mov r4, #0 /* r4 con motivos de ser un acumulador y luego dejar en memoria lo que corresponda */

                cargarDatosCiclo:
                    ldrb r6, [r5] /* cargo los ascii en r6 */
                    cmp r6, #';' /* nos fijamos si es el fin de la cadena */
                    beq cargarDatosCambioEnPendiente 
                    cmp r6, #',' /* nos fijamos si es la separacion de la x y la pendiente que se ingreso */
                    beq cargarDatosCambioEnX
                    mov r8, r6 /* dejo en r8 lo que hay en r6 */
                    bl convertir
                    add r4, r8
                    add r5, #1
                    b cargarDatosCiclo

                cargarDatosCambioEnX:
                    str r4, [r2]
                    mov r4, #0
                    add r5, #1
                    b cargarDatosCiclo

                cargarDatosCambioEnPendiente:
                    str r4, [r3]
                    pop {lr, r2, r3, r4, r5, r6, r8}
                    bx lr
        .fnend

    

.global main
main:

    
    bl mostrarMensajeLeerDatos
    bl cargarDatos
    
    ldr r1, =x
    ldr r1, [r1]

    ldr r2, =pendiente 
    ldr r2, [r2]


    mov r7, #1
    swi 0
