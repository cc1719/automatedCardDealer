#include <xc.inc>

extrn	PWM_Setup, Timer0, ADC_Setup, ADC_Read, LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Write_Dec, LCD_Send_Byte_D, LCD_clear, LCD_line1

global	dutytimeL, dutytimeH
    
psect	udata_acs   ; reserve data space in access ram
    dutytimeL: ds  1
    dutytimeH: ds  1

psect	data
	dutycycle EQU 3784

psect	code, abs
	
rst:	org	0x0
	goto	setup

int_hi:	
	org	0x0008	; high vector, no low vector
	goto	Timer0
	
setup:	
;	movlw	HIGH(dutycycle)
;	movwf	dutytimeH, A
;	movlw	LOW(dutycycle)
;	movwf	dutytimeL, A
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	LCD_Setup	; setup UART
	call	PWM_Setup
	call	ADC_Setup
    
main:
	goto	$

	end	rst