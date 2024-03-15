#include <xc.inc>
   
extrn   output, arg1, arg2, arg3, divisor, divide
    
psect	code, abs
	
rst:	org	0x0

main:	movlw   140
	movwf   arg1, 0
	movlw   109
	movwf   arg2, 0
	movlw   227
	movwf   arg3, 0
	movlw   5
	movwf   divisor, 0
	call    divide	
	nop		
	end	rst
