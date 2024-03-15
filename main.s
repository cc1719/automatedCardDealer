#include <xc.inc>
    
psect	udata_acs
arg1:	 ds 1
arg2:	 ds 1
output:   ds 1
remainder1: ds 1
remainder2: ds 1
divisor: ds 1

global  test
    
psect	code, abs
	
rst:	org	0x0

divide:	;arg1 + arg2 should equal the 16 bit number to be divided.
		movf    arg1, 0, 0
		cpfslt  divisor, 0
		goto    continue1
		goto    end1
continue1:	movf    divisor, 0, 0
		subwf   arg1, 1, 0
		incf    output, 1, 0
		movf    arg1, 0, 0
		cpfslt  divisor, 0
		goto    continue1
end1:		movwf   remainder1, 0	
    
		movf    arg2, 0, 0
		cpfslt  divisor, 0
		goto    continue2
		goto    end2
continue2:	movf    divisor, 0, 0
		subwf   arg2, 1, 0
		incf    output, 1, 0
		movf    arg2, 0, 0
		cpfslt  divisor, 0
		goto    continue2
end2:		movwf   remainder2, 0
		
		movf    remainder1, 0, 0
		addwf   remainder2, 0, 0
		cpfslt  divisor, 0
		incf    output, 1, 0
		return
		
		end	rst
