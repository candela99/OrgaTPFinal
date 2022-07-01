.data
  input_usuario: .asciz "       "
  long_input = . - input_usuario
  mensaje_error: .asciz "Lo siento, mis respuestas son limitadas \n"
  long_error = . - mensaje_error
  text_result: .asciz "##########"
  operacion: .byte 0
  vector_num1: .asciz "  "
  long_vector_num1 = . - vector_num1
  vector_num2: .asciz "  "
  long_vector_num2 = . - vector_num2
  num1: .int 0
  num2: .int 0
  resultado: .int 0
  resto: .int 0
  mensaje_despedida: .asciz "Adios! \n"
  long_despedida = . - mensaje_despedida
  /*mensaje_test: .asciz "test! \n"*/
  saludoInicial: .asciz "Hola, soy C-3PO relaciones cibernetico-humanas. En que puedo servile? \n"
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
   mov r7, #3 /*ingreso standard output*/
   mov r0, #0 /*le indico al SO que va a ser una cadena*/
   ldr r2, =long_input  /*tamaño de la cadena a leer*/
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
   mov r5, #0 /*r5 = va a almacenar el primer valor*/
   mov r6, #0 /*r6 = va a almacenar el segundo valor*/
   ldrb r4, [r3, +r8] /*r4 = almacena el valor del caracter, r3 = puntero a input*/
   ldr r11, =vector_num1
   ldr r12, =long_vector_num1
   cmp r4, #0x2D /*compara si es negativo*/
   beq negativo 
   bl ciclo_num
   bl es_operacion /*tendria que comprobar si es una operacion valida*/
   eor r5, r5
   eor r11, r11
   ldr r11, =vector_num2
   eor r12, r12
   ldr r12, =long_vector_num2
   beq negativo
   bl ciclo_num
   pop {lr}
   bx lr /*vuelve a quien lo llamo, seria el main*/
 .fnend 
negativo: 
 .fnstart
   eor r1, r1
   mov r1, #0x2D
   strb r1, [r11, r5] /*r11 = puntero a vector_num1*/
   add r5, #+1 /*mueve el puntero de vector_num1 1 posicion*/
   add r8, #+1 /*incrementa el indice*/
   bx lr
 .fnend
ciclo_num:
 .fnstart
   cmp r5, r12 /*comparo puntero de vector_num con su long*/
   beq volver_a_es_cuenta
   cmp r8, r9 /*r9 = long_input, compara el indice con la long */
   blt es_espacio_o_num
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
   bne salirEs_cueta /*si no es un nro ni espacio, imprimo msj de error*/
   add r8, #1 /*guardo en r8 el siguiente indice*/
   bx lr /*tendria que volver a es_cuenta*/
 .fnend
 
es_numero:
 .fnstart
   cmp r4, #0x39 /*compara r4 con 0x39, si es menor o igual, lo almacena, sino error*/ 
   ble almacenar_nro
   bgt salirEs_cueta
   bx lr
 .fnend
salirEs_cueta:
	.fnstart
		bl es_salir
		pop {lr}
		bx lr
	.fnend
almacenar_nro:
 .fnstart
   eor r6, r6
   subs r6, r4, #0x30
   strb r6, [r11, r5] /*guarda el valor en el puntero a vector_numX*/
   add r5, #+1 /*r11 = puntero de vector_numX, lo actualiza en la sig posicion*/
   add r8, #+1 /*incrementa el indice*/
   bl ciclo_num
 .fnend 
 
es_operacion:
 .fnstart
   push {lr} /*guarda la direccion de retorno a es_cuenta*/
   ldrb r4, [r3, +r8] /*r4 = almacena el valor del caracter, r3 = puntero a input*/
   cmp r4, #0x2A /*compara si es una multiplicacion (*) */
   beq cargar_operacion
   cmp r4, #0x2B /*compara si es una suma (+) */
   beq cargar_operacion
   cmp r4, #0x2D /*compara si es una resta (-) */
   beq cargar_operacion
   cmp r4, #0x2F /*compara si es una division (/)*/
   beq cargar_operacion
   bl print_mensaje_error /*si no es ninguna de las op, devuelve error*/
 .fnend
