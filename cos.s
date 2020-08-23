@*************************************************************************************************************************  
@ SWI commands
@ Note: all the commands correspond to SWI Legacy.
@ Make sure to activate the Legacy (not the Angel) plugin in Plugin section of ARMSim.
@ To calculate the cosine, we will work in float32 most of the time. Still, it is not posible to print out a float32, so
@ to print a value on screen first we print out the whole-number part, then a decimal point symbol and then decimal
@ digits, one by one (up to 3 digits).
@************************************************************************************************************************* 

    .equ Print_Chr, 0x00
    .equ Exit, 0x11
    .equ Open, 0x66
    .equ Close, 0x68
    .equ PrStr, 0x69       
    .equ Write_Int, 0x6B
    .equ Read_Int, 0x6C
    .equ Stdout, 1          

.data
    .align 
    sexagesimal: .float 0.01745329252   @ pi/180, degree to radian conversion factor
    first_order: .float 0.5             @ 1/2!
    second_order: .float 0.0416666666   @ 1/4!
    third_order: .float 0.00138888888   @ 1/6!
    one: .float 1.0
    minus_one: .float -1.0
    decimals : .float 10
    zero: .float 0.0
    filename: .asciz "input.txt"    	@ the input archive to read from
    msg1: .asciz  "Cosine of an angle of "  
    msg2: .asciz  " degrees is (precision up to .001): " 
    dot: .asciz "."                  	@ decimal point symbol to print out the cos(x)
    minus: .asciz "-"

.text

@*************************************************************************************************************************  
@ High level equivalent: printf("Cosine of an angle of " );
@*************************************************************************************************************************

mov r0,#Stdout                      @ mode: on screen
ldr r1, =msg1                       @ saves the direction of the label that contains the message
swi PrStr                           @ and prints it out on the screen

@*************************************************************************************************************************  
@ Open the input.txt and read the first line, which contains the value of an angle x (in degrees).
@************************************************************************************************************************* 

START:
    ldr r0, =filename               @ se guarda el nombre de archivo a leer
    mov r1, #0                      @ en modo lectura
    swi Open                        @ open the archive
    mov r2, r0
    swi Read_Int                    @ execute the syscall to read the value

    mov r1, r0                      @ r1 contains the read value just to print it out
    mov r0, #Stdout                 @ on screen
    swi Write_Int                  
    mov r10, r1

    ldr r2, =sexagesimal            @ all the constants from .data section are assigned to their
    ldr r2, =sexagesimal            @ respective register to use them in taylor series expansion function
    ldr r3, =first_order
    ldr r4, =second_order
    ldr r5, =third_order

@*************************************************************************************************************************  
@ High level equivalent:  printf(" degrees is (precision up to .001): ");
@*************************************************************************************************************************  

mov r0,#Stdout                      @ mode: on screen
ldr r1, =msg2                       @ saves the direction of the label that contains the message
swi PrStr                           @ and prints it out on the screen

@*************************************************************************************************************************  
@ Convert the original angle from degrees (sexagesimal system) to radians.
@*************************************************************************************************************************  

TO_RADIANS:
    vldr s2, [r2]                   @ move convertion factor (from degrees to radians) to float32 register s2
    vmov s0, r10                    @ r10 contains the value of an angle in degrees, vmov saves it as float32 in s0
    vcvt.f32.u32 s0, s0             
    vmul.f32 s0, s0, s2             @ s0 =  pi/180 * s0 - convertion to float32 radian angle value
   

@*************************************************************************************************************************  
@ To calculate the value of cos(x), where x is the angle in radianes we will use the Taylor Series expansion (partial).
@ That is: cos(x) = 1 - x^2/2! + x^4/4! - x^6/6!
@ Range: de 0 a 180 in sexagesimal numeric system (degree).
@*************************************************************************************************************************  

TAYLOR_SERIES:
    vmul.f32 s1, s0, s0             @ x^2
    vmul.f32 s2, s1, s1             @ x^4
    vmul.f32 s3, s2, s1             @ x^6

    vldr s4, [r3]
    vmul.f32 s1, s1, s4             @ x^2/2!

    
    vldr s4, [r4]
    vmul.f32 s2, s2, s4             @ x^4/4!

   
    vldr s4, [r5]
    vmul.f32 s3, s3, s4             @ x^6/6!

    ldr r0, =one
    vldr s6, [r0]					@ s5 will contain the final result of series expansion
    vsub.f32 s5, s6, s1             @ s5 = 1 - x^2/2!
    vadd.f32 s5, s5, s2             @ s5 = 1 - x^2/2! + x^4/4!
    vsub.f32 s5, s5, s3             @ s5 = 1 - x^2/2! + x^4/4! - x^6/6!
    b PRINT_FLOAT 


PRINT_FLOAT:
    vcvt.u32.f32 s1, s5             @ converts float32 s5 (result) to int and saves it in s1
    vmov.f32 r1, s1                 @ save the value in r1 (r1 now contains the whole-number part)
    mov r0, #Stdout                 @ mode: on screen
    swi Write_Int                   @ prints out the whole-number part

    ldr r1, =dot                    @ saves the direction of decimal point constant
    swi PrStr                       @ prints out a decimal point on screen

    vsub.f32 s5, s5, s1
    mov r6, #0                      @ r6 is the counter
    ldr r2, =decimals               @ <decimals> is the multiplication factor (equials to 10) to get 1 decimal space at a time
    vldr s6, [r2]                   @ it should be converted to float32 to be able to execute vmul operation


LOOP: 
    cmp r6, #3                      @ while count != 3 (precision up to 3 decimals)
    beq DONE                        @ if count == 3 -> exit the LOOP.
    vmul.f32 s5, s5, s6             @ we assume that precision up to 3 decimal == truncate on 3rd decimal
    vcvt.u32.f32 s1, s5             @ converts float32 s5 (result) to int and saves it in s1
    vmov.f32 r1, s1                 @ r1 now contains value to print out
    mov r0, #Stdout                 @ mode: on screen
    swi Write_Int                   @ prints out the decimal as integer
    vcvt.f32.u32 s1, s1
    vsub.f32 s5, s5, s1 
    add r6, r6, #1                  @ count += 1            
    B LOOP                          @ loop 3 times to print only 3 decimals

DONE:
    .end
