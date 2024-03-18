#include <xc.inc>
 
;psect	udata_acs  
;message:	ds  1
;counter:        ds  1
 
psect		settings_code, class = CODE

storedMessages: ;bcf     CFGS
		;bsf	EEPGD
		;db      'Enter no players'
		;db      'Enter no cards'
		;messages EQU 0x20
		;align	 2

readMessage:    ;lfsr    0, messages
		;movlw   low highword(storedMessages)
		;movwf   TBLPTRU, A
		;movlw   high(storedMessages)
		;movwf   TBLPTRH, A
		;movlw   low(storedMessages)
		;movwf   TBLPTRL, A
		;movlw   10
		;movwf   counter, A
loop:		;tblrd*+
		;movff   TABLAT, POSTINC0
		;decfsz  counter, A
		;bra     loop
		return



