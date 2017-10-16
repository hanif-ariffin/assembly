;----------------------------------------------------------------------
; File: Keypad.asm
; Author:

; Description:
;  This contains the code for reading the
;  16-key keypad attached to Port A
;  See the schematic of the connection in the
;  design document.
;
;  The following subroutines are provided by the module
;
; char pollReadKey(): to poll keypad for a keypress
;                 Checks keypad for 2 ms for a keypress, and
;                 returns NOKEY if no keypress is found, otherwise
;                 the value returned will correspond to the
;                 ASCII code for the key, i.e. 0-9, *, # and A-D
; void initkey(): Initialises Port A for the keypad
;
; char readKey(): to read the key on the keypad
;                 The value returned will correspond to the
;                 ASCII code for the key, i.e. 0-9, *, # and A-D
;---------------------------------------------------------------------

; Include header files
 include 	"sections.inc"
 include 	"reg9s12.inc"  ; Defines EQU's for Peripheral Ports
 include 	"delay.inc"

**************EQUATES**********


;-----Conversion table
NUMKEYS		EQU		16		; Number of keys on the keypad
BADCODE 	EQU		$FF 	; returned of translation is unsuccessful
NOKEY		EQU 	$00   	; No key pressed during poll period
POLLCOUNT	EQU		1     	; Number of loops to create 1 ms poll time

 SWITCH globalConst  ; Constant data



 SWITCH code_section  ; place in code section
;-----------------------------------------------------------	
; Subroutine: initKeyPad
;
; Description: 
; 	Initiliases PORT A
;-----------------------------------------------------------	
initKeyPad:
	movb #$00, PORTA ;-- clears any values in porta
	movb #$00, DDRA ;-- readies porta to be read
	rts

;-----------------------------------------------------------    
; Subroutine: ch <- pollReadKey
; Parameters: none
; Local variable:
; Returns
;       ch: NOKEY when no key pressed,
;       otherwise, ASCII Code in accumulator B

; Description:
;  Loops for a period of 2ms, checking to see if
;  key is pressed. Calls readKey to read key if keypress 
;  detected (and debounced) on Port A and get ASCII code for
;  key pressed.
;-----------------------------------------------------------
; Stack Usage
;-- OFFSET 0  ; to setup offset into stack

pollReadKey: 
	
	lbne 	readKey
	pshb
   pshx
   pshy

   ; Complete this routine
   ;Obtain the delayCount value set from setDelay and put it into register X
   LDX delayCount


loop_delay_count:
   ;-- XGDX ; Switch X <-> D, D will now contain the delayCount
   LDY #3000
loop_1_ms:
   NOP
   NOP
   NOP
   NOP
   DEY ; Decrement #3000
   BNE loop_1_ms ; Loop to loop_1_ms if not equal to zero
   ;-- XGDX ;  Switch D <-> X, X will now contain the delayCount
   DEX ; Decrement delayCount
   BNE loop_delay_count ; Loop to loop_delay_count if not equal to zero
   LDAA #TRUE;
   ; restore registers and stack
   puly
   pulx
   pulb
   rts

;-----------------------------------------------------------	
; Subroutine: ch <- readKey
; Arguments: none
; Local variable: 
;	ch - ASCII Code in accumulator B

; Description:
;  Main subroutine that reads a code from the
;  keyboard using the subroutine readKeybrd.  The
;  code is then translated with the subroutine
;  translate to get the corresponding ASCII code.
;-----------------------------------------------------------	
; Stack Usage
;-- OFFSET 0  ; to setup offset into stack

maskr		equ 	0
maskc		equ 	1
column		equ 	2
row 		equ 	3

readKey:
getKey:
	leas	-4,SP
	movb	#$F0,DDRA
gkloope:	
	clr		row,SP
	movb	#$EF,maskr,SP
nextR:
	clr		column,SP
	movb	#$01,maskc,SP
	movb	#$FF,porta
	ldaa	maskr,SP
	anda	porta
	staa	porta
gkloopi:
	ldaa	maskc,SP
	anda	porta
	beq		debnce
next: 	
	ldaa	#3
	cmpa	column,SP
	blo		inc_col
	ldaa	#3
	cmpa	row,SP
	blo		inc_row
	bra		gkloope
inc_col:	
	inc 	column,SP
	lsl		maskc,SP
	bra		gkloopi
inc_row:	
	inc 	row,SP
	lsl		maskr,SP
	bset	maskr,SP,$01
	bra		nextR
debnce: 	
	ldd		#10
	jsr		delayms
	ldaa	maskc,SP
	anda	porta
	beq		getcode
	bra		next
getcode:	
	ldaa	row,SP
	lsla
	lsla
	adda	column,SP
	cmpa	#10
	blo		isdeci
	adda	#$37
	leas	4,SP
	rts
isdeci:	
	leas	4,SP
	adda	#$30
	rts



