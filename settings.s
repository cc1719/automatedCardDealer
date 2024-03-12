#include <xc.inc>

extrn   LCD_Write_Message, LCD_line2
    
psect	udata_acs  
counter:        ds  1
 
psect		settings_code, class = CODE

storedMessage1: ;bcf     CFGS
		;bsf	EEPGD
		db      'Enter no players'
		message1 EQU 0x20
		align	 2

storedMessage2: db      'Enter no cards'
		message2 EQU 0x40
		align	 2

readPrompt1:	lfsr    2, message1
		movlw   low highword(storedMessage1)
		movwf   TBLPTRU, A
		movlw   high(storedMessage1)
		movwf   TBLPTRH, A
		movlw   low(storedMessage1)
		movwf   TBLPTRL, A
		movlw   20
		movwf   counter, A
loop1:		tblrd*+
		movff   TABLAT, POSTINC2
		decfsz  counter, A
		bra     loop1
		return

readPrompt2:	lfsr    2, message2
		movlw   low highword(storedMessage2)
		movwf   TBLPTRU, A
		movlw   high(storedMessage2)
		movwf   TBLPTRH, A
		movlw   low(storedMessage2)
		movwf   TBLPTRL, A
		movlw   14
		movwf   counter, A
loop2:		tblrd*+
		movff   TABLAT, POSTINC2
		decfsz  counter, A
		bra     loop2
		return
		
int_hi:         org     0x0008
		goto    timer4

timer4:		btfss   TMR4IF
		retfie  f
		
		
		
settingsInput:  call    readPrompt1
		movf    counter, 0
		call    LCD_Write_Message
		call    LCD_line2
		goto    $
continue1:	
		
