z;----------------------------------------------------------------------
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
BADCODE 	EQU		$FF 		; returned of translation is unsuccessful
NOKEY		EQU 		$00   		; No key pressed during poll period
POLLCOUNT	EQU		1		; Number of loops to create 1 ms poll time

 SWITCH globalConst  ; Constant data

 ; codes for scanning keyboard

ROW1 EQU %11101111
ROW2 EQU %11011111
ROW3 EQU %10111111
ROW4 EQU %01111111

; defnitions for structure cnvTbl_struct
 OFFSET 0
cnvTbl_code ds.b 1
cnvTbl_ascii  ds.b 1
cnvTbl_struct_len EQU *

; Conversion Table
cnvTbl  dc.b %11101110,'1'
	dc.b %11101101,'2'
	dc.b %11101011,'3'
	dc.b %11100111,'a'
	dc.b %11011110,'4'
	dc.b %11011101,'5'
	dc.b %11011011,'6'
	dc.b %11010111,'b'
	dc.b %10111110,'7'
	dc.b %10111101,'8'
	dc.b %10111011,'9'
	dc.b %10110111,'c'
	dc.b %01111110,'*'
	dc.b %01111101,'0'
	dc.b %01111011,'#'
	dc.b %01110111,'d'

 SWITCH code_section  ; place in code section
;-----------------------------------------------------------	
; Subroutine: initKeyPad
;
; Description: 
; 	Initiliases PORT A
;-----------------------------------------------------------	
initKeyPad:
	
	;-- Set the DDRA and PUCR to enable input from the board
	MOVB 	#$f0, 	DDRA ;-- readies porta to be read
	MOVB 	#$01, 	PUCR ;-- clears any values in porta
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
; This routine does not require any local variable (no stack usage)


pollReadKey: PSHX
	
	;-- The amount of time to loop, depending on the length of our loop cycle, set POLLCOUNT
	;-- appropriately to cause 1ms delay.
	LDX 	#POLLCOUNT

	;-- Set PORTA to default value of $0F
	MOVB 	#$0F, PORTA

pollReadKey_check_difference:

	;-- Load the value of PORTA into AC B
	LDAB 	PORTA
	
	;-- Compare the value of PORTA( now in AC B) with #$0F
	CMPB 	#$0F
	
	;-- If equal it means no difference then we go to loop_check_difference_end to 
	;-- decrement POLLCOUNT and try again
	BEQ 	pollReadkey_decrement_POLLCOUNT
	
	;-- Else, prepare to delay for 1 ms to check for debouncing
	LDD 	#1
	JSR 	delayms

;-- Check if PORTA is still not equal to $0F.
;-- If it is equal, then that means that it was just an anomaly. We decrement POLLCOUNT and try again until 
;-- polllcount is zero, then we return NOKEY if we continue to fail.
;-- If it is NOT equal, then we pass the debouncing test. We will now let readKey to read the input.
;-- After readKey routine is finished,
pollReadKey_check_after_debouncing:
	LDAB 	PORTA;
	CMPB	#$0F
	BEQ pollReadkey_decrement_POLLCOUNT

	;-- If the value in PORTA is not #$0F, meaning that it is in 
	;-- fact a key press (and not some random anomaly) then we
	;-- go to readkey to evaluate the actual value of the key
	JSR readkey

	;-- Restore value of REG X
	PULX
	RTS ;-- return from pollReadKey

;-- Decrement POLLCOUNT.
;-- If POLLCOUNT is zero then return NOKEY (by putting it in AC B) and exit subroutine.
;-- Else return with whatever the value obtained from readKey and exit subroutine
pollReadkey_decrement_POLLCOUNT:
	DEX
	BNE pollReadKey_check_difference
	LDAB NOKEY
	PULX
	RTS ;-- return from pollReadKey

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
	OFFSET 0  ; to setup offset into stack
READKEY_CODE       DS.B 1 ; code variable
READKEY_VARSIZE    DS.B 1 ; Preseserve A
READKEY_RA         DS.W 1 ; return address

;-- push AC A because we are going to use it in this subroutine
readKey:psha

	;-- Reserve stack space for our local variables
    LEAS 	-READKEY_VARSIZE,	SP

