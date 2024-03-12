#include <xc.inc>
 
extrn   KeyPad_Setup, Check_KeyPress, KeyPad_Value, KeyPad_Output, LCD_Setup, LCD_Write_Message, LCD_clear
    
psect	udata_acs  
variable: ds  1

psect	code, abs

rst:	org	0x0
	goto	setup
	
setup:	;call    KeyPad_Setup
	;call    LCD_Setup
	
	end	rst
