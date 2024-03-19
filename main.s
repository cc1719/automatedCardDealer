#include <xc.inc>

extrn   LCD_clear, settingsInput, Servo_Setup, Servo_Start, divide, divide2, output, numCards, numPlayers	

global	rottime, timerH, timerL, cardno 
    
psect	udata_acs   ; reserve data space in access ram
    delL:	ds 1	
    delH:	ds 1	
    delI:	ds 1
    timerH:	ds 1
    timerL:	ds 1
    rottimeL:	ds 1
    rottimeH:	ds 1
    cardno:	ds 1
    
PSECT	udata_acs_ovr,space=1,ovrld,class=COMRAM
	rottime	EQU 31000		; Calibrated for one rotation of continuous servo

psect	code, abs
	
rst:	org	0x0
	goto	main

int_hi:	
	org	0x0008	; high vector, no low vector
	goto	Servo_Start
	
setup:	
	;call    settingsInput		; Run Keypad & LCD Scripts, output numCards & numPlayers
	;movf	numCards, W, A
	;mulwf	numPlayers, A
	;movff	PRODL, cardno, A	; Total number of DCM spins stored in cardno
	;call	divide			; Calculation for Servo rotation
	;movlw	0xff
	;movwf	timerL, A
	;movlw	0xff
	;movwf	timerH, A
	;movf	PRODL, W, A
	;subwf	timerL, F, A
	;movf	PRODH, W, A
   	;subwfb	timerH, F, A
	;call	Servo_Setup		; Servo.s setup
	;goto	main

main:	movlw   3
	movwf   numPlayers, A
	call    divide2
	nop
	
	btfss	PORTA, 7, A		; Check if interrupt is currently actively dealing a card
	call	Dealing			; If not, move to Deal function
	goto	main			; Repeatedly check this flag

Dealing:
	movlw	0xff
	movwf	delL, A
	movlw	0xff
	movwf	delH, A
	movlw	0x05
	movwf	delI, A
	call	bigdelay		; Implemented manual 32bit delay so that there is break between dealt card and servo rotation
	tstfsz	cardno, A		; Check if machine has dealt all the necesary cards
	call	startservo		; If not, move servo and DCM to deal a card
	return
	
startservo:
	bsf	TMR3ON			; Start PWM on Servo
	bsf	PORTA, 7, A		; Set flag - card is being dispensed!
	movff	timerH, TMR0H
	movff	timerL, TMR0L
	bsf	TMR0ON			; Timer0 sets how long servo should spin - timerH and timerL were calculated in divide.s
	return

bigdelay: 				; 32bit delay function
    movlw   0x00
dloop: 
    decf    delL, F, A
    subwfb  delH, F, A
    subwfb  delI, F, A
    bc	    dloop
    return

	end rst
