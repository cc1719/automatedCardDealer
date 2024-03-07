#include <xc.inc>
	
global	PWM_Setup, Timer0, dutybyteL, dutybyteH, maxtimeL, maxtimeH
    
extrn	dutytimeL, dutytimeH, ADC_Setup, ADC_Read, LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Write_Dec, LCD_Send_Byte_D, LCD_clear, LCD_line1    

psect	udata_acs   ; reserve data space in access ram
dutybyteL: ds  1	  
dutybyteH: ds  1
maxtimeH:  ds  1
maxtimeL:  ds  1
arg1L:      ds 1   
arg1H:      ds 1
KL:	    ds 1
KH:	    ds 1
K3:	    ds 1
out0:       ds 1
out1:       ds 1
out2:       ds 1
out3:       ds 1
RES3:	    ds 1
RES2:	    ds 1
RES1:	    ds 1
RES0:	    ds 1
CAR2:	    ds 1
CAR1:	    ds 1
CAR0:	    ds 1
    
psect	dac_code, class=CODE

PWM_Setup:
    call	multiplier
    clrf	TRISD
    movlw	0xc0		; 0xc0 for 20ms TMR0
    movwf	TMR0L		; CHANGE BACK TO TMR0L
    movlw	0x63		; 0x63 for 20ms TMR0
    movwf	TMR0H		; CHANGE BACK TO TMR0H
    movlw	10000010B
    movwf	T0CON, A	; TMR0 is 20ms, time LOW
    bsf		TMR0IE		; Enable timer0 interrupt
    movff	maxtimeL, TMR3L, A
    movff	maxtimeH, TMR3H, A
    movlw	00100000B
    movwf	T3CON, A	; TMR3 is <Duty Cycle>, time HIGH
    bsf		TMR3IP
    bsf		TMR3IE
    bsf		PEIE
    bsf		GIE
    return
    
Timer0:
    btfsc	TMR3IF
    goto	Timer3
    btfss	TMR0IF		; CHANGE BACK TO TMR0IF
    retfie	f		; if not then return
    setf	PORTD
    bsf		TMR3ON
    bcf		TMR0IF		; CHANGE BACK TO TMR0IF
    movlw	0xc0		; 0xc0 for 20ms TMR0
    movwf	TMR0L		; CHANGE BACK TO TMR0L
    movlw	0x63		; 0x63 for 20ms TMR0
    movwf	TMR0H		; CHANGE BACK TO TMR0H
    retfie	f

Timer3:
    clrf	PORTD
    call	multiplier
    bcf		TMR3ON
    bcf		TMR3IF
    movff	maxtimeL, TMR3L, A
    movff	maxtimeH, TMR3H, A
    retfie	f

multiplier:
    call	ADC_Read
    call	multiply_16x16_bit
    call	display
;    movff	ADRESL, dutytimeL, A
;    movff	ADRESH, dutytimeH, A
    movlw	0x04
    mulwf	dutytimeL, A
    movff	PRODL, dutybyteL
    movff	PRODH, dutybyteH
    mulwf	dutytimeH, A
    movf	PRODL, W, A
    addwf	dutybyteH, F, A
    movlw	0xff
    movwf	maxtimeH, A
    movwf	maxtimeL, A
    movf	dutybyteL, W, A
    subwf	maxtimeL, F, A
    movf	dutybyteH, W, A
    subwfb	maxtimeH, F, A
    return

display:
	movf	RES3, W, A
	call	LCD_Write_Dec
	movlw	0x2E
	call	LCD_Send_Byte_D
	movf	RES2, W, A
	call	LCD_Write_Dec
	movf	RES1, W, A
	call	LCD_Write_Dec
	movlw	0x56
	call	LCD_Send_Byte_D
	return
    
