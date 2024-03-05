#include <xc.inc>

extrn	Timer1
    
psect	code, abs
	
rst:	org	0x0
	goto	setup

int_hi:	
	org	0x0008	; high vector, no low vector
	goto	Timer1
	
setup:	clrf	TRISD
	movlw	01110101B
	movwf	T1CON, A	
	bsf	TMR1IE		; Enable timer0 interrupt
	bsf	GIE	
    
main:
	clrf	PORTD
	goto	main