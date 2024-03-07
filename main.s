#include <xc.inc>

extrn	PWM_Setup, Timer0

psect	code, abs
	
;rst:	org	0x0
;	goto	setup

int_hi:	
	org	0x0008	; high vector, no low vector
	goto	Timer0
	
setup:	
	call	PWM_Setup
    
main:
	goto	$

	end	rst
