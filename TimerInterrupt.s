#include <xc.inc>
	
global	Timer1, timeH, timeL
    
psect	udata_acs   ; reserve data space in access ram
timeH: ds   1	    ; reserve 1 byte for variable UART_counter
timeL: ds   1    
    
psect	dac_code, class=CODE


Timer1:
    btfss	TMR0IF		; check that this is timer0 interrupt
    retfie	f		; if not then return
    movlw	0xff
    movwf	PORTD
    call	bigdelay
    bcf		TMR0IF	
    retfie	f

bigdelay:
    movlw   0x0
dloop:
    decf    timeL, F, A
    subwfb  timeH, F, A
    bc	    dloop
    return