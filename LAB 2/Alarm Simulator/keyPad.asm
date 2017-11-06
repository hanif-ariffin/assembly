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
	movb #$f0, DDRA ;-- readies porta to be read
	movb #$01, PUCR ;-- clears any values in porta
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
	OFFSET 0  ; to setup offset into stack
POLLREADKEY_CH         DS.B 1 ; return value, ASCII code
POLLREADKEY_VARSIZE:
POLLREADKEY_PR_X       DS.W 1 ; preserve X
POLLREADKEY_RA         DS.W 1 ; return address


pollReadKey: PSHX
	LEAS -POLLREADKEY_VARSIZE, SP
	;-- Put the default return value of #NOKEY into POLLREADKEY_CH.
	;-- We dont immediately put it at AC B because we are going to 
	;-- need it to evaluate PORTA.
	MOVB 	#NOKEY, POLLREADKEY_CH, SP
	
	;-- The amount of time to loop, depending on the length of our loop cycle, set POLLCOUNT
	;-- appropriately to cause 1ms delay.
	LDX 	#POLLCOUNT

	;-- Set PORTA to default value of $0F
	MOVB 	#$0F, PORTA

pollReadKey_main:
pollReadKey_check_difference:
	;-- Load the value of PORTA into AC B
	LDAB 	PORTA
	
	;-- Compare the value of PORTA( now in AC B) with #$0F
	CMPB 	#$0F
	
	;-- If equal it means no difference.
	;-- We go to loop_check_difference_end to decrement POLLCOUNT and try again
	BEQ 	pollReadKey_check_difference_end
	
	;-- Else, prepare to delay for 1 ms to check for debouncing
	LDD 	#1
	JSR 	delayms

	;-- Check if PORTA still not equal, put ch the value of 
	;-- readkey, then break to outside of main loop
pollReadKey_check_after_debouncing
	LDAB 	PORTA;
	CMPB	#$0F
	BEQ pollReadKey_check_difference_end

	;-- If the value in PORTA is not #$0F, meaning that it is in 
	;-- fact a key press (and not some random anomaly) then we
	;-- go to readkey to evaluate the actual value of the key
	JSR readkey

	;-- Since the return value from readkey is stored in AC B, we 
	;-- store this value in our stack
	STAB POLLREADKEY_CH, SP ;-- Possibly redundant?
	BRA pollReadKey_main_end
pollReadKey_check_difference_end:
	DEX
	BNE pollReadKey_main
pollReadKey_main_end:
	;-- Retrieve the value that we stored in the stack into AC B, which 
	;-- is the return register for this function
	LDAB POLLREADKEY_CH, SP ;-- Possibly redundant?

	;-- Restore stack memory
	LEAS POLLREADKEY_VARSIZE, SP

	;-- Restore value of REG X
	PULX
	RTS

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
RDK_CODE       DS.B 1 ; code variable
RDK_VARSIZE    DS.B 1 ; Preseserve A
RDK_RA         DS.W 1 ; return address

readKey:psha		; byte code;	
    leas -RDK_VARSIZE,SP 
rkDo                     ; do	           ; {
    movb $0F,PORTA         ;    PORTA = 0x0F;
rkLop1:
    ldab PORTA         ;    while(PORTA==0x0F) 
    cmpb #$0F
    beq rkLop1
    movb PORTA,RDK_CODE,SP ;    code = PORTA
    ldd #10
    jsr delayms	           ;    delayms(10);
    ldab PORTA	           ; } while(code != PORTA); 
    cmpb RDK_CODE,SP
    bne rkDo
    jsr keyPress       ; code = readKeyCode();  // get the keycode
    stab RDK_CODE,SP
    movb #$0F,PORTA        ; PORTA = 0x0F;  // set all output pins to 0
rkLop2: 
    ldab PORTA         ; while(PORTA!=0F)  /* wait */;
    cmpb #$0F
    bne rkLop2
    ldd #10
    jsr delayms            ; delayms(10);  // Debouncing release of the key
    ldab RDK_CODE,SP
    jsr translate          ; ch = translate(code);
    leas RDK_VARSIZE,SP
    pula
    rts		           ;  return(ch); 

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
; Subroutine:  ch <- translate(code)
; Arguments
;	code - in Acc B - code read from keypad port
; Returns
;	ch - saved on stack but returned in Acc B - ASCII code
; Local Variables
;    	ptr - in register X - pointer to the table
;	count - counter for loop in accumulator A
; Description:
;   Translates the code by using the conversion table
;   searching for the code.  If not found, then BADCODE
;   is returned.
;-----------------------------------------------------------	
; Stack Usage:
   OFFSET 0
TR_CH DS.B 1  ; for ch 
TR_PR_A DS.B 1 ; preserved regiters A
TR_PR_X DS.B 1 ; preserved regiters X
TR_RA DS.W 1 ; return address

translate: psha
	pshx	; preserve registers
	leas -1,SP 		    		; byte chascii;
	ldx #cnvTbl		   			; ptr = cnvTbl;
	clra			    		; ix = 0;
	movb #BADCODE,TR_CH,SP      ; ch = BADCODE;

tLop: 			            	; do {
	cmpb cnvTbl_code,X  	    ;     if(code == ptr->code)
	bne tEndIf  	            ;     {
	movb cnvTbl_ascii,X,TR_CH,SP;        ch <- [ptr+1]
	bra tEndLop  		    	;         break;
tEndIf:  			    		;     }
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



