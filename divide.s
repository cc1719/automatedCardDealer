#include <xc.inc>

global  divide2, output
;b
extrn numPlayers
    
psect	udata_acs
arg1:	 ds 1 
arg2:	 ds 1 ; arg1 + arg2 should equal one factor of the total number to be divided - max = 510, dont divide by 1.
arg3:	 ds 1 ; arg3 should equal the other factor (max 8 bit).
output:   ds 1
remainder1: ds 1
remainder2: ds 1
divisor: ds 1

psect		divide_code, class = CODE
    
divide2:    ; divides (arg1+arg2) by numPlayers, result in output.
		movlw   100
		movwf   arg1, 0
		movlw   100
		movwf   arg2, 0
		movlw	0x01
		subwf	numPlayers, W, A
		movwf	divisor, A
		movlw   0
		movwf   output, 0
    	        movf    arg1, 0, 0
		cpfsgt  divisor, 0
		goto    continue3
		goto    end3
continue3:	movf    divisor, 0, 0
		subwf   arg1, 1, 0
		incf    output, 1, 0
		movf    arg1, 0, 0
		cpfsgt  divisor, 0
		goto    continue3
end3:		movwf   remainder1, 0	
    
		movf    arg2, 0, 0
		cpfsgt  divisor, 0
		goto    continue4
		goto    end4
continue4:	movf    divisor, 0, 0
		subwf   arg2, 1, 0
		incf    output, 1, 0
		movf    arg2, 0, 0
		cpfsgt  divisor, 0
		goto    continue4
end4:		movwf   remainder2, 0
		
		movf    remainder1, 0, 0
		addwf   remainder2, 0, 0
		cpfsgt  divisor, 0
		incf    output, 1, 0
		
		return
