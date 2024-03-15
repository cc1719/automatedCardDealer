#include <xc.inc>

extrn   settingsInput, LCD_Setup, LCD_Send_Byte_D, LCD_Write_Message, LCD_clear, LCD_line2, LCD_delay_ms, timer2, timer2Setup
    
psect		udata_acs   
testVar: ds  1    
psect	code, abs

rst:	org	0x0
	goto	main
	
int_hi: org	0x0008
	goto    timer2
	
main:	call    timer2Setup
	bsf     TMR2IE
	bsf     GIE
	call    settingsInput
	goto    $
	
	end rst
