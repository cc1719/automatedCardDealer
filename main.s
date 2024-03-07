#include <xc.inc>

extrn	Timer0

psect	code, abs
	
rst:	org	0x0
	goto	setup

int_hi:	
	org	0x0008	; high vector, no low vector
	goto	Timer0
	
setup:	clrf	TRISD
	clrf	TMR0L
	clrf	TMR0H
	clrf	TMR3L
	clrf	TMR3H
	movlw	10000010B
	movwf	T0CON, A	; TMR0 is 20ms, time LOW
	bsf	TMR0IE		; Enable timer0 interrupt
;	movlw	00000101B
;	movwf	T3CON, A	; TMR3 is <Duty Cycle>, time HIGH
;	bsf	TMR3IE
	bsf	GIE
    
main:
	clrf	PORTD
	goto	main

	end	rst