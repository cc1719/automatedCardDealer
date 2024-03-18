#include <xc.inc>
	
global	Servo_Setup, Servo_Start
    
extrn	rottime, timerH, timerL, cardno
    
psect	dac_code, class=CODE

Servo_Setup:
    clrf	TRISF
    movlw	0xc0		; 0xc0 for 20ms TMR0
    movwf	TMR3L		; CHANGE BACK TO TMR0L
    movlw	0x63		; 0x63 for 20ms TMR0
    movwf	TMR3H		; CHANGE BACK TO TMR0H
    movlw	00000000B
    movwf	T3CON, A	; TMR0 is 20ms, time LOW
    bsf		TMR3IE		; Enable timer0 interrupt
    movlw	00111000B
    movwf	T2CON, A	; TMR3 is <Duty Cycle>, time HIGH
    bsf		TMR2IE
    movff	timerH, TMR0H
    movff	timerL, TMR0L
    movlw	00000100B
    movwf	T0CON, A
    movlw	01111011B
    movwf	T4CON, A
    bsf		TMR4IE
    bsf		TMR0IE
    clrf	PORTB
    clrf	TRISB
    clrf	TRISD
    clrf	TRISA
    clrf	PORTA
    clrf	PORTD
    bsf		PEIE
    bsf		GIE
    return
    
Servo_Start:
    btfsc	TMR2IF
    goto	Duty_cycle
    btfsc	TMR0IF
    goto	Servo_Stop
    btfsc	TMR4IF
    goto	DCM_On
    setf	PORTF
    bsf		TMR2ON
    bcf		TMR3IF		; CHANGE BACK TO TMR0IF
    movlw	0xc0		; 0xc0 for 20ms TMR0
    movwf	TMR3L		; CHANGE BACK TO TMR0L
    movlw	0x63		; 0x63 for 20ms TMR0
    movwf	TMR3H		; CHANGE BACK TO TMR0H
    retfie	f

Duty_cycle:
    clrf	PORTF
    bcf		TMR2ON
    bcf		TMR2IF
    retfie	f

Servo_Stop:
    bcf		TMR3ON
    bcf		TMR0ON
    bcf		TMR0IF
    btfss	PORTD, 4, A
    goto	Motor_Break
    bcf		PORTD, 4, A
    bcf		PORTA, 1, A
    decf	cardno, A
    bcf		PORTB, 0, A
    retfie	f
    
DCM_On:
    bsf	    PORTD, 4, A
    bsf	    PORTA, 1, A
    bcf	    TMR4ON
    bcf	    TMR4IF
    movlw   0xd8
    movwf   TMR0H
    movlw   0xef
    movwf   TMR0L
    bsf	    TMR0ON
    retfie  f

Motor_Break: 
    bsf		TMR4ON
    retfie	f
