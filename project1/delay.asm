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
   ;Obtain the delayCount value set from setDelay and put it into register X
   LDX delayCount


loop_delay_count:
   XGDX ; Switch X <-> D, D will now contain the delayCount
   LDX #3000
loop_1_ms:
   NOP
   NOP
   NOP
   NOP
   DEX ; Decrement #3000
   BNE loop_1_ms ; Loop to loop_1_ms if not equal to zero
   XGDX ; Switch D <-> X, X will now contain the delayCount
   DEX ; Decrement delayCount
   BNE loop_delay_count ; Loop to loop_delay_count if not equal to zero

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
