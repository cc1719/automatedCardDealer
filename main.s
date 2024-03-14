#include <xc.inc>

extrn   settingsInput, LCD_Setup, LCD_Send_Byte_D, LCD_Write_Message, LCD_clear, LCD_line2, LCD_delay_ms
global testVar
psect		udata_acs   
testVar: ds  1    
psect	code, abs

rst:	org	0x0
	goto	setup
	
setup:	
	call    settingsInput
	goto    $
	
	end rst
