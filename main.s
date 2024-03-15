#include <xc.inc>
    
psect	udata_acs
arg1:	 ds 1
arg2:	 ds 1
count:   ds 1
remainder1: ds 1
remainder2: ds 1
divisor: ds 1
test:	 ds 1

global  test
    
psect	code, abs
	
rst:	org	0x0

divide:	;arg1 + arg2 should equal the 16 bit number to be divided.
	movf    divisor, 0, 0
	subwf   arg1, 1, 0
	tst

	end	rst
