
;-----------------

;LAB 1 Part B

;-----------------

 ORG	$2000 
	LDD #$3A
	LDX $EE86
	JSR 0,X
	LDX $EE84
	JSR 0,X
	LDAA #3
	 PSHA
 	PSHB
	LDD #$20
	LDX $EE86
	JSR 0,X
	PULB
	LDX $EE86
	JSR 0,X
	PULA
	DECA
	BNE $200F
	SWI