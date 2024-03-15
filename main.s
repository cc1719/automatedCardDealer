#include <xc.inc>

extrn   settingsInput, LCD_Setup, LCD_Send_Byte_D, LCD_Write_Message, LCD_clear, LCD_line2, LCD_delay_ms, timer2, timer2Setup
global main
psect		udata_acs   
testVar: ds  1    
psect	code, abs

rst:	org	0x0
	goto	setup
	
int_hi: org	0x0008
	goto    timer2
	
setup:	call    timer2Setup
	bsf     TMR2IE
	bsf     GIE
	bsf	PEIE
	bsf     TMR2ON

main:	call    settingsInput
	goto    $
	
	end rst
