	#include <xc.inc>

psect	code, abs
	
main:
	org	0x0
	goto	start

	org	0x100		    ; Main code starts here at address 0x100
start:
	movlw	0xff
	movwf	TRISD, A
	movlw 	0x0
	movwf	TRISC, A	    ; Port C all outputs
	bra 	test
loop:
	incf 	0x06, W, A
	movff 	0x06, PORTC
test:
	movwf	0x06, A	    ; Test for end of loop condition
	movf	PORTD, W, A
	cpfsgt 	0x06, A
	bra 	loop		    ; Not yet finished goto start of loop again
	goto 	0x0		    ; Re-run program from start

	end	main