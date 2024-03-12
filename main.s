#include <xc.inc>
 
extrn   KeyPad_Setup, Check_KeyPress, KeyPad_Value, KeyPad_Output, LCD_Setup, LCD_Write_Message, LCD_clear, settingsInput
    
psect	udata_acs  
variable: ds  1

psect	code, abs

rst:	org	0x0
	goto	main
	
main:   call settingsInput

	
	
	
	end	rst
