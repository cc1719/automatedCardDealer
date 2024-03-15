#include <xc.inc>
    
psect	udata_acs
arg1L:	 ds 1
arg1L:	 ds 1
arg1L:	 ds 1
arg1L:	 ds 1
result1: ds 1
result2: ds 1
result3: ds 1
result4: ds 1
    
psect	code, abs
	
rst:	org	0x0

multiply:
	MOVF ARG1L, W
	MULWF ARG2L ; ARG1L * ARG2L->
; PRODH:PRODL
	MOVFF PRODH, RES1 ;
	MOVFF PRODL, RES0 ;
;
	MOVF ARG1H, W
	MULWF ARG2H ; ARG1H * ARG2H->
; PRODH:PRODL
	MOVFF PRODH, RES3 ;
	MOVFF PRODL, RES2 ;
;
	MOVF ARG1L, W
	MULWF ARG2H ; ARG1L * ARG2H->
; PRODH:PRODL
	MOVF PRODL, W ;
	ADDWF RES1, F ; Add cross
	MOVF PRODH, W ; products
	ADDWFC RES2, F ;
	CLRF WREG ;
	ADDWFC RES3, F ;
;
	MOVF ARG1H, W ;
	MULWF ARG2L ; ARG1H * ARG2L->
; PRODH:PRODL
	MOVF PRODL, W ;
	ADDWF RES1, F ; Add cross
	MOVF PRODH, W ; products
	ADDWFC RES2, F ;
	CLRF WREG ;
	ADDWFC RES3, F ;

	end	rst
