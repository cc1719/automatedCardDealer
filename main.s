#include <xc.inc>

extrn	Servo_Setup, Servo_Start, divide

global	rottime, timerH, timerL, cardno, startservo    

psect	udata_acs   ; named variables in access ram
    delL:	ds 1	
    delH:	ds 1	
    delI:	ds 1
    timerH:	ds 1
    timerL:	ds 1
    rottimeL:	ds 1
    rottimeH:	ds 1
    cardno:	ds 1
    
PSECT	udata_acs_ovr,space=1,ovrld,class=COMRAM
	rottime	EQU 31000
	
psect	code, abs
	
rst:	org	0x0
	goto	setup

int_hi:	
	org	0x0008	; high vector, no low vector
	goto	Servo_Start
	
setup:	
	movlw	0x5
	movwf	cardno, A
	call	divide
	movlw	0xff
	movwf	timerL, A
	movlw	0xff
	movwf	timerH, A
	movf	PRODL, W, A
	subwf	timerL, F, A
	movf	PRODH, W, A
   	subwfb	timerH, F, A
	clrf	TRISD
	clrf	TRISA
	clrf	PORTA
	clrf	PORTD
	call	Servo_Setup
	nop
 
main:
	btfss	PORTB, 0, A
	call	Dealing
	goto	main

Dealing: 
	tstfsz	cardno, A
	call	startservo
	return
	
startservo:
	bsf	TMR3ON
	bsf	PORTB, 0, A
	movff	timerH, TMR0H
	movff	timerL, TMR0L
	bsf	TMR0ON
	return