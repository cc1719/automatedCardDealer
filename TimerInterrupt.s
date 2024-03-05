#include <xc.inc>
	
global	Timer1
    
psect	dac_code, class=CODE


Timer1:
    btfss	TMR1IF		; check that this is timer0 interrupt
    retfie	f		; if not then return
    movlw	0xff
    movwf	PORTD
    bcf		TMR1IF	
    retfie	f
