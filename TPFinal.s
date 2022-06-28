.data
  input_usuario: .asciz "                            "
  long_input= . - input_usuario
  mensaje_error: "Lo siento, mis respuestas son limitadas \n"
  text_result: "##########"
  operacion: .byte 0
  num1: .int 0
  num2: .int 0
  resultado: .int 0
  resto: .int 0
  mensaje_despedida: "Adios! \n"
.text
.global main
leer_input_usuario:
 .fnstart
   mov r7, #3 /*ingreso standard output*/
   mov r0, #0 /*le indico al SO que va a ser una cadena*/
   ldr r1, =input_usuario /*r0 = puntero de input*/
   ldr r2, =long_input
   ldr r2, [r2] /*r2 = cantidad de caracteres*/
   swi 0 
   bx lr
 .fnend
es_numero:
 .fnstart
   ldrb r1, r3, #1 /*r1 = almacena el valor del caracter, r3 = puntero a input*/
   cmp r1, #30 
   bhe posibleNum
   cmp r1, #2D /*compara si es negativo, #2D = '-'*/
   beq negativo
 .fnend

