#include <xc.inc>

extrn	PWM_Setup, Timer0, ADC_Setup, ADC_Read, LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Write_Dec, LCD_Send_Byte_D, LCD_clear, LCD_line1, KeyPad_Setup, Check_KeyPress, KeyPad_Value, KeyPad_Output

global	dutytimeL, dutytimeH
    
psect	udata_acs   ; reserve data space in access ram
    dutytimeL:      ds  1
    dutytimeH:      ds  1
    delayCounter:   ds  1
    clearVariable:  ds  1
    
psect	data
	dutycycle EQU 3784

psect	code, abs
	
rst:	org	0x0
	goto	setup

int_hi:	org	0x0008	; high vector, no low vector
	tstfsz  KeyPad_Value, 0
	goto    next
	goto    next3
next:	call    KeyPad_Output
	cpfseq  clearVariable
	goto    next2
	goto    clear
next2:	movf    KeyPad_Value, 0, 0
	call    LCD_Send_Byte_D	
	goto    next3
clear:  call    LCD_clear
next3:	retfie	f
	;goto	Timer0
	
setup:	
;	movlw	HIGH(dutycycle)
;	movwf	dutytimeH, A
;	movlw	LOW(dutycycle)
;	movwf	dutytimeL, A
;	bcf	CFGS	; point to Flash program memory  
;	bsf	EEPGD 	; access Flash program memory
	call	LCD_Setup	; setup UART
;	call	PWM_Setup
;	call	ADC_Setup
	call    KeyPad_Setup
	movlw   01000110B
	movwf   clearVariable
	movlw   0
	movwf   KeyPad_Value
main:	goto    $
	

delay:	movlw   0x2
        movwf   delayCounter, A
count:  decfsz  delayCounter, A           
        bra     delayCounter
        return

	end	rst
