#include <xc.inc>

extrn	Timer1, timeH, timeL
    
psect	code, abs
	
rst:	org	0x0
	goto	setup

int_hi:	
	org	0x0008	; high vector, no low vector
	goto	Timer1
	
setup:	clrf	TRISD
	movlw	10000010B
	movwf	T0CON, A
	bsf	TMR0IE		; Enable timer0 interrupt
	bsf	GIE
    
main:
	clrf	PORTD
	goto	main