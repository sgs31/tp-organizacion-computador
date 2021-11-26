.data
turnoJ: .byte 1
signo: .word 1  /*Signo de la pendiente. Si es positivo el valor es 1, si es negativo es 0*/
direccion: .word 1 /*si dispara a la derecha el valor es 1, si dispara a la izquierda el valor es 0*/
signoCorrimiento: .word 1 /*signo de la pendiente. +=1 y -=0*/
YJugadorTurno: .word 21    /*carga el Y del jugador que le toca jugar*/

.text

cambiarTurnoo:
   .fnstart
      mov r8, #2
      mov r9, #1

      ldr r1, =turnoJ
      ldrb r2, [r1]
      cmp r2, #1
      beq cambiaraj2
      
      strb r9, [r1] @cargo 1
      bx lr
      cambiaraj2:
      
      strb r8, [r1] @cargo 2
      bx lr 
   .fnend

switchLugarDisparo:
   .fnstart
      
      mov r1, #1 @para cambiar en signo, direccion, signo corrimiento
      mov r2, #0 @para cambiar en signo, direccion, signo corrimiento
      mov r6, #21 @para cambiar en YjugadorTurno
      mov r9, #12 @para cambiar en YjugadorTurno

      ldr r3, =signo
      ldr r4, =direccion
      ldr r5, =signoCorrimiento
      ldr r8, =YJugadorTurno

      ldr r10, =turnoJ
      ldrb r10, [r10]
      cmp r10, #2
      beq cambiarPosicionDeDisparoAJ2
      str r6, [r8]
      str r1, [r3]
      str r1, [r4]
      str r1, [r5]

      bx lr
      cambiarPosicionDeDisparoAJ2:
      str r9, [r8]
      str r2, [r3]
      str r2, [r4]
      str r2, [r5]

      bx lr
   .fnend

.global main
main:
mov r1, #0
ldr r1, =turnoJ
ldrb r1, [r1]
bl cambiarTurnoo
ldr r1, =turnoJ
ldrb r1, [r1]

@21, 1, 1, 1 porque fue jugador 1
ldr r1, =YJugadorTurno
ldr r1, [r1] @21
ldr r1, =signo
ldr r1, [r1] @1
ldr r1, =direccion
ldr r1, [r1] @1
ldr r1, =signoCorrimiento
ldr r1, [r1] @1

@tiene que valer 2 ahora
ldr r1, =turnoJ
ldrb r1, [r1]

bl switchLugarDisparo

ldr r1, =YJugadorTurno
ldr r1, [r1] @12
ldr r1, =signo
ldr r1, [r1] @0
ldr r1, =direccion
ldr r1, [r1] @0
ldr r1, =signoCorrimiento
ldr r1, [r1] @0

bl cambiarTurnoo

ldr r1, =YJugadorTurno
ldr r1, [r1] @12
ldr r1, =signo
ldr r1, [r1] @0
ldr r1, =direccion
ldr r1, [r1] @0
ldr r1, =signoCorrimiento
ldr r1, [r1] @0

bl switchLugarDisparo

ldr r1, =YJugadorTurno
ldr r1, [r1] @21
ldr r1, =signo
ldr r1, [r1] @1
ldr r1, =direccion
ldr r1, [r1] @1
ldr r1, =signoCorrimiento
ldr r1, [r1] @1

mov r7, #1
swi 0

