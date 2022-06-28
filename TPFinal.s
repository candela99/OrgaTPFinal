.data
  input_usuario: .asciz "     "
  long_input= . - input_usuario
  mensaje_error: "Lo siento, mis respuestas son limitadas \n"
  long_error= . - mensaje_error
  text_result: "##########"
  operacion: .byte 0
  num1: .int 0
  num2: .int 0
  resultado: .int 0
  resto: .int 0
  mensaje_despedida: "Adios! \n"

.text
.leer_input_usuario:
 .fnstart
   mov r7, #3 /*ingreso standard output*/
   mov r0, #0 /*le indico al SO que va a ser una cadena*/
   ldr r1, =input_usuario /*r1 = puntero de input*/
   ldr r2, =long_input
   ldr r2, [r2] /*r2 = cantidad de caracteres*/
   swi 0
   bx lr
 .fnend
.es_numero:
 .fnstart
   cmp r4, #0x39 /*compara r4 con 0x39, si es menor o igual, lo almacena, sino error*/ 
   ble almacenar_nro
   bl print_mensaje_error
 .fnend
.es_cuenta:
 .fnstart
   ldr r3, =input_usuario
   ldr r9, =long_input
   ldr r9, [r9]
   mov r8, #1 /*r8 = indice*/
   mov r5, #0 /*r5 = va a almacenar el primer valor*/
   mov r6, #0 /*r6 = va a almacenar el segundo valor*/
   ldrb r4, [r3], #1 /*r4 = almacena el valor del caracter, r3 = puntero a input*/
   cmp r4, #0x2D /*compara si es negativo*/
   beq negativo 
   bl ciclo_num
   bl es_operacion /*tendria que comprobar si es una operacion valida*/
   bl ciclo_num
   bx lr /*vuelve a quien lo llamo, seria el main*/
 .fnend 
.ciclo_num:
 .fnstart
   cmp r8, r9 /*r9 = long_input, compara el indice con la long */
   beq lr /*tendria que volver a es_cuenta*/
   add r8, #1 /*guardo en r8 el siguiente indice*/
   cmp r4, #0x30 /*compara r4 con 0x30*/
   bhe es_numero
   cmp r4, #0x20 /*compara r4 con espacio*/
   beq lr /*tendria que volver a es_cuenta*/
   b print_mensaje_error /*si no es un nro ni espacio, imprimo msj de error*/
 .fnend
.es_operacion:
 .fnstart
   cmp r4, #0x2A /*compara si es una multiplicacion (*) */
   beq cargar_operacion
   cmp r4, #0x2B /*compara si es una suma (+) */
   beq cargar_operacion
   cmp r4, #0x2D /*compara si es una resta (-) */
   beq cargar_operacion
   cmp r4, #0x2F /*compara si es una division (/)*/
   beq cargar_operacion
   bl imprimir_mensaje_error /*si no es ninguna de las op, devuelve error*/
 .fnend
.resolver_operacion:
 .fnstart
   push {lr}
   ldrb r0,=operacion
   ldrb r0,[r0]
   ldr  r1,=num1  /*r0=operando de turno y lo compara con los ascii*/
   ldr  r1,[r1]   /*salta a la operacion a realizar si es igual o a error*/
   ldr  r2,=num2  /*r1 y r2 son los numeros*/
   ldr  r2,[r2]
   cmp r1,#0x2b
   beq suma
   cmp r1,#0x2d
   beq resta
   cmp r1,#0x2a
   beq multiplicacion
   cmp r1,#0x2f
   beq division
   bne mensaje_error
   pop {lr}
 .fnend
.suma:
.resta:
.multiplicacion:
.division:



.print_mensaje_error:/*print mensaje de error*/
 .fnstart
   push {lr}
   ldrb r1,=mensaje_error
   ldr  r2,=long_error
   mov r7,#4
   mov r0,#1
   swi 0
   bx lr
   pop {lr}
 .fnend
.global main
main:
	bl mensaje_error
fin:
   mov r7,#1
   swi 0
