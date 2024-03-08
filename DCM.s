#include <xc.inc>

global	DCM_Setup, DCM_Start, DCM_Stop, DCM_Reverse
    
psect	dac_code, class=CODE

DCM_Setup:
	clrf	TRISA
	clrf	PORTA
	movlw	00000111B
	movwf	T0CON, A
	bsf	TMR0IE
;	movlw	00110000B
;	movwf	T5CON, A
;	bsf	TMR5IE
	movlw	00110000B
	movwf	T1CON, A
	bsf	TMR1IE
	return
	
DCM_Start:
	bsf	PORTA, 1
	bsf	TMR0ON
	return
DCM_Reverse:
	setf	PORTA
	bcf	PORTA, 1
	bcf	TMR0ON
	bsf	TMR1ON
	bcf	TMR0IF
	retfie	f
DCM_Stop:
	bsf	PORTA, 1
	clrf	PORTA
	bcf	TMR1ON
	bcf	TMR1IF
	retfie	f