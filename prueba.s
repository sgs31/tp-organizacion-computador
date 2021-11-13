.data

.text

subrutina1:
    .fnstart
        push lr
        add r1, #1
        b sub0
        
        sub0:
            b sub1
        sub1:
            bl subrutina2
            b salir
        salir:
        pop lr
        bx lr
    .fnend

subrutina2:
    .fnstart
        add r1, #1
        bx lr
    .fnend
    
.global main
main:

    mov r1, #1
    bl subrutina1

    mov r7, #1
    swi 0