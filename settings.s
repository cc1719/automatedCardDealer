#include <xc.inc>

extrn   LCD_delay_ms, LCD_clear, LCD_Write_Message, LCD_line2, LCD_Setup, KeyPad_Setup, Check_KeyPress, KeyPad_Value, KeyPad_Output, writeNumPlayers, writeNumCards, numPlayersDigit1, numPlayersDigit2, numCardsDigit1, numCardsDigit2
global  settingsInput, count1, count2, numPlayers, numCards
psect	udata_acs  
counter:        ds  1
count1:		ds  1
count2:		ds  1
numPlayers:	ds  1
numCards:	ds  1
 
psect		settings_code, class = CODE

storedMessage1: db     'Enter no players'
		message1  EQU 0x240
storedMessage2: db     'Enter no cards'
		message2  EQU 0x250
readPrompt1:	lfsr    2, message1
		movlw   low highword(storedMessage1)
		movwf   TBLPTRU, A
		movlw   high(storedMessage1)
		movwf   TBLPTRH, A
		movlw   low(storedMessage1)
		movwf   TBLPTRL, A
		movlw   17
		movwf   count1,  A
		movwf   counter, A
loop1:		tblrd*+
		movff   TABLAT, POSTINC2
		decfsz  counter, A
		goto    loop1
		return

readPrompt2:	lfsr    2, message2
		movlw   low highword(storedMessage2)
		movwf   TBLPTRU, A
		movlw   high(storedMessage2)
		movwf   TBLPTRH, A
		movlw   low(storedMessage2)
		movwf   TBLPTRL, A
		movlw   14
		movwf   count2,  A
		movwf   counter, A
loop2:		tblrd*+
		movff   TABLAT, POSTINC2
		decfsz  counter, A
		goto     loop2
		return    

settingsInput:	call    LCD_Setup
		call    LCD_clear
		call    readPrompt1
		movf    count1, 0, 0
		lfsr    2, message1
		call    LCD_Write_Message
		call    LCD_line2
		call    writeNumPlayers	
		movlw   100
		call    LCD_delay_ms
		call    LCD_clear
		call    readPrompt2
		movf    count2, 0, 0
		lfsr    2, message2
		call    LCD_Write_Message
		call    LCD_line2
		call    writeNumCards	
		movlw   100
		call    LCD_delay_ms
		call    LCD_clear
		
		movlw   0xff
		cpfseq  numPlayersDigit2, 0
		goto    twoDigitPlayers	
		movlw   48
		subwf   numPlayersDigit1, 0, 0
		movwf   numPlayers, A
		goto    skip
twoDigitPlayers:movlw   48
		subwf   numPlayersDigit1, 1, 0
		movlw   10
		mulwf   numPlayersDigit1, 0
		movff   PRODL, numPlayers
		movlw   48
		subwf   numPlayersDigit2, 0, 0
		addwf   numPlayers, 1, 0
		
skip:		movlw   0xff
		cpfseq  numCardsDigit2, 0
		goto    twoDigitCards	
		movlw   48
		subwf   numCardsDigit1, 0, 0
		movwf   numCards, A
		return
		
twoDigitCards:	movlw   48
		subwf   numCardsDigit1, 1, 0
		movlw   10
		mulwf   numCardsDigit1, 0
		movff   PRODL, numCards
		movlw   48
		subwf   numCardsDigit2, 0, 0
		addwf   numCards, 1, 0
		return


