.data

    mensajeX: .ascii "Ingrese un X\n"
    longitudMensajeX= . - mensajeX
    xEnAsci: .ascii "     "

    mensajePendiente: .ascii "Ingrese una pendiente\n"
    longitudMensajePendiente= . - mensajePendiente
    pendienteEnAsci: .ascii "     "

    x: .word 0
    pendiente: .word 0

.text

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
            mov r2, #4
            swi 0   
            ldr r0, [r1]
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

    /* recibe en r1 una direccion de cadena */
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

    cargarDatos:
        .fnstart
            push {lr, r2, r3, r4, r5, r6, r8}
            
            ldr r1, =xEnAsci
            bl convertirAscii2Integer
            ldr r11, =x
            str r8, [r11]

            ldr r1, =pendienteEnAsci
            bl convertirAscii2Integer
            ldr r11, =pendiente
            str r8, [r11]
            
            pop {lr, r2, r3, r4, r5, r6, r8}
            bx lr
        .fnend
    
    secuencia:
        .fnstart
            push {lr}

            bl resetXyPendiente

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
    
    bl secuencia
           
    ldr r1, =x
    ldr r1, [r1]

    ldr r2, =pendiente 
    ldr r2, [r2]

    bl secuencia

    ldr r1, =x
    ldr r1, [r1]

    ldr r2, =pendiente 
    ldr r2, [r2]

    mov r7, #1
    swi 0
