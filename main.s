#include <xc.inc>
    
psect	udata_acs  
variable: ds  1

psect	code, abs
	
rst:	org	0x0
	goto	setup
	
setup:	
	clrf    TRISD
	movlw   0xff
	comf    PORTD, F
	clrf    TRISE
	movlw   0xff
	comf    PORTE, F
	goto	setup
	end	rst
