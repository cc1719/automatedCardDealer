#include <xc.inc>

extrn   settingsInput, LCD_Setup, LCD_Send_Byte_D

psect	code, abs
	
rst:	org	0x0
	goto	setup
	
setup:	call    settingsInput
	goto    $
	
	end rst
