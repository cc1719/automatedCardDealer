#include <xc.inc>

extrn   KeyPad_Setup, LCD_Setup, Settings_Input, Servo_Setup, Interrupt_Check, divide, numCards, numPlayers, output, Reset_Settings, Dealing_Message, divide16bit

global	timerL, timerH, currentPlayer, numCards
    
psect	udata_acs   ; reserve data space in access ram
    timerL:	ds 1
    timerH: 	ds 1
    currentPlayer: ds 1
    posdelta: 	ds 1

psect	code, abs
	
rst:	org	0x0
	goto	setup

int_hi:	
	org	0x0008	; high vector, no low vector
	goto	Interrupt_Check
	
setup:	
	call    KeyPad_Setup		; Set-up routines for LCD and keypad.
	call    LCD_Setup
	call	Servo_Setup			; Servo.s setup
 	bsf	TMR3ON				; Start PWM on Servo

User_Input:
	call    Settings_Input			; Run Keypad & LCD Scripts, output numCards & numPlayers
	movlw	0x01
	movwf	timerH, A
	movlw	0xff
	movwf	timerL, A
	movlw	0x03
	cpfslt	numPlayers, A
	call	divide16bit
 	movff	numPlayers, currentPlayer, A 	; currentPlayer will count down as dealer faces relevant player
	call	divide
	movff	output, posdelta, A
	goto	main

main:
	btfss	LATH, 0, A		; Check if interrupt is currently actively dealing a card
	goto	Dealing			; If not, move to Deal function
	goto	main			; Repeatedly check this flag

Dealing:
	bsf	LATH, 0, A		; Set flag - card is being dispensed!
	call    Dealing_Message
 	movlw	0x00
  	cpfsgt	numCards, A		; Check if all players have been dealt cards
   	goto 	Play_Again		; If yes, restart?
  	cpfsgt	currentPlayer, A	; Check if dealer has moved to final player position
   	goto	Player1			; If yes, return to player 1 and deal
	movf	numPlayers, W, A
 	cpfseq	currentPlayer, A	; Check if dealer is facing player 1
  	goto	Next_Player		; If not, move to next player and deal
	bsf	TMR0ON			; Timer0 sets how long servo should spin - timerH and timerL were calculated in divide.s
	goto	main

Player1: 				; Dealer has dealt to last player, back to player 1
 	movff	numPlayers, currentPlayer, A	; Reset current player value
 	movlw	0x32		    
  	movwf	PR2, A			; Reset servo position back to Player 1
	movlw	0x01
	movwf	TMR0H, A
	movlw	0xff
	movwf	TMR0L, A		; Set long timer for servo to spin as it is doing half revolution
	bsf	TMR0ON			; Timer0 sets how long servo should spin - timerH and timerL were calculated in divide.s
	goto	main

Next_Player: 				; Dealer has dealt to player 1, move on to next
	movf	posdelta, W, A
   	addwf	PR2, F, A		; Move servo to next player position
	movff	timerH, TMR0H, A
	movff	timerL, TMR0L, A	; Set time for servo to rotate (DCM wait)
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
	goto    User_Input
