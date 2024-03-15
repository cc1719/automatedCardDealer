#include <xc.inc>
    
psect	udata_acs
arg1L:	 ds 1
arg1H:	 ds 1
arg2L:	 ds 1
arg2H:	 ds 1
result0: ds 1
result1: ds 1
result2: ds 1
result3: ds 1
test:	 ds 1

global  test
    
psect	code, abs
	
rst:	org	0x0

multiply:
	movlw  100
	movwf  test, A
	goto  $
;	movf  arg1L, 0, 0
;	mulwf arg2L, 0
;	movff PRODH, result1
;	movff PRODL, result0 
;
;	movf  arg1H, 0, 0
;	MULWF ARG2H ; ARG1H * ARG2H->
;; PRODH:PRODL
;	MOVFF PRODH, RES3 ;
;	MOVFF PRODL, RES2 ;
;;
;	MOVF ARG1L, W
;	MULWF ARG2H ; ARG1L * ARG2H->
;; PRODH:PRODL
;	MOVF PRODL, W ;
;	ADDWF RES1, F ; Add cross
;	MOVF PRODH, W ; products
;	ADDWFC RES2, F ;
;	CLRF WREG ;
;	ADDWFC RES3, F ;
;;
;	MOVF ARG1H, W ;
;	MULWF ARG2L ; ARG1H * ARG2L->
;; PRODH:PRODL
;	MOVF PRODL, W ;
;	ADDWF RES1, F ; Add cross
;	MOVF PRODH, W ; products
;	ADDWFC RES2, F ;
;	CLRF WREG ;
;	ADDWFC RES3, F ;

	end	rst
