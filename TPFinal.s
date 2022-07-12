.data
  input_usuario: .asciz "                "
  long_input = . - input_usuario
  mensaje_error: .asciz "Lo siento, mis respuestas son limitadas \n"
  long_error = . - mensaje_error
  mensaje_resultado: .asciz "El resultado de la operacion es: "
  long_msj_resultado = . - mensaje_resultado
  text_result: .asciz "##########"
  operacion: .byte 0
  vector_num1: .asciz "     "
  long_vector_num1 = . - vector_num1
  vector_num2: .asciz "     "
  long_vector_num2 = . - vector_num2
  num1: .int 0
  signo_num1: .int 0 /*si es 1 es negativo*/
  cant_numeros_num1: .int 0
  num2: .int 0
  signo_num2: .int 0 /*si es 1 es negativo*/
  cant_numeros_num2: .int 0
  resultado: .int 0
  resto: .int 0
  resultadoStringAlreves: .asciz "             "
  long_resultadoStringAlreves = . -resultadoStringAlreves
  resultadoString: .asciz "             "
  long_resultadoString = . -resultadoString
  mensaje_despedida: .asciz "Adios! \n"
  long_despedida = . - mensaje_despedida
  enter: .asciz "\n"
  long_enter = . - enter
  saludoInicial: .asciz "Hola, en que puedo ayudarte? Puedo realizar las siguientes operaciones aritmeticas: '+ - * /' \n"
  longSaludo = . - saludoInicial
.text
print:
 .fnstart
    mov r7,#4
    mov r0,#1
    swi 0
    bx lr
 .fnend 
leer_input_usuario:
 .fnstart
   eor r7, r7
   eor r0, r0
   eor r1, r1
   eor r2, r2
   mov r7, #3 /*ingreso standard output*/
   mov r0, #0 /*le indico al SO que va a ser una cadena*/
   ldr r2, =long_input  /*tamaño de la cadena a leer*/
   sub r2, #1
   ldr r1, =input_usuario /*r1 = puntero de input*/
   swi 0
   bx lr
 .fnend

es_cuenta:
 .fnstart
   push {lr} /*agrega a la pila el retorno al main*/
   ldr r3, =input_usuario
   ldr r9, =long_input
   mov r8, #0 /*r8 = indice*/
   mov r5, #0 /*r5 = indice de vector_numX*/
   mov r6, #0 /*r6 = va a almacenar la cantidad de numeros ingresados en vector_numX*/
   ldrb r4, [r3, +r8] /*r4 = almacena el valor del caracter, r3 = puntero a input*/
   ldr r11, =vector_num1
   ldr r12, =long_vector_num1
   ldr r10, =signo_num1
   bl negativo 
   bl numero
   ldr r6, =cant_numeros_num1
   str r10, [r6]
   ldrb r4, [r3, +r8] /*r4 = almacena el valor del caracter, r3 = puntero a input*/
   bl es_operacion /*tendria que comprobar si es una operacion valida*/
   eor r5, r5
   eor r11, r11
   ldr r11, =vector_num2
   eor r12, r12
   ldr r12, =long_vector_num2
   ldrb r4, [r3, +r8] /*r4 = almacena el valor del caracter, r3 = puntero a input*/
   ldr r10, =signo_num2
   bl negativo
   bl numero
   ldr r6, =cant_numeros_num2
   str r10, [r6]
   ldr r3, =vector_num1
   ldr r6, =cant_numeros_num1
   ldr r1, =signo_num1
   bl reconocer_input
   ldr r4, =num1
   str r2, [r4]
   ldr r3, =vector_num2
   ldr r6, =cant_numeros_num2
   ldr r1, =signo_num2
   bl reconocer_input
   ldr r4, =num2
   str r2, [r4]
   bl resolver_operacion
   pop {lr}
   bx lr /*vuelve a quien lo llamo, seria el main*/
 .fnend 
negativo: 
 .fnstart
   cmp r4, #0x2D
   beq es_negativo
   bx lr
 es_negativo:
   eor r1, r1
   mov r1, #0x2D
   mov r2, #1
   strb r2, [r10]
   strb r1, [r11, r5] /*r11 = puntero a vector_num1*/
   add r5, #+1 /*mueve el puntero de vector_num1 1 posicion*/
   add r8, #+1 /*incrementa el indice*/
   ldrb r4, [r3, +r8] /*r4 = almacena el valor del caracter, r3 = puntero a input*/
 bx lr
 .fnend
