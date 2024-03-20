#include <xc.inc>

global  divide, output

extrn numPlayers
    
psect	udata_acs
arg1:	 ds 1 
arg2:	 ds 1 
output:   ds 1
remainder1: ds 1
remainder2: ds 1
divisor: ds 1

psect		divide_code, class = CODE
    
divide:    ; divides (arg1+arg2) by numPlayers, result in output.
		movlw   100
		movwf   arg1, 0
		movlw   100
		movwf   arg2, 0
		movlw	0x01
		cpfseq	numPlayers, 0
		subwf	numPlayers, W, A
		movwf	divisor, A
		movlw   0
		movwf   output, 0
    	        movf    arg1, 0, 0
		cpfsgt  divisor, 0
		goto    next1
		goto    end1
next1:		movf    divisor, 0, 0
		subwf   arg1, 1, 0
		incf    output, 1, 0
		movf    arg1, 0, 0
		cpfsgt  divisor, 0
		goto    next1
end1:		movwf   remainder1, 0	
    
		movf    arg2, 0, 0
		cpfsgt  divisor, 0
		goto    next2
		goto    end2
next2:		movf    divisor, 0, 0
		subwf   arg2, 1, 0
		incf    output, 1, 0
		movf    arg2, 0, 0
		cpfsgt  divisor, 0
		goto    next2
end2:		movwf   remainder2, 0
		
		movf    remainder1, 0, 0
		addwf   remainder2, 0, 0
		cpfsgt  divisor, 0
		incf    output, 1, 0
		
		return
