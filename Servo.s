#include <xc.inc>
	
global	Servo_Setup, Servo_Start
    
extrn	DCM_Stop, DCM_Reverse, rottime, timerH, timerL
    
psect	dac_code, class=CODE

Servo_Setup:
    clrf	TRISD
    movlw	0xc0		; 0xc0 for 20ms TMR0
    movwf	TMR3L		; CHANGE BACK TO TMR0L
    movlw	0x63		; 0x63 for 20ms TMR0
    movwf	TMR3H		; CHANGE BACK TO TMR0H
    movlw	00110000B
    movwf	T3CON, A	; TMR0 is 20ms, time LOW
    bsf		TMR3IE		; Enable timer0 interrupt
    movlw	01011001B
    movwf	T2CON, A	; TMR3 is <Duty Cycle>, time HIGH
    bsf		TMR2IE
    movff	timerH, TMR0H
    movff	timerL, TMR0L
    movlw	00000111B
    movwf	T0CON, A
    bsf		TMR0IE
    bsf		PEIE
    bsf		GIE
    return
    
Servo_Start:
    btfsc	TMR2IF
    goto	Duty_cycle
    btfsc	TMR0IF
    goto	Servo_Stop
;    btfsc	TMR1IF
;    goto	DCM_Stop
    setf	PORTD
    bsf		TMR2ON
    bcf		TMR3IF		; CHANGE BACK TO TMR0IF
    movlw	0xc0		; 0xc0 for 20ms TMR0
    movwf	TMR3L		; CHANGE BACK TO TMR0L
    movlw	0x63		; 0x63 for 20ms TMR0
    movwf	TMR3H		; CHANGE BACK TO TMR0H
    retfie	f

Duty_cycle:
    clrf	PORTD
    bcf		TMR2ON
    bcf		TMR2IF
    retfie	f

Servo_Stop:
    bcf		TMR3ON
    bcf		TMR0ON
    bcf		TMR0IF
    bcf		PORTE, 0, A
    retfie	f