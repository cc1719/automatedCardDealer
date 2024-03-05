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
	clrf	TMR1L
	clrf	TMR1H
	movlw	10000010B
	movwf	T0CON, A	; TMR0 is 20ms, time LOW
	bsf	TMR0IE		; Enable timer0 interrupt
	movlw	00100100B
	movwf	T1CON, A	; TMR1 is <Duty Cycle>, time HIGH
	bsf	TMR1IE
	bsf	GIE
    
main:
	goto	$