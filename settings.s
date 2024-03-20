#include <xc.inc>

extrn   Write_Reset, LCD_delay_ms, LCD_clear, LCD_Write_Message, LCD_line2, LCD_Setup, KeyPad_Setup, writeNumPlayers, writeNumCards, numCardsDigit1, numPlayers, numCardsDigit2
global  Settings_Setup, Settings_Input, numCards, Reset_Settings, Dealing_Message, count, Read_Prompt1, Read_Prompt2, messageLocation1, messageLocation2
psect	udata_acs  
counter:        ds  1
count:		ds  1
messageLocation:	ds  1
message:	ds  1
numCards:	ds  1
 
psect		settings_code, class = CODE

Stored_Message1: db     'Enter no players'
		messageLocation1  EQU 0x240
Stored_Message2: db     'Enter no cards'
		messageLocation2  EQU 0x250
Stored_Message3: db     '1 to re-deal'
		messageLocation3  EQU 0x260
Stored_Message4: db     'Dealing...'
		messageLocation4  EQU 0x270
  
Settings_Setup:	call    KeyPad_Setup
		call    LCD_Setup
		return
		
Read_Prompt1:	lfsr    2, messageLocation1
		movlw   low highword(Stored_Message1)
		movwf   TBLPTRU, A
		movlw   high(Stored_Message1)
		movwf   TBLPTRH, A
		movlw   low(Stored_Message1)
		movwf   TBLPTRL, A
		movlw   17
		movwf   count, 0
		movwf   counter, 0
loop1:		tblrd*+
		movff   TABLAT, POSTINC2
		decfsz  counter, A
		goto    loop1
		return

Read_Prompt2:	lfsr    2, messageLocation2
		movlw   low highword(Stored_Message2)
		movwf   TBLPTRU, A
		movlw   high(Stored_Message2)
		movwf   TBLPTRH, A
		movlw   low(Stored_Message2)
		movwf   TBLPTRL, A
		movlw   14
		movwf   count, 0
		movwf   counter, 0
loop2:		tblrd*+
		movff   TABLAT, POSTINC2
		decfsz  counter, A
		goto    loop2
		return
		
Read_Prompt3:	lfsr    2, messageLocation3
		movlw   low highword(Stored_Message3)
		movwf   TBLPTRU, A
		movlw   high(Stored_Message3)
		movwf   TBLPTRH, A
		movlw   low(Stored_Message3)
		movwf   TBLPTRL, A
		movlw   16
		movwf   count, 0
		movwf   counter, 0
loop3:		tblrd*+
		movff   TABLAT, POSTINC2
		decfsz  counter, A
		goto    loop3
		return

Read_Prompt4:	lfsr    2, messageLocation4
		movlw   low highword(Stored_Message4)
		movwf   TBLPTRU, A
		movlw   high(Stored_Message4)
		movwf   TBLPTRH, A
		movlw   low(Stored_Message4)
		movwf   TBLPTRL, A
		movlw   10
		movwf   count, 0
		movwf   counter, 0
loop4:		tblrd*+
		movff   TABLAT, POSTINC2
		decfsz  counter, A
		goto    loop4
		return

Settings_Input:	call    LCD_clear
		call    Read_Prompt1
		movf    count, 0, 0
		lfsr    2, messageLocation1
		call    LCD_Write_Message
		call    LCD_line2
		call    writeNumPlayers	
		movlw   100
		call    LCD_delay_ms
		call    LCD_clear
		call    Read_Prompt2
		movf    count, 0, 0
		lfsr    2, messageLocation2
		call    LCD_Write_Message
		call    LCD_line2
		call    writeNumCards	
		movlw   100
		call    LCD_delay_ms
		call    LCD_clear
		
		movlw   48
		subwf   numPlayers, 1, 0
		
		movlw   0xff
		cpfseq  numCardsDigit2, 0
		goto    Two_Digit_Cards	
		movlw   48
		subwf   numCardsDigit1, 0, 0
		movwf   numCards, A
		return
		
Two_Digit_Cards:	movlw   48
		subwf   numCardsDigit1, 1, 0
		movlw   10
		mulwf   numCardsDigit1, 0
		movff   PRODL, numCards
		movlw   48
		subwf   numCardsDigit2, 0, 0
		addwf   numCards, 1, 0
		return

Reset_Settings:	call    LCD_clear
		call    Read_Prompt3
		movf    count, 0, 0
		lfsr    2, messageLocation3
		call    LCD_Write_Message
		call    LCD_line2
		call    Write_Reset
		movlw   100
		call    LCD_delay_ms
		return
		
Dealing_Message:
		call    LCD_clear
		call    Read_Prompt4
		movf    count, 0, 0
		lfsr    2, messageLocation4
		call    LCD_Write_Message
		return