#include <xc.inc>

extrn	Servo_Setup, Servo_Start, DCM_Setup, DCM_Start, ADC_Setup, ADC_Read, LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Write_Dec, LCD_Send_Byte_D, LCD_clear, LCD_line1

psect	udata_acs   ; named variables in access ram
    delL:	ds 1	
    delH:	ds 1	
    
psect	code, abs
	
rst:	org	0x0
	goto	setup

int_hi:	
	org	0x0008	; high vector, no low vector
	goto	Servo_Start
	
setup:	
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	LCD_Setup	; setup LCD
	call	ADC_Setup
	call	Servo_Setup
	call	DCM_Setup
	setf	TRISE
	clrf	PORTE
    
main:
	btfsc	PORTE, 0, A
	bsf	TMR3ON
	btfsc	PORTE, 1, A
	bcf	TMR3ON
	btfsc	PORTE, 2, A
	call	DCM_Start
	movlw	0xff
	movwf	delL, A
	movlw	0xff
	movwf	delH, A
	call	bigdelay
	goto	main  

bigdelay:
    movlw   0x0
dloop:    
    decf    delL, F, A
    subwfb  delH, F, A
    bc	    dloop
    return
    
	end	rst