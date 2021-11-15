.data
xEnAsci: .ascii "12345"
longitudX = .-xEnAsci
pendienteEnAsci: .ascii "12345"
longitudPendiente = .-pendienteEnAsci

saludo: .ascii "Saludos!"
longitudSaludo = .-saludo

.text

 resetXyPendiente:
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
        .fnend

    /* r1 recibe que mensaje y r2 la longitud del mensaje */
    mostrarMensaje:
        .fnstart
            mov r7, #4
            mov r0, #1
            swi 0
            bx lr
        .fnend

    
.global main
main:

    ldr r1, =xEnAsci
    ldr r2, =longitudX
    bl mostrarMensaje

    ldr r1, =pendienteEnAsci
    ldr r2, =longitudPendiente
    bl mostrarMensaje

    bl resetXyPendiente

    ldr r1, =xEnAsci
    ldr r2, =longitudX
    bl mostrarMensaje

    ldr r1, =pendienteEnAsci
    ldr r2, =longitudPendiente
    bl mostrarMensaje

    ldr r1, =saludo
    ldr r2, =longitudSaludo
    bl mostrarMensaje

    mov r7, #1
    swi 0