;------------------------------------------------------
; Alarm System Simulation Assembler Program
; File: delay.asm
; Description: The Delay Module
; Author: Gilbert Arbez
; Date: Fall 2010
;------------------------------------------------------

; Some definitions
    SWITCH code_section

;------------------------------------------------------
; Subroutine setDelay
; Parameters: cnt - accumulator D
; Returns: nothing
; Global Variables: delayCount
; Description: Intialises the delayCount 
;              variable.
;------------------------------------------------------
;-- This subroutine does not use local variables so no stack is needed
setDelay:
	  STD       delayCount
    rts


;------------------------------------------------------
; Subroutine: polldelay
; Parameters:  none
; Returns: TRUE when delay counter reaches 0 - in accumulator A
; Local Variables
;   retval - acc A cntr - X register
; Global Variables:
;      delayCount
; Description: The subroutine delays for 1 ms, decrements delayCount.
;              If delayCount is zero, return TRUE; FALSE otherwise.
;   Core Clock is set to 24 MHz, so 1 cycle is 41 2/3 ns
;   NOP takes up 1 cycle, thus 41 2/3 ns
;   Need 24 cyles to create 1 microsecond delay
;   8 cycles creates a 333 1/3 nano delay
;	DEX - 1 cycle
;	BNE - 3 cyles - when branch is taken
;	Need 4 NOP
;   Run Loop 3000 times to create a 1 ms delay   
;------------------------------------------------------
;-- This subroutine does not use local variables so no stack is needed

polldelay: pshb
   	pshx
   	pshy

   	;-- Obtain the delayCount value set from setDelay and put it into register X
    LDX			delayCount
   	LDAA 		#FALSE
   	LDY 		#3000

polldelay_main:
   	NOP
   	NOP
   	NOP
   	NOP

   	;-- A usual loop function, decrement #3000 by 1 and loop back to polldelay_main until its 0
   	DEY
   	BNE 		polldelay_main

   	;-- Decrement delayCount (in X) and check if its zero. If its zero, that means that the loop finished counting. I
   	;-- If its not, that means that while counting, something is interrupting the process (??)
   	DEX
   	BNE 		polldelay_end_loop
   	LDAA 		#TRUE;

polldelay_end_loop:
   	;-- restore registers and stack
   	puly
   	pulx
   	pulb
   	rts


;------------------------------------------------------
; Subroutine delayms
; Parameters: num - accumulator D
; Returns: nothing
; Global Variables: 
; Description: Set delay for num ms
;------------------------------------------------------
;-- This subroutine does not use local variables so no stack is needed
delayms:
	  ;-- Initialize our delayCounter to be whatever value this function is given in D
	  JSR 		setDelay
    JSR 		polldelay
  	
  	;-- Test if AC A is zero, if it is is, then skip BNE, if it is then BNE back and request a pollDelay again.
  	;-- AC A should content the boolean returned from pollDelay during this sequence.
   	TSTA
   	BNE 		delayms
   	rts


;------------------------------------------------------
; Global variables
;------------------------------------------------------
   switch globalVar
delayCount ds.w 1   ; 2 byte delay counter
