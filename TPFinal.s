.data
  input_usuario: .asciz "                            "
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
   ldrb r1, [r3], #1 /*r1 = almacena el valor del caracter, r3 = puntero a input*/
   cmp r1, #0x30 /*compara r1 con 0x30, si es mayor o igual salta a posibleNum*/ 
   bhe posibleNum
   cmp r1, #0x2D /*compara si es negativo, #2D = '-'*/
   beq negativo
   b print_mensaje_error /*si no es un nro ni negativo, imprimo msj de error*/
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
