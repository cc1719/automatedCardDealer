#include <xc.inc>

global  divide

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
    
divide:		; arg1 + arg2 should equal one of the products of the 16 bit.
		movlw   100
		movwf   arg1, 0
		movlw   100
		movwf   arg2, 0
		movlw   155
		movwf   arg3, 0
		movff	numPlayers, divisor, A
		movlw   0
		movwf   output, 0
    	        movf    arg1, 0, 0
		cpfsgt  divisor, 0
		goto    continue1
		goto    end1
continue1:	movf    divisor, 0, 0
		subwf   arg1, 1, 0
		incf    output, 1, 0
		movf    arg1, 0, 0
		cpfsgt  divisor, 0
		goto    continue1
end1:		movwf   remainder1, 0	
    
		movf    arg2, 0, 0
		cpfsgt  divisor, 0
		goto    continue2
		goto    end2
continue2:	movf    divisor, 0, 0
		subwf   arg2, 1, 0
		incf    output, 1, 0
		movf    arg2, 0, 0
		cpfsgt  divisor, 0
		goto    continue2
end2:		movwf   remainder2, 0
		
		movf    remainder1, 0, 0
		addwf   remainder2, 0, 0
		cpfsgt  divisor, 0
		incf    output, 1, 0
		
		movf    arg3, 0, 0
		mulwf   output, 0
		
		return

divide2:		
		movlw   100
		movwf   arg1, 0
		movlw   100
		movwf   arg2, 0
		movff	numPlayers, divisor, A
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