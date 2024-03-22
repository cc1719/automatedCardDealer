#include <xc.inc>
    
extrn	timerH, timerL, cardno, currentPlayer, numCards
	
global	Servo_Setup, Interrupt_Check
    
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
    movlw	0x32		
    movwf	PR2, A		; Setup servo at pos 0 by setting PWM duty cycle to 500us
    movlw	00100001B
    movwf	T2CON, A	; TMR2 is set to duty cycle time
    bsf		TMR2IE		; Enable TMR2 interrupt
    movlw	00000100B
    movwf	T0CON, A	; TMR0 is set to Servo rotation time
    bsf		TMR0IE		; Enable TMR0 interrupt
    movlw	00110000B
    movwf	T1CON, A
    bsf		TMR1IE
    clrf	TRISD
    clrf	TRISA
    clrf	TRISH
    clrf	LATH
    clrf	LATA
    clrf	LATD
    bsf		LATA, 0, A
    bsf		LATD, 2, A	
    bsf		PEIE
    bsf		GIE		; Relevant interrupt enable bits
    return

Interrupt_Check: 		; Start by checking what interrupt has been triggered
    btfsc	TMR3IF		
    goto	PWM_Start	; Servo period is over, PORTF should be pulled high
    btfsc	TMR2IF	
    goto	Duty_cycle	; Duty cycle is over, PORTF should be pulled low
    btfsc	TMR0IF
    goto	Servo_Stop	; Servo/DCM has run and should be turned off
    btfsc	TMR1IF
    goto	Next_Servo

PWM_Start:			
    setf	PORTF		; TMR3 is done and new period starts - set PORTF high
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
    bcf		TMR0ON		; Servo has reached desired position, stop TMR0
    bcf		TMR0IF		; Clear TMR0 flag
    btfss	LATD, 4, A	; Check if the DCM is currently active (this function stops both DCM and Servo)
    goto	DCM_On		; If DCM is not on, start TMR4, after which DCM will turn on
    bsf		LATD, 2, A	; TMR0 has finished and DCM has finished spinning, turn off DCM
    btfsc	LATA, 0, A	; Check if motor has reversed
    goto	Motor_Reverse	; If not, set motor to reverse
    bsf		LATA, 0, A
    bcf		LATD, 4, A	; If DCM is already on, TMR0 has finished (card is dealt), clear DCM flag
    dcfsnz	currentPlayer, A; Move to next player
    decf	numCards, A
    bsf		TMR1ON
    retfie	f
    
DCM_On:
    bsf	    LATD, 4, A		; DCM On flag (LED on PIC18)
    bcf	    LATD, 2, A		
    movlw   0xC7
    movwf   TMR0H
    movlw   0x38
    movwf   TMR0L		; Calibrated time for DCM to spin
    bsf	    TMR0ON		; Turn on TMR0 for DCM to spin
    retfie  f

Motor_Reverse:			; Reverse DCM to pull back the extra cards
    bcf	    LATA, 0, A
    movlw   0xC7
    movwf   TMR0H
    movlw   0x38
    movwf   TMR0L
    bsf	    TMR0ON
    retfie  f
    
Next_Servo:
    bcf	    TMR1ON
    bcf	    TMR1IF
    bcf	    LATH, 0, A	; Clear Dealing flag, so main.s can determine whether more cards should be dealt
    retfie  f