ciclo_num:
 .fnstart
   cmp r5, r12 /*comparo puntero de vector_num con su long*/
   beq volver_a_es_cuenta
   cmp r8, r9 /*r9 = long_input, compara el indice con la long */
   blt es_espacio_o_num
   pop {lr}
   bx lr /*tendria que volver a es_cuenta*/
   volver_a_es_cuenta:
	pop {lr}
	bx lr
.fnend
 
es_espacio_o_num:
 .fnstart
   ldrb r4, [r3, +r8] /*r4 = almacena el valor del caracter, r3 = puntero a input*/
   cmp r4, #0x30 /*compara r4 con 0x30*/
   bge es_numero
   cmp r4, #0x20 /*compara r4 con espacio*/
   beq ir_a_es_cuenta
   cmp r4, #0x0A
   bne salirEs_cueta
 ir_a_es_cuenta:
   add r8, #1 /*guardo en r8 el siguiente indice*/
   pop {lr}
   bx lr /*tendria que volver a es_cuenta*/
 .fnend
 
numero:
 .fnstart
   push {lr} /*guarda el retorno a es_cuenta*/
   mov r10, #0
   cmp r4, #0x30
   bge es_numero
   bl salirEs_cueta
 es_numero:  
   cmp r4, #0x39 /*compara r4 con 0x39, si es menor o igual, lo almacena, sino error*/ 
   ble almacenar_nro
   /*bgt salirEs_cueta*/
  pop {lr}
  bx lr
 .fnend
salirEs_cueta:
	.fnstart
                bl es_salir
		pop {lr}
		pop {lr}
		bx lr
	.fnend
almacenar_nro:
 .fnstart
   eor r6, r6
   mov r6, r4
   subs r6, #0x30
   strb r6, [r11, r5] /*guarda el valor en el puntero a vector_numX*/
   add r5, #+1 /*r11 = puntero de vector_numX, lo actualiza en la sig posicion*/
   add r8, #+1 /*incrementa el indice*/
   add r10, #1
   bl ciclo_num
 .fnend 
 
es_operacion:
 .fnstart
   push {lr} /*guarda la direccion de retorno a es_cuenta*/
   cmp r4, #0x2A /*compara si es una multiplicacion (*) */
   beq cargar_operacion
   cmp r4, #0x2B /*compara si es una suma (+) */
   beq cargar_operacion
   cmp r4, #0x2D /*compara si es una resta (-) */
   beq cargar_operacion
   cmp r4, #0x2F /*compara si es una division (/)*/
   beq cargar_operacion
   bl salirEs_cueta /*si no es ninguna de las op, devuelve error*/
 .fnend
cargar_operacion:
 .fnstart
  ldr r10, =operacion
  strb r4, [r10]
  add r8, #+1
  ldrb r4, [r3, r8] /*incrementa el puntero de input en una posicion*/
  cmp r4, #0x20
  bne salirEs_cueta
  add r8, #1
  pop {lr}
  bx lr /*tendria que volver a es_cuenta*/
 .fnend
reconocer_input:
 .fnstart
  push {lr}
  ldr r6, [r6] /*r6 = cant numeros de numX*/
  mov r10, r6
  mov r5, #0 /*puntero*/
  mov r12, #0 /*r12 = acumulador*/
  ldr r1,[r1]
  bl mover_posicion_si_neg
  bl ciclo_numero
  bl ver_si_negativo
  pop {lr}
  bx lr
 .fnend
mover_posicion_si_neg:
 .fnstart
   cmp r1, #1
   beq mover
   bx lr
 mover:
   add r5, #1
   bx lr
 .fnend
ver_si_negativo:
 .fnstart
  cmp r1, #1
  beq hacer_negativo
 bx lr
 hacer_negativo:
  mov r3, #0xffffffff
  eor r2, r3
  add r2, #1
  /*muls r11, r2, r1
  mov r2, r11*/
 bx lr
 .fnend
