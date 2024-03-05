#include <xc.inc>
	
global	Timer0  
    
psect	dac_code, class=CODE

Timer0:
    btfsc	TMR2IF
    goto	Timer1
    btfss	TMR0IF		; check that this is timer0 interrupt
    retfie	f		; if not then return
    setf	PORTD
    bsf		TMR2ON
    bcf		TMR0IF
    clrf	TMR0L
    clrf	TMR0H
    retfie	f

Timer1:
    clrf    PORTD
    bcf	    TMR2ON
    bcf	    TMR2IF
    clrf    TMR2
    retfie  f