#include <xc.inc>

global  settingsInput
    
psect	udata_acs  
message:	ds  1
counter:        ds  1
 
psect		settings_code, class = CODE

storedMessages: ;bcf     CFGS
		;bsf	EEPGD
		db      'Enter no players'
		db      'Enter no cards'
		messages EQU 0x20
		align	 2

settingsInput:  
    
outputPrompt1:	lfsr    2, messages
		movlw   low highword(storedMessages)
		movwf   TBLPTRU, A
		movlw   high(storedMessages)
		movwf   TBLPTRH, A
		movlw   low(storedMessages)
		movwf   TBLPTRL, A
		movlw   20
		movwf   counter, A
loop:		tblrd*+
		movff   TABLAT, POSTINC2
		decfsz  counter, A
		bra     loop
		return


