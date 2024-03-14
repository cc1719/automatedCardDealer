#include <xc.inc>

extrn   settingsInput

psect	code, abs
	
rst:	org	0x0
	goto	setup
	
setup:	call    settingsInput
	goto    $
	
	end rst