cargar_operacion:
 .fnstart
  ldr r10, =operacion
  strb r4, [r10]
  add r8, #+1
  ldrb r4, [r3, r8] /*incrementa el puntero de input en una posicion*/
  pop {lr}
  bx lr /*tendria que volver a es_cuenta*/
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
   cmp r0,#0x2b
   beq suma
   cmp r0,#0x2d
   beq resta
   cmp r0,#0x2a
   beq multiplicacion
   ldr r3,=resto /*r3=direccion en memoria del resto*/
   cmp r0,#0x2f  /*r1/r2 r1=dividendo, r2=diviso*/
   beq division
   bx lr
 .fnend
suma:
 .fnstart
   add r9,r1,r2
   strb r9,[r10]
   pop {lr}
   bx lr
 .fnend
resta:
 .fnstart
   sub r9,r1,r2
   strb r9,[r10]
   pop {lr}
   bx lr
 .fnend
multiplicacion:
 .fnstart
   mul r9,r1,r2
   strb r9,[r10]
   pop {lr}
   bx lr
 .fnend
division:
 .fnstart
   cmp r2,r1
   bls div
   bx lr
 .fnend
div:
 .fnstart
   add r9,#1 /*cociente +1*/
   sub r1,r2
   cmp r2,r1
   bls div    /*si el divisor<=dividendo sigo en el ciclo*/
   strb r9,[r10] /*cargo el resultado en memoria*/
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
   eor r1,r1
   ldr r1,=input_usuario
   mov r3,#0 /*contador*/
   /*primer letra del imput*/
   ldrb r4,[r1,+r3]   /*si r4=a va a comparar si la proxima letra es d*/
   cmp r4,#0x61
   beq compararD /*con registro de desplazamiento*/
   bne print_mensaje_error
   pop {lr}
   bx lr
 .fnend

compararD:
 .fnstart
   add r3,#1	/*incremento r3 para direc. relativo a registro*/
   ldrb r4,[r1,+r3]
   cmp r4,#0x64
   beq compararI
   bne print_mensaje_error /*Ya que el bot no tiene ninguna operacion que */
   /* sea 'a' seguido de otra letra, salto a mostrar el mensaje de error*/
   bx lr /*si es distinto de adios sigue con el programa*/
 .fnend
compararI:
 .fnstart
   add r3,#1
   ldrb r4,[r1,+r3]
   cmp r4,#0x69
   beq compararO
   bne print_mensaje_error /*Ya que el bot no tiene ninguna operacion que sea 'ad'
   seguido de otra letra, salto a mostrar el mensaje de error*/
   bx lr
 .fnend
compararO:
 .fnstart
   add r3,#1
   ldrb r4,[r1,+r3]
   cmp r4,#0x6f
   beq compararS
   bne print_mensaje_error /*Ya que el bot no tiene ninguna operacion que sea 'adi'
   seguido de otra letra, salto a mostrar el mensaje de error*/
   bx lr
 .fnend
compararS:
 .fnstart
   add r3,#1
   ldrb r4,[r1,+r3]
   cmp r4,#0x73
   beq comparar00
   bne print_mensaje_error /*Ya que el bot no tiene ninguna operacion que sea 'adio'
   seguido de otra letra, salto a mostrar el mensaje de error*/
   bx lr
 .fnend
comparar00:
 .fnstart
   add r3,#1
   ldrb r4,[r1,+r3]
   cmp r4,#0x00
   beq salir  /*el programa termina*/
   cmp r4,#0x20
   beq salir
   bne print_mensaje_error /*Ya que el bot no tiene ninguna operacion que sea 'adios'
   seguido de otra letra, salto a mostrar el mensaje de error*/
   bx lr
 .fnend
salir:
   ldr r1,=mensaje_despedida
   ldr r2,=long_despedida
   bl print
   b fin

.global main
main:
	ldr r1,=saludoInicial
	ldr r2,=longSaludo
	bl print
    	bl leer_input_usuario
	/*ldr r2,=long_input
	ldr r1,=input_usuario
	bl print*/
    	bl es_cuenta
	/*ldr r1,=resultado
	bl print
	bl print
	bl es_salir*/
fin:
   mov r7,#1
   swi 0