ciclo_numero: /*recorre nro x nro, (recorre el vector)*/
 .fnstart
  push {lr} /*guarda el retorno a reconocer_input*/
  mov r8, #10
  mov r2, #0 /*r2 = acumulador*/
 ciclo_n: 
   ldrb r4, [r3, +r5]
   mov r9, r6 /* r9 = aux, para calc potencias de 10*/
   mov r11, #10
   bl calc_potencia
   mul r8, r4, r11
   add r2, r8
   add r5, #1 /*incrementa el puntero*/
   sub r6, #1 /*baja una potencia*/
   cmp r5, r10
   ble ciclo_n
  b salir_a_ri
 .fnend
 potencia_1:
 .fnstart
  mov r1, #1
  mul r12, r11, r1
  mov r11, r12
  sub r9, #1
  pop {lr} 
  bx lr
 .fnend
 salir_a_ri:
 .fnstart
  pop {lr}
  bx lr
 .fnend
potencia_0:
 .fnstart
  add r2, r4
  pop {lr}
  pop {lr}
  bx lr
 .fnend
calc_potencia:
   .fnstart
    push {lr} /*pushea el retorno a ciclo_n*/
    cmp r9, #2
    beq potencia_1
    cmp r9, #1
    beq potencia_0
    mul r12, r11, r8
    mov r11, r12
    sub r9, #1
    pop {lr}
    bx lr
   .fnend
resolver_operacion:
 .fnstart
   push {lr}
   eor r0, r0
   eor r1, r1
   eor r2, r2
   ldr r0,=operacion
   ldrb r0,[r0]
   ldr  r1,=num1  /*r0=operando de turno y lo compara con los ascii*/
   ldr  r1,[r1]   /*salta a la operacion a realizar si es igual o a error*/
   ldr  r2,=num2  /*r1 y r2 son los numeros*/
   ldr  r2,[r2]
   ldr  r10,=resultado /*r10=direccion donde se va a guardar el resultado*/
   mov  r9,#0     	   /*r9=resultado*/
   bl suma
   bl resta
   bl multiplicacion
   ldr r3,=resto /*r3=direccion en memoria del resto*/
   bl division
   pop {lr}
   bx lr
 .fnend
suma:
 .fnstart
   cmp r0,#0x2b
   beq sumar
   bx lr
 sumar:
   adds r9,r1,r2
   strb r9,[r10]
   bx lr
 .fnend
resta:
 .fnstart
   cmp r0,#0x2d
   beq restar
   bx lr
 restar:
   sub r9,r1,r2
   strb r9,[r10]
   bx lr
 .fnend
multiplicacion:
 .fnstart
   cmp r0,#0x2a
   beq multiplicar
   bx lr
 multiplicar:
   mul r9,r1,r2
   strb r9,[r10]
   bx lr
 .fnend
complemento_a2:
 .fnstart
  cmp r3, #1
  beq ca2
  bx lr
  ca2:
   mov r5, #0xffffffff
   eor r4, r5
   add r4, #1
   bx lr
 .fnend
division:
 .fnstart
   push {lr}
   cmp r0,#0x2f  /*r1/r2 r1=dividendo, r2=diviso*/
   beq dividir
   bx lr
 dividir:
   ldr r3, =signo_num1
   ldr r3, [r3]
   ldr r4, =num1
   ldr r4, [r4]
   bl complemento_a2
   mov r1, r4
   ldr r3, =signo_num2
   ldr r3, [r3]
   ldr r4, =num2
   ldr r4, [r4]
   bl complemento_a2
   mov r2, r4
   bl div
   ldr r1, =signo_num1
   ldr r1, [r1]
   ldr r2, =signo_num2
   ldr r2, [r2]
   eor r3, r1, r2
   bl resultado_negativo
   str r9,[r10] /*cargo el resultado en memoria*/
   pop {lr}
   bx lr
 .fnend
resultado_negativo:
 .fnstart
  push {lr}
  mov r4, r9
  bl complemento_a2
  mov r9, r4
  pop {lr}
  bx lr
 .fnend
div:
 .fnstart
  ciclo:
   add r9,#1 /*cociente +1*/
   sub r1,r2
   cmp r1,r2
   bge ciclo    /*si el divisor<=dividendo sigo en el ciclo*/
  bx lr
 .fnend

imprimir_resultado:
 .fnstart
   push {lr}
   ldr r2,=long_msj_resultado
   ldr r1,=mensaje_resultado
   bl print
   eor r2,r2
   eor r1,r1
   bl resultado_toString
   eor r2,r2
   eor r1,r1
   ldr r2,=long_resultadoString
   ldr r1,=resultadoString
   bl print
   eor r2,r2
   eor r1,r1
   ldr r1, =enter
   ldr r2,=long_enter
   bl print
   pop {lr}
   bx lr
 .fnend

