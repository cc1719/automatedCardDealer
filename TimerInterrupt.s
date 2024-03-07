#include <xc.inc>
	
global	PWM_Setup, Timer0  
    
extrn	dutytimeL, dutytimeH

psect	udata_acs   ; reserve data space in access ram
dutybyteL: ds  1	  
dutybyteH: ds  1
maxtimeH:  ds  1
maxtimeL:  ds  1
    
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
    movlw	maxtimeL
    movwf	TMR3L
    movlw	maxtimeH
    movwf	TMR3H
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
    bcf		TMR3ON
    bcf		TMR3IF
    movlw	maxtimeL
    movwf	TMR3L
    movlw	maxtimeH
    movwf	TMR3H
    retfie	f

multiplier:
    movlw	0x04
    mulwf	dutytimeL, A
    movff	PRODL, dutybyteL
    movff	PRODH, dutybyteH
    mulwf	dutytimeH, A
    movf	PRODH
    addwf	dutybyteH, F, A
    movlw	0xff
    movwf	maxtimeH, A
    movwf	maxtimeL, A
    movf	dutybyteL, A
    subwf	maxtimeL, F, A
    movf	dutybyteH, A
    subwfb	maxtimeH, F, A
    return
    