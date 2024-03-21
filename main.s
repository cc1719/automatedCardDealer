#include <xc.inc>

extrn   Settings_Setup, Settings_Input, Servo_Setup, Interrupt_Check, divide, numCards, numPlayers, output, Reset_Settings, Dealing_Message

global	cardno, timerL, timerH, currentPlayer, numCards
    
psect	udata_acs   ; reserve data space in access ram
    delL:	ds 1	
    delH:	ds 1	
    delI:	ds 1
    timerL:	ds 1
    timerH: 	ds 1
    cardno:	ds 1
    currentPlayer: ds 1
    posdelta: 	ds 1

psect	code, abs
	
rst:	org	0x0
	goto	setup

int_hi:	
	org	0x0008	; high vector, no low vector
	goto	Interrupt_Check
	
setup:	call    Settings_Setup
	call	Servo_Setup			; Servo.s setup
 	bsf	TMR3ON				; Start PWM on Servo
	call    Settings_Input			; Run Keypad & LCD Scripts, output numCards & numPlayers
	movlw	0xff
	movwf	timerL, A
	movlw	0x7f
	movwf	timerH, A			; Time for Servo to reach desired position
 	movff	numPlayers, currentPlayer, A 	; currentPlayer will count down as dealer faces relevant player
	call	divide
	movff	output, posdelta, A
	goto	main

main:
	btfss	LATA, 7, A		; Check if interrupt is currently actively dealing a card
	goto	Dealing			; If not, move to Deal function
	goto	main			; Repeatedly check this flag

Dealing:
	call    Dealing_Message
	movlw	0xff
	movwf	delL, A
	movlw	0xff
	movwf	delH, A
	movlw	0x07
	movwf	delI, A
	call	bigdelay		; Implemented manual 32bit delay so that there is break between dealt card and servo rotation
 	movlw	0x00
  	cpfsgt	numCards, A		; Check if all players have been dealt cards
   	goto 	Play_Again		; If yes, restart?
  	cpfsgt	currentPlayer, A	; Check if dealer has moved to final player position
   	goto	Player1			; If yes, return to player 1 and deal
	movf	numPlayers, W, A
 	cpfseq	currentPlayer, A	; Check if dealer is facing player 1
  	goto	Next_Player		; If not, move to next player and deal
   	goto	Deal_card		; If yes, deal a card

Player1: 				; Dealer has dealt to last player, back to player 1
 	movff	numPlayers, currentPlayer, A
 	movlw	0x32
  	movwf	PR2, A
   	goto	Deal_card

Next_Player: 				; Dealer has dealt to player 1, move on to next
	movf	posdelta, W, A
   	addwf	PR2, F, A
    	goto	Deal_card
 
Deal_card:
	bsf	LATA, 7, A		; Set flag - card is being dispensed!
	movff	timerH, TMR0H
	movff	timerL, TMR0L
	bsf	TMR0ON			; Timer0 sets how long servo should spin - timerH and timerL were calculated in divide.s
	goto	main

Play_Again: 
	movlw	0x32
  	movwf	PR2, A			; Return to player 1 position
	call    Reset_Settings
	movlw   0
	movwf   numPlayers, A
	movlw   0
	movwf   numCards, A
	goto    setup
	
bigdelay: 				; 32bit delay function
    movlw   0x00
dloop: 
    decf    delL, F, A
    subwfb  delH, F, A
    subwfb  delI, F, A
    bc	    dloop
    return

	end rst
