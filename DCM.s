#include <xc.inc>

global	DCM_Setup, DCM_Start, DCM_Stop, DCM_Reverse
    
psect	dac_code, class=CODE

DCM_Setup:
	clrf	TRISA
	clrf	PORTA
	movlw	00110000B
	movwf	T5CON, A
	bsf	TMR5IE
	movlw	00110000B
	movwf	T7CON, A
	bsf	TMR7IE
	return
	
DCM_Start:
	bsf	PORTA, 1
	bsf	TMR5ON
	return
DCM_Reverse:
	bsf	PORTA, 4
	bcf	PORTA, 1
	bcf	TMR5ON
	bcf	TMR5IF
	bsf	TMR7ON
	retfie	f
DCM_Stop:
	bsf	PORTA, 1
	clrf	PORTA
	bcf	TMR7ON
	bcf	TMR7IF
	retfie	f