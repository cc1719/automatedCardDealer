#include <xc.inc>

extrn	PWM_Setup, Timer0

global	dutytimeL, dutytimeH
    
psect	udata_acs   ; reserve data space in access ram
    dutytimeL: ds  1
    dutytimeH: ds  1

psect	data
	dutycycle EQU 2000

psect	code, abs
	
;rst:	org	0x0
;	goto	setup

;test
    
main:
	goto	$

	end	rst
