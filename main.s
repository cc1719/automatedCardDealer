#include <xc.inc>

extrn   ADC_Setup, ADC_Read, LCD_clear, settingsInput

global	dutytimeL, dutytimeH
    
psect	udata_acs   ; reserve data space in access ram
    dutytimeL:      ds  1
    dutytimeH:      ds  1
    delayCounter:   ds  1
    variable:	    ds  1
    
psect	data
	dutycycle EQU 3784

psect	code, abs
	
rst:	org	0x0
	goto	setup

;int_hi:	
;	org	0x0008	; high vector, no low vector
;	goto	Timer0
	
setup:	
;	movlw	HIGH(dutycycle)
;	movwf	dutytimeH, A
;	movlw	LOW(dutycycle)
;	movwf	dutytimeL, A
;	bcf	CFGS	; point to Flash program memory  
;	bsf	EEPGD 	; access Flash program memory
;	call	LCD_Setup	; setup UART
;	call	PWM_Setup
;	call	ADC_Setup
;	call    KeyPad_Setup
	call    settingsInput
	
	end	rst
