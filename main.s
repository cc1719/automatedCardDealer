#include <xc.inc>

extrn	PWM_Setup, Timer0

global	dutytimeL, dutytimeH
    
psect	udata_acs   ; reserve data space in access ram
    dutytimeL: ds  1
    dutytimeH: ds  1

psect	data
	dutycycle EQU 2000
;testing
psect	code, abs
	
;rst:	org	0x0
;	goto	setup

int_hi:	
	org	0x0008	; high vector, no low vector
	goto	Timer0
	
setup:	
	movlw	HIGH(dutycycle)
	movwf	dutytimeH, A
	movlw	LOW(dutycycle)
	movwf	dutytimeL, A
	call	PWM_Setup
    
main:
	goto	$

	end	rst
