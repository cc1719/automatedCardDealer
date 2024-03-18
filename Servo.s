#include <xc.inc>
    
extrn	rottime, timerH, timerL, cardno
	
global	Servo_Setup, Servo_Start
    
psect	servo_code, class=CODE

Servo_Setup:
    clrf	TRISF		; Set PORTF as output for PWM signal to servo
    movlw	0xc0	
    movwf	TMR3L		
    movlw	0x63		
    movwf	TMR3H	
    movlw	00000000B
    movwf	T3CON, A	; TMR3 is calibrated to 20ms period for PWM (50Hz)
    bsf		TMR3IE		; Enable TMR3 interrupt
    movlw	00111000B
    movwf	T2CON, A	; TMR2 is set to duty cycle time
    bsf		TMR2IE		; Enable TMR2 interrupt
    movff	timerH, TMR0H
    movff	timerL, TMR0L
    movlw	00000100B
    movwf	T0CON, A	; TMR0 is set to Servo rotation time
    bsf		TMR0IE		; Enable TMR0 interrupt
    movlw	01111011B	
    movwf	T4CON, A	; TMR4 is for small delay between Servo rotation complete and start DCM rotation
    bsf		TMR4IE		; Enable TMR4 interrupt
    clrf	TRISD
    clrf	TRISA
    clrf	PORTA
    clrf	PORTD		; Clear PORTD and PORTA and set as outputs for Dealing flag & DCM control
    bsf		PEIE
    bsf		GIE		; Relevant interrupt enable bits
    return
    
Servo_Start:			; Start by checking what interrupt has been triggered
    btfsc	TMR2IF	
    goto	Duty_cycle	; Duty cycle is over, PORTF should be pulled low
    btfsc	TMR0IF
    goto	Servo_Stop	; Servo/DCM has run and should be turned off
    btfsc	TMR4IF
    goto	DCM_On		; Servo stopped and TMR4 is done, DCM should be turned on
    setf	PORTF		; Otherwise, TMR3 is done and new period starts - set PORTF high
    bsf		TMR2ON		; Start TMR2 (duty cycle)
    bcf		TMR3IF		; Clear TMR3 flag
    movlw	0xc0	
    movwf	TMR3L	
    movlw	0x63	
    movwf	TMR3H		; Calibration to ensure TMR3 runs for 20ms
    retfie	f

Duty_cycle:
    clrf	PORTF		; Duty cycle is over, PORTF pulled low
    bcf		TMR2ON		; Stop TMR2 until next period
    bcf		TMR2IF		; Clear TMR2 flag
    retfie	f

Servo_Stop:
    bcf		TMR3ON		; Servo has reached desired position, stop PWM
    bcf		TMR0ON		; Servo has reached desired position, stop TMR0
    bcf		TMR0IF		; Clear TMR0 flag
    btfss	PORTD, 4, A	; Check if the DCM is currently active (this function stops both DCM and Servo)
    goto	Motor_Break	; If DCM is not on, start TMR4, after which DCM will turn on
    bcf		PORTD, 4, A	; If DCM is already on, TMR0 has finished (card is dealt), clear DCM flag
    bcf		PORTA, 1, A	; TMR0 has finished and DCM has finished spinning, turn off DCM
    decf	cardno, A	; Decrease cardno (this is the last part after servo and DCM have done one cycle)
    bcf		PORTA, 7, A	; Clear Dealing flag, so main.s can determine whether more cards should be dealt
    retfie	f
    
DCM_On:
    bsf	    PORTD, 4, A		; DCM On flag (LED on PIC18)
    bsf	    PORTA, 1, A		; TMR4 is complete, Turn on DCM
    bcf	    TMR4ON		; Turn off TMR4
    bcf	    TMR4IF		; Clear TMR4 flag
    movlw   0xd8
    movwf   TMR0H
    movlw   0xef
    movwf   TMR0L		; Calibrated time for DCM to spin
    bsf	    TMR0ON		; Turn on TMR0 for DCM to spin
    retfie  f

Motor_Break: 
    bsf		TMR4ON		; Turn on TMR4 for break between servo and DCM spins
    retfie	f


