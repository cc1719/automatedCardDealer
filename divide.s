#include <xc.inc>

global  divide, output, divide16bit

extrn numPlayers, timerL, timerH
    
psect	udata_acs
arg1:	 ds 1 
arg2:	 ds 1 
arg3:	 ds 1
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
		cpfseq	numPlayers, 0          ; Checks if divisor will be 1, if not subtract one from it.
		subwf	numPlayers, W, A
		movwf	divisor, A
		movlw   0
		movwf   output, 0
    	        movf    arg1, 0, 0
		cpfsgt  divisor, 0
		goto    next1
		goto    end1
next1:		movf    divisor, 0, 0		; Subtracts divisor from arg1 until arg1 is less than divisor, while counting how many times this is done in output.
		subwf   arg1, 1, 0
		incf    output, 1, 0
		movf    arg1, 0, 0
		cpfsgt  divisor, 0
		goto    next1
end1:		movwf   remainder1, 0	
    
		movf    arg2, 0, 0		; Same for arg2.
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
		cpfsgt  divisor, 0		; Check if total remainder is greater than divisor, and if so add one to output.
		incf    output, 1, 0
		
		return
		
divide16bit:    ; divides the number (arg1+arg2)*arg3 by divisor, result is in PRODH and PRODL. Works same as above, so dividing arg1 and arg2 by divisor, then multiplies result by arg3
		; to get result of the division of the 16 bit number.
		movlw   100
		movwf   arg1, 0
		movlw   157
		movwf   arg2, 0
		movlw   255
		movwf   arg3, 0
		movff   numPlayers, divisor, A
		movlw	0x01
		cpfseq	numPlayers, 0
		subwf	numPlayers, W, A
		movwf	divisor, A
		movlw   0
		movwf   output, 0
    	        movf    arg1, 0, 0
		cpfsgt  divisor, 0
		goto    next3
		goto    end3
next3:		movf    divisor, 0, 0
		subwf   arg1, 1, 0
		incf    output, 1, 0
		movf    arg1, 0, 0
		cpfsgt  divisor, 0
		goto    next3
end3:		movwf   remainder1, 0	
    
		movf    arg2, 0, 0
		cpfsgt  divisor, 0
		goto    next4
		goto    end4
next4:		movf    divisor, 0, 0
		subwf   arg2, 1, 0
		incf    output, 1, 0
		movf    arg2, 0, 0
		cpfsgt  divisor, 0
		goto    next4
end4:		movwf   remainder2, 0
		
		movf    remainder1, 0, 0
		addwf   remainder2, 0, 0
		cpfsgt  divisor, 0
		incf    output, 1, 0
		
		movf    output, 0, 0
		mulwf   arg3, A
		
		movlw	0xff
		movwf	timerL, A
		movwf	timerH, A
		movf	PRODL, W, A
		subwf	timerL, F, A
		movf	PRODH, W, A
		subwfb	timerH, F, A
		clrf	PRODL, A
		clrf	PRODH, A
		
		return
