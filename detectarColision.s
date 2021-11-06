.data

viveGusano: .byte 1

.text
/* Por el registro r12 recibe el ascii y lo devuelve en el mismo y en el registro r11 devuelve el boolean */
/* Detectar colision de cualquier forma tiene que devolver un booleano. Si colisiono con algo, retornara  */
/* el ascii que se tiene que dibujar  */
/* @ = X , | = ' ' , + = ' ' , - = ' ' ,  */

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
            ldr r10, =viveGusano
            str r9, [r10]
            b finDetectarColision

        finDetectarColision:
            bx lr
    .fnend

.global main
main:
    
    ldr r1, =viveGusano
    ldr r1, [r1]    /* Hasta aca el gusano vive */
    mov r12, #' '
    bl detectarColision /* El contenido de r12 tiene que ser ahora: ' ' */
    mov r12, #'|'
    bl detectarColision /* El contenido de r12 tiene que ser ahora: ' ' */
    mov r12, #'+'
    bl detectarColision /* El contenido de r12 tiene que ser ahora: ' ' */
    mov r12, #'-'
    bl detectarColision /* El contenido de r12 tiene que ser ahora: ' ' */
    mov r12, #'@'
    bl detectarColision /* El contenido de r12 tiene que ser ahora: X */
    ldr r1, =viveGusano
    ldr r1, [r1]    /* Aca ya el gusano tiene que estar muerto */

    mov r7, #1
    swi 0