;-- Readkey_main is a reference to beginning to the module where we will set PORTA to the default value and 
;-- see if anything changes (possibly under the same assumption that the keypress will keep overwriting the value in PORTA(??).
;-- 

readkey_main

	;-- Set PORTA to the default value of $0F
    MOVB 	$0F,			PORTA

;-- While PORTA == 0x0F, we will continue to loop indefinitely. This is probably not a good idea in general (?). 
;-- But won't necessarily cause any hickups, the user just have to press the keypad and it will exit this infinite loop.
;-- Else it will continue to perform the same check that we see in pollReadKey but this time it is not checking for 
;-- debouncing (?) and delays for a lot longer (10ms). Instead of checking if PORTA is the same as the default value, 
;-- this one checks if the (old_keypress) is the same as the (new_keypress). If the value in PORTA is the 
;-- same as the one obtained from before then we will proceed to call the subroutine to translate this value and 
;-- convert it into ASCII(hexadecimal) value.
readkey_obtain_value_from_PORTA:
    LDAB 	PORTA
    CMPB 	#$0F
    BEQ 	readkey_obtain_value_from_PORTA

    ;-- Since we have exited the readkey_obtain_value_from_PORTA loop, we are now under the assumption that something changed in PORTA, 
    ;-- we will now delay for 10ms before checking again to see if we have the same value as before. Before we
    ;-- do that, we store the value obtained from PORTA into the variable READKEY_CODE (which is in the stack).
    MOVB 	PORTA,			READKEY_CODE,	SP
    LDD 	#10
    JSR 	delayms

    ;-- Get and compare the new content PORTA after the 10ms delay. If the resulting substraction (which is how CMPB works) is not equal to zero (hence we are using BNE)
    ;-- then the program will loop back to readkey_main and perform the same check as before again. We go back to readkey_main because there could 
    ;-- be something weird that caused the input to change during the 10ms delay and let the user try again. Even better, if the user's hand is slow enough, 
    ;-- this is just reducing the probability that the hardware messes up.
    LDAB 	PORTA
    CMPB 	READKEY_CODE,	SP
    BNE 	readkey_main

    ;-- Since we have confirmed that the value in PORTA is indeed consistent for some time, we can guarantee that this is indeed a keypress. 
    ;-- Call the keypress subsroutine to parse the value in PORTA. The subsroutine keyPress will store the return value in B, we then put this 
    ;-- value in the variable for this subsroutine.
    JSR 	keyPress
    STAB 	READKEY_CODE,	SP

;-- To ensure that the processing of the keypad press is only evaluated AFTER the user have released the key, we perform an infinite loop 
;-- that will only be broken when the value in PORTA is equal to the default value that is set in the beginning of that infinite loop. To ensure that the user have indeed released the key,
;-- we will introduce a delay of 10ms (the debouncing time) into the infinite loop. This will likely cause a slow program, but its better than having a buggy program.
;--
;-- ________________ISSUES___________________:
;-- If the value in PORTA is being continuously updated indefinitely, the program will get stuck here and there is no recovering from this error.
readkey_check_release_key:
    MOVB 	#$0F,			PORTA

    ;-- Call delayms subroutine to delay for 10ms
    LDD 	#10
    JSR 	delayms

    ;-- Check if the value that we have set into PORTA is still 0x0F.
    ;-- If it is not equal to 0x0F, then the user is still pressing the key and PORTA is still being overwritten by that.
    LDAB 	PORTA
    CMPB 	#$0F
    BNE 	readkey_check_release_key

    ;-- Load the value that we obtained from keyPress and put it into AC B to be translated by the translate_keypad subroutine.
    LDAB 	READKEY_CODE,SP
    JSR 	translate_keypad

    ;-- Recover the stack memory that this subroutine uses.
    LEAS 	READKEY_VARSIZE,SP
    PULA
    RTS

;-----------------------------------------------------------	
; Subroutine: key <- keyPress       
; Arguments: none
; Local variables:  key: Accumulator B
; Returns: key - in Accumulator B - code corresponding to key pressed

; Description: Assume key is pressed. Set 0 on each output pin
;              to find row and hence code for the key.
;-----------------------------------------------------------	
; Stack Usage: none

keyPress: 
         movb #ROW1,PORTA  ; PORTA = ROW1;
kpIf1  ldab PORTA          ; if(PORTA == ROW1) // input pin is 0 if key in row 1
         cmpb #ROW1
         bne kpEndIf1      ; {
         movb #ROW2,PORTA  ;   PORTA = ROW2
kpIf2  ldab PORTA          ;   if(PORTA == ROW2)
         cmpb #ROW2
         bne kpEndIf2      ;   {
         movb #ROW3,PORTA  ;      PORTA = ROW3;
kpIf3  ldab PORTA          ;      if(PORTA == ROW3)
         cmpb #ROW3        ;        {
         bne kpEndIf3      ;          PORTA = ROW4;
         movb #ROW4,PORTA  ;        }
kpEndIf1 		   ;   }
kpEndIf2 
kpEndIf3                                                    
                           ; }
         ldab PORTA        ; key = PORTA;
         rts               ; return(key);
	      
;-----------------------------------------------------------	
; Subroutine:  ch <- translate_keypad(code)
; Arguments
;	code - in Acc B - code read from keypad port
; Returns
;	ch - saved on stack but returned in Acc B - ASCII code
; Local Variables
;    	ptr - in register X - pointer to the table
;	count - counter for loop in accumulator A
; Description:
;   translate the code by using the conversion table
;   searching for the code.  If not found, then BADCODE
;   is returned.
;-----------------------------------------------------------	
; Stack Usage:
   OFFSET 0
TR_CH DS.B 1  ; for ch 
TR_PR_A DS.B 1 ; preserved regiters A
TR_PR_X DS.B 1 ; preserved regiters X
TR_RA DS.W 1 ; return address

translate_keypad: psha
	pshx	; preserve registers
	leas -1,SP 		    ; byte chascii;
	ldx #cnvTbl		    ; ptr = cnvTbl;
	clra			    ; ix = 0;
	movb #BADCODE,TR_CH,SP      ; ch = BADCODE;

tLop: 			            ; do {
	cmpb cnvTbl_code,X  	    ;     if(code == ptr->code)
	bne tEndIf  	            ;     {
	movb cnvTbl_ascii,X,TR_CH,SP ;        ch <- [ptr+1]
	bra tEndLop  		    ;         break;
tEndIf:  			    ;     }
				    ;     else {	
	leax cnvTbl_struct_len,X    ;           ptr++;
	inca ; increment count      ;           ix++;
                                    ;     }	
	cmpa #NUMKEYS               ;} while count < NUMKEYS
	blo tLop	
tEndLop:                            
	; restore registres
	pulb 	
	pulx
	pula
	rts



