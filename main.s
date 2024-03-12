#include <xc.inc>
    
psect	udata_acs   ; reserve data space in access ram
    dutytimeL: ds  1

psect	code, abs
	
rst:	org	0x0
	goto	setup
	
setup:	
	movlw	HIGH(dutycycle)
	movwf	dutytimeH, A
	movlw	LOW(dutycycle)
	movwf	dutytimeL, A
	call	PWM_Setup
	
	end	rst
