#include <xc.inc>

extrn	Servo_Setup, Servo_Start

global	rottime, timerH, timerL    

psect	udata_acs   ; named variables in access ram
    delL:	ds 1	
    delH:	ds 1	
    delI:	ds 1
    timerH:	ds 1
    timerL:	ds 1
    rottimeL:	ds 1
    rottimeH:	ds 1
    NUMERATOR:	ds 1
    DENOMINATOR:ds 1
    BitCount:	ds 1
    Remainder:	ds 1
    
PSECT	udata_acs_ovr,space=1,ovrld,class=COMRAM
	rottime	EQU 32000	; LCD enable bit
    
psect	code, abs
	
rst:	org	0x0
	goto	setup

int_hi:	
	org	0x0008	; high vector, no low vector
	goto	Servo_Start
	
setup:	
	movlw	0xff
	movwf	timerL
	movlw	0xff
	movwf	timerH
	movlw	low(rottime)
	subwf	timerL, F, A
	movlw	high(rottime)
	subwfb	timerH, F, A
	call	Servo_Setup
	bcf	TRISD, 4, A
	bcf	PORTD, 4, A
    
main:
	bsf	PORTD, 4, A
	call	startservo
	movlw	0xff
	movwf	delL, A
	movlw	0xff
	movwf	delH, A
	movlw	0x7f
	movwf	delI, A
	call	bigdelay
	goto	main  
startservo:
	bsf	TMR3ON
	movff	timerH, TMR0H
	movff	timerL, TMR0L
	bsf	TMR0ON
	return
	
bigdelay:
    movlw   0x0
dloop:    
    decf    delL, F, A
    subwfb  delH, F, A
    subwfb  delI, F, A
    bc	    dloop
    return
    
	end	rst