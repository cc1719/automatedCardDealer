#include <xc.inc>
	
global	timer2, KeyPad_Value
extrn   Check_KeyPress
    
psect	udata_acs  
resetVar:   ds 1
    
psect	dac_code, class=CODE

timer2:	 ;   btfss   TMR2IF
	  ;  retfie  f
	   ; call    Check_KeyPress
	    ;movff   KeyPad_Value, resetVar
	    ;movlw   01000101B
	    ;cpfseq  resetVar
	    ;goto    noResetSection
	    ;goto    resetSection    
;noResetSection:	    bcf     TMR2IF
		 ;   retfie  f
;resetSection:	    bcf     TMR2IF
		  ;  goto    0x0
		    