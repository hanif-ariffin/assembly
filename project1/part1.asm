;--------------------
; Lab Part 10
;--------------------
 org $2000
	ldd #$3b
	ldx $EE86
	jsr 0,X
	ldx $ee84
	jsr 0,x
	ldaa #15
	psha
	pshb
	ldd #$3b
	ldx $ee86
	jsr 0,x
	pulb
	ldx $ee86
	jsr 0,x
	pula
	deca
	bne $200F
	swi