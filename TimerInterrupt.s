#include <xc.inc>
	
global	Timer0  

psect	udata_acs   ; reserve data space in access ram
counterH: ds  1	  
counterL: ds  1
    
psect	dac_code, class=CODE

Timer0:
;    btfsc	TMR1IF
;    goto	Timer1
    btfss	TMR0IF		; CHANGE BACK TO TMR0IF
    retfie	f		; if not then return
    setf	PORTD
;    bsf		TMR1ON
    bcf		TMR0IF		; CHANGE BACK TO TMR0IF
    movlw	0xc0		; 0xc0 for 20ms TMR0
    movwf	TMR0L		; CHANGE BACK TO TMR0L
    movlw	0x63		; 0x63 for 20ms TMR0
    movwf	TMR0H		; CHANGE BACK TO TMR0H
    movlw	0xff
    movwf	counterL, A
    movlw	0x05
    movwf	counterH, A
    call	delay
    retfie	f

Timer1:
    clrf    PORTD
    bcf	    TMR1ON
    bcf	    TMR1IF
    clrf    TMR1L
    clrf    TMR1H
    retfie  f
    
delay:
	movlw	0x0
dloop:
	decf	counterL, F, A
	subwfb	counterH, F, A
	bc	dloop
	return
	