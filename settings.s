#include <xc.inc>

extrn   LCD_Write_Message, LCD_line2, LCD_Setup, KeyPad_Setup, Check_KeyPress, KeyPad_Value, KeyPad_Output, writeNumPlayers, writeNumCards, numPlayersDigit1, numPlayersDigit2, numCardsDigit1, numCardsDigit2
global  settingsInput
psect	udata_acs  
counter:        ds  1
 
psect		settings_code, class = CODE

storedMessage1: db     'Enter no players'
		message1 EQU 0x400

storedMessage2: db     'Enter no cards'
		message2 EQU 0x40

readPrompt1:	
		lfsr    2, message1
		movlw   low highword(storedMessage1)
		movwf   TBLPTRU, A
		movlw   high(storedMessage1)
		movwf   TBLPTRH, A
		movlw   low(storedMessage1)
		movwf   TBLPTRL, A
		movlw   17
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
		movlw   15
		movwf   counter, A
loop2:		tblrd*+
		movff   TABLAT, POSTINC2
		decfsz  counter, A
		bra     loop2
		return    

settingsInput:	call    readPrompt1
		movf    counter, 0, 0
		call    LCD_Write_Message
		call    LCD_line2
		call    writeNumPlayers	
		
		call    readPrompt2
		movf    counter, 0, 0
		call    LCD_Write_Message
		call    LCD_line2
		call    writeNumCards	
		return