resultado_toString:
 .fnstart
   push {lr}
   ldr r4,=resultadoStringAlreves
   ldr r6,=long_resultadoStringAlreves
   mov r7,#0
   ldr r0,=resultado
   ldr r1,[r0] /*r1=valor del resultado*/
   mov r2,#10  /*Para convertir un número a ASCII, debe dividir el número por 10*/
   eor r5,r5
   divResultado:
	cmp r1,r2
	bge restarResultado
	bal continuarDivision
   restarResultado:
    sub r1,r2
	add r5,#1
	bal divResultado
   continuarDivision:
	cmp r5,r2
	mov r8,r1
	add r8,#0x30
	strb r8,[r4,+r7]
	add r7,#1
	mov r1,r5
	eor r5,r5
	bge divResultado
	add r1,#0x30
	strb r1,[r4,+r7]
	ldr r10,=resultadoString
	mov r7,#0
   escribir:
	 cmp r6,#0
	 blt exit_resultado_toString
	 ldrb r9,[r4,+r6]
	 cmp r9,#0x20
     bne anotar
	 sub r6,#1
	 b escribir
   anotar:
     strb r9,[r10,+r7]
	 add r7,#1
	 sub r6,#1
	 b escribir
   exit_resultado_toString:
   pop {lr}
   bx lr
 .fnend


print_mensaje_error:/*print mensaje de error*/
 .fnstart
   push {lr}
   ldr r1,=mensaje_error
   ldr r2,=long_error
   bl print
   pop {lr}
   bx lr
 .fnend

/*metodo es_salir en proceso de contruccion*/
es_salir:
 .fnstart
   push {lr}
   eor r5,r5
   eor r11,r11
   ldr r5,=input_usuario
   ldr r6,=long_input
   mov r3,#0 /*contador*/
   /*primer letra del imput*/
   ldrb r4,[r5,+r3]   /*si r4=a va a comparar si la proxima letra es d*/
   cmp r4,#0x61
   beq compararD /*con registro de desplazamiento*/
   bl print_mensaje_error
   b exit
 compararD:
   add r3,#1	/*incremento r3 para direc. relativo a registro*/
   ldrb r4,[r5,+r3]
   cmp r4,#0x64
   beq compararI
   bl print_mensaje_error /*Ya que el bot no tiene ninguna operacion que */
   /* sea 'a' seguido de otra letra, salto a mostrar el mensaje de error*/
   b exit /*si es distinto de adios sigue con el programa*/
 compararI:
   add r3,#1
   ldrb r4,[r5,+r3]
   cmp r4,#0x69
   beq compararO
   bl print_mensaje_error /*Ya que el bot no tiene ninguna operacion que sea 'ad'
   seguido de otra letra, salto a mostrar el mensaje de error*/
   b exit
 compararO:
   add r3,#1
   ldrb r4,[r5,+r3]
   cmp r4,#0x6f
   beq compararS
   bl print_mensaje_error /*Ya que el bot no tiene ninguna operacion que sea 'adi'
   seguido de otra letra, salto a mostrar el mensaje de error*/
   b exit
 compararS:
   add r3,#1
   ldrb r4,[r5,+r3]
   cmp r4,#0x73
   beq compararEnter
   bl print_mensaje_error /*Ya que el bot no tiene ninguna operacion que sea 'adio'
   seguido de otra letra, salto a mostrar el mensaje de error*/
   b exit
 compararEnter:
   add r3,#1
   ldrb r4,[r5,+r3]
   cmp r4,#0x0a /*LF*/
   beq salir
   bl print_mensaje_error
   b exit
 salir:
   ldr r1,=mensaje_despedida
   ldr r2,=long_despedida
   bl print
   mov r11,#1/*registro para salir del ciclo main*/
   b exit
 exit:
   pop {lr}
   bx lr
 .fnend


.global main
main:
	ldr r1,=saludoInicial
	ldr r2,=longSaludo
	bl print

ciclo_main:		/*ciclo main*/
	cmp r11,#1  /*r11 se setea en 1 en salir*/
	eq fin
	bl leer_input_usuario
	bl es_cuenta /*procesa el input del usuario*/
	bne ciclo_main
fin:
   mov r7,#1
   swi 0
