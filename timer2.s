#include <xc.inc>
	
global	timer2, KeyPad_Value, timer2Setup
extrn   Check_KeyPress, KeyPad_Setup, main
global  resetVar
psect	udata_acs  
resetVar:   ds 1
    
psect	dac_code, class=CODE

timer2Setup:
	    movlw   01111010B
	    movwf   T2CON, A
	    call    KeyPad_Setup
	    return
	    
timer2:	    btfss   TMR2IF
	    retfie  f
	    call    Check_KeyPress
	    movff   KeyPad_Value, resetVar
	    movlw   01000101B
	    cpfseq  resetVar, 0
	    goto    noResetSection
	    goto    resetSection    
noResetSection:	    bcf     TMR2IF
		    retfie  f
resetSection:	    bcf     TMR2IF
		    goto    main
		  
		    