multiply_16x16_bit:
    ; FIRST DIGIT
	movff   ADRESL, arg1L, A
	movff   ADRESH, arg1H, A
	movlw	0x01
	addwf	arg1L, F, A
	clrf	WREG
	addwfc	arg1H, F, A
	movlw   0x88
	movwf   KL, A
	movlw   0x13
	movwf   KH, A
	
	movf    arg1L, W, A
	mulwf   KL, A ; ARG1L * ARG2L to PRODH:PRODL
	
	movff   PRODH, out1
	movff   PRODL, out0 

	movf    arg1H, W, A
	mulwf   KH, A; ARG1H * ARG2H to PRODH:PRODL
	
   	movff   PRODH, out3 
	movff   PRODL, out2 
	
	movf    arg1L, W, A
	mulwf   KH, A ; ARG1L * ARG2H to PRODH:PRODL
	
	movf    PRODL, W
	addwf   out1, F, A ; Add cross
	movf    PRODH, W ; products
	addwfc  out2, F, A
	clrf    WREG
	addwfc  out3, F, A
	
	movf    arg1H, W, A
	mulwf   KL, A ; ARG1H * ARG2L to PRODH:PRODL
	
	movf    PRODL, W
	addwf   out1, F, A ; Add cross
	movf    PRODH, W ; products
	addwfc  out2, F, A
	clrf    WREG
	addwfc  out3, F, A
	
	swapf	out1, F, A
	movlw	0x0f
	andwf	out1, F, A
	swapf	out2, F, A
	swapf	out3, F, A
	movlw	0xf0
	andwf	out2, W, A
	iorwf	out1, F, A
	movlw	0x0f
	andwf	out2, F, A
	movlw	0xf0
	andwf	out3, W, A
	iorwf	out2, F, A
	clrf	out3, A
	clrf	out0, A
	
	movff   out1, arg1L, A
	movff	out1, dutytimeL, A
	movff	out2, dutytimeH, A
	movff   out2, arg1H, A
	clrf	out1, A
	clrf	out2, A
	movlw   0x8A
	movwf   KL, A
	movlw   0x41
	movwf   KH, A
	
	movf    arg1L, W, A
	mulwf   KL, A ; ARG1L * ARG2L to PRODH:PRODL
	
	movff   PRODH, out1 
	movff   PRODL, out0 

	movf    arg1H, W, A
	mulwf   KH, A; ARG1H * ARG2H to PRODH:PRODL
	
   	movff   PRODH, out3 
	movff   PRODL, out2 
	
	movf    arg1L, W, A
	mulwf   KH, A ; ARG1L * ARG2H to PRODH:PRODL
	
	movf    PRODL, W
	addwf   out1, F, A ; Add cross
	movf    PRODH, W ; products
	addwfc  out2, F, A
	clrf    WREG
	addwfc  out3, F, A
	
	movf    arg1H, W, A
	mulwf   KL, A ; ARG1H * ARG2L to PRODH:PRODL
	
	movf    PRODL, W
	addwf   out1, F, A ; Add cross
	movf    PRODH, W ; products
	addwfc  out2, F, A
	clrf    WREG
	addwfc  out3, F, A
	
	movff	out3, RES3
	movff	out2, CAR2
	movff	out1, CAR1
	movff	out0, CAR0
	
	clrf	out3, A
	clrf	out2, A
	clrf	out1, A
	clrf	out0, A
	; SECOND DIGIT
	movlw	0x0a
	movwf	K3, A
	
	movf	K3, A
	mulwf	CAR0, A
	movff	PRODL, out0
	movff	PRODH, out1
	
	movf	K3, A
	mulwf	CAR2, A
	movff	PRODL, out2
	movff	PRODH, out3
	
	movf	K3, A
	mulwf	CAR1, A
	movf	PRODL, W
	addwf	out1, F, A
	movf	PRODH, W
	addwfc	out2, F, A
	clrf	WREG
	addwfc	out3, F, A
	
	movff	out3, RES2
	movff	out2, CAR2
	movff	out1, CAR1
	movff	out0, CAR0
	
	clrf	out3, A
	clrf	out2, A
	clrf	out1, A
	clrf	out0, A
	; THIRD DIGIT
	movlw	0x0a
	movwf	K3, A
	
	movf	K3, A
	mulwf	CAR0, A
	movff	PRODL, out0
	movff	PRODH, out1
	
	movf	K3, A
	mulwf	CAR2, A
	movff	PRODL, out2
	movff	PRODH, out3
	
	movf	K3, A
	mulwf	CAR1, A
	movf	PRODL, W
	addwf	out1, F, A
	movf	PRODH, W
	addwfc	out2, F, A
	clrf	WREG
	addwfc	out3, F, A
	
	movff	out3, RES1
	movff	out2, CAR2
	movff	out1, CAR1
	movff	out0, CAR0
	
	clrf	out3, A
	clrf	out2, A
	clrf	out1, A
	clrf	out0, A
	; FOURTH DIGIT
	movlw	0x0a
	movwf	K3, A
	
	movf	K3, A
	mulwf	CAR0, A
	movff	PRODL, out0
	movff	PRODH, out1
	
	movf	K3, A
	mulwf	CAR2, A
	movff	PRODL, out2
	movff	PRODH, out3
	
	movf	K3, A
	mulwf	CAR1, A
	movf	PRODL, W
	addwf	out1, F, A
	movf	PRODH, W
	addwfc	out2, F, A
	clrf	WREG
	addwfc	out3, F, A
	
	movff	out3, RES0
	
	return
    