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
setDelay: 

	; Complete this subroutine
	STD delayCount ;Put the value in D into globalVar::delayCount
	rts ;Branch back out


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
; Stack Usage:
	OFFSET 0  ; to setup offset into stack
PDLY_VARSIZE:
PDLY_PR_Y   DS.W 1 ; preserve Y
PDLY_PR_X   DS.W 1 ; preserve X
PDLY_PR_B   DS.B 1 ; preserve B
PDLY_RA     DS.W 1 ; return address

;------NOTE---------
; polldelay begins by storing the values from b,x,y to the stack.
; then perform a set of instructions that will take x seconds of processing time
; then pull back the values of b,x,y from the stack.
;-------------------
polldelay: pshb
   pshx
   pshy

   ; Complete this routine
   
   LDX delayCount ;Obtain the delayCount value set from setDelay and put it into register X

loop_delay_count:
   ;----------------------------------
   ; We swap the content in X (contains delayCount --> contains whatever) and D (contains whatever --> contains delayCount)
   ;----------------------------------

   XGDX ; Switch X <-> D
   LDX #3000 ; Load a static value 3000 into register X. This is how many times the program will loop to be inactive for 1 ms.
loop_1_ms:
   DEX ; Decrement value in register X
   BEQ loop_1_ms ; If the decrement instruction from before does not result in 0 value, then BNE( branch if not equal to 0) to loop_1_ms, which will decrement it again.
   ;----------------------------------
   ; We swap the content in X (contains 0 --> contains delayCount) and D (contains delayCount--> contains 0)
   ;----------------------------------
   XGDX ; Switch X <-> D
   DEX
   BNE loop_delay_count


   ; restore registers and stack
   puly
   pulx
   pulb
   rts





;------------------------------------------------------
; Global variables
;------------------------------------------------------
   switch globalVar
delayCount ds.w 1   ; 2 byte delay counter
