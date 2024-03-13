#include <xc.inc>

extrn   LCD_clear, LCD_Write_Message, LCD_line2, LCD_Setup, KeyPad_Setup, Check_KeyPress, KeyPad_Value, KeyPad_Output, writeNumPlayers, writeNumCards, numPlayersDigit1, numPlayersDigit2, numCardsDigit1, numCardsDigit2
global  settingsInput, msg1, msg2, message1, message2
psect	udata_acs  
counter:        ds  1
msg1:		ds  1
msg2:		ds  1
message1:	ds  1
message2:	ds  1
count1:		ds  1
count2:		ds  1
 
psect		settings_code, class = CODE

storedMessage1: db     'Enter no players'
storedMessage2: db     'Enter no cards'
readPrompt1:	movlw   0x20
		movwf   msg1, A	
		movwf   message1, A	
		lfsr    2, message1
		movlw   low highword(storedMessage1)
		movwf   TBLPTRU, A
		movlw   high(storedMessage1)
		movwf   TBLPTRH, A
		movlw   low(storedMessage1)
		movwf   TBLPTRL, A
		movlw   17
		movwf   count1, 0
		movwf   counter, A
loop1:		tblrd*+
		movff   TABLAT, POSTINC2
		decfsz  counter, A
		bra     loop1
		return

readPrompt2:	movlw   0x40
		movwf   msg2, A
		movwf   message2, A	
		lfsr    2, message2
		movlw   low highword(storedMessage2)
		movwf   TBLPTRU, A
		movlw   high(storedMessage2)
		movwf   TBLPTRH, A
		movlw   low(storedMessage2)
		movwf   TBLPTRL, A
		movlw   15
		movwf   count2, 0
		movwf   counter, A
loop2:		tblrd*+
		movff   TABLAT, POSTINC2
		decfsz  counter, A
		bra     loop2
		return    

settingsInput:	call    LCD_Setup
		call    LCD_clear
		call    readPrompt1
		movf    count1, 0, 0
		lfsr    2, msg1
		call    LCD_Write_Message
		call    LCD_line2
		call    writeNumPlayers	
		
		call    readPrompt2
		movf    count2, 0, 0
		call    LCD_Write_Message
		call    LCD_line2
		call    writeNumCards	
		return

