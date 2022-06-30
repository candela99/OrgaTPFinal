.data
  input_usuario: .asciz "     "
  long_input= . - input_usuario
  mensaje_error: .asciz "Lo siento, mis respuestas son limitadas \n"
  long_error= . - mensaje_error
  text_result: .asciz "##########"
  operacion: .byte 0
  vector_num1: .asciz "  "
  vector_num2: .asciz "  "
  num1: .int 0
  num2: .int 0
  resultado: .int 0
  resto: .int 0
  mensaje_despedida: .asciz "Adios! \n"
  saludoInicial: .asciz "Hola, soy C-3PO relaciones cibernetico-humanas. En que puedo servile? \n"
  longSaludo= . - saludoInicial
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
   ldr r1, =input_usuario /*r1 = puntero de input*/
   ldr r2, =long_input
   ldr r2, [r2] /*r2 = cantidad de caracteres*/
   swi 0
   bx lr
 .fnend
es_numero:
 .fnstart
   cmp r4, #0x39 /*compara r4 con 0x39, si es menor o igual, lo almacena, sino error*/ 
   ble almacenar_nro
   bl print_mensaje_error
 .fnend
almacenar_nro:
 .fnstart
   eor r7, r7
   subs r7, r4, #30
   strb r7, [r11] /*guarda el valor en el puntero a vector_numX*/
   add r11, #+1 /*r11 = puntero de vector_numX, lo actualiza en la sig posicion*/
   add r8, #1 /*incrementa el indice*/
   bl ciclo_num
 .fnend
es_cuenta:
 .fnstart
   ldr r3, =input_usuario
   ldr r9, =long_input
   ldr r9, [r9]
   mov r8, #1 /*r8 = indice*/
   mov r5, #0 /*r5 = va a almacenar el primer valor*/
   mov r6, #0 /*r6 = va a almacenar el segundo valor*/
   ldrb r4, [r3], #1 /*r4 = almacena el valor del caracter, r3 = puntero a input*/
   ldr r11, =vector_num1
   cmp r4, #0x2D /*compara si es negativo*/
   beq negativo 
   bl ciclo_num
   bl es_operacion /*tendria que comprobar si es una operacion valida*/
   eor r11, r11
   ldr r11, =vector_num2
   beq negativo
   bl ciclo_num
   bx lr /*vuelve a quien lo llamo, seria el main*/
 .fnend 
negativo: 
 .fnstart
   mov r1, #0x2D
   strb r1, [r11] /*r11 = puntero a vector_num1*/
   add r11, #+1
   ldrb r4, [r3], #+1 /*mueve el puntero de input 1 posicion*/
   add r8, #+1 /*incrementa el indice*/
   bx lr
 .fnend
ciclo_num:
 .fnstart
   cmp r8, r9 /*r9 = long_input, compara el indice con la long */
   bne es_espacio_o_num
   bx lr /*tendria que volver a es_cuenta*/
.fnend
es_espacio_o_num:
 .fnstart
   cmp r4, #0x30 /*compara r4 con 0x30*/
   bge es_numero
   cmp r4, #0x20 /*compara r4 con espacio*/
   bne print_mensaje_error /*si no es un nro ni espacio, imprimo msj de error*/
   add r8, #1 /*guardo en r8 el siguiente indice*/
   pop {lr}
   bx lr /*tendria que volver a es_cuenta*/
 .fnend
es_operacion:
 .fnstart
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
  pop {lr}
  bx lr /*tendria que volver a es_cuenta*/
 .fnend
resolver_operacion:
 .fnstart
   push {lr}
   ldrb r0,=operacion
   ldrb r0,[r0]
   ldr  r1,=num1  /*r0=operando de turno y lo compara con los ascii*/
   ldr  r1,[r1]   /*salta a la operacion a realizar si es igual o a error*/
   ldr  r2,=num2  /*r1 y r2 son los numeros*/
   ldr  r2,[r2]
   ldr  r10,=resultado /*r10=direccion donde se va a guardar el resultado*/
   mov  r9,#0     	   /*r9=resultado*/
   cmp r1,#0x2b
   beq suma
   cmp r1,#0x2d
   beq resta
   cmp r1,#0x2a
   beq multiplicacion
   cmp r1,#0x2f  /*r1/r2 r1=dividendo, r2=diviso*/
   ldr r3,=resto /*r3=direccion en memoria del resto*/
   beq division
   bne print_mensaje_error
   pop {lr}
 .fnend
suma:
   add r9,r1,r2
   str r9,[r10]
   bx lr
resta:
   sub r9,r1,r2
   str r9,[r10]
   bx lr
multiplicacion:
   mul r9,r1,r2
   str r9,[r10]
   bx lr
division:
   cmp r2,r1
   bls div
   bx lr
div:
   add r9,#1 /*cociente +1*/
   sub r1,r2
   cmp r2,r1
   bls div    /*si el divisor<=dividendo sigo en el ciclo*/
   str r9,[r10] /*cargo el resultado en memoria*/
   bx lr

print_mensaje_error:/*print mensaje de error*/
 .fnstart
   push {lr}
   ldr r1,=mensaje_error
   ldr r2,=long_error
   bl print
   pop {lr}
   bx lr
 .fnend
 
 
.global main
main:
	ldr r1,=saludoInicial
	ldr r2,=longSaludo
	bl print
	bl print_mensaje_error
fin:
   mov r7,#1
   swi 0
