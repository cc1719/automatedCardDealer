#include <xc.inc>

extrn   resetVar, Write_Y_Or_N, LCD_delay_ms, LCD_clear, LCD_Write_Message, LCD_line2, LCD_Setup, KeyPad_Setup, Check_KeyPress, KeyPad_Value, KeyPad_Output, writeNumPlayers, writeNumCards, numPlayers, numCardsDigit1, numCardsDigit2
global  Settings_Setup, Settings_Input, numPlayers, numCards, Reset_Settings
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
Stored_Message3: db     'Re-deal? 1-Y 2-N'
		messageLocation3  EQU 0x260
Stored_Message4: db     'Dealing...'
		messageLocation4  EQU 0x270
  
Settings_Setup:	call    KeyPad_Setup
		call    LCD_Setup
		return
		
Read_Prompt:	lfsr    2, messageLocation
		movlw   low highword(message)
		movwf   TBLPTRU, A
		movlw   high(message)
		movwf   TBLPTRH, A
		movlw   low(message)
		movwf   TBLPTRL, A
loop:		tblrd*+
		movff   TABLAT, POSTINC2
		decfsz  counter, A
		goto    loop
		return

Settings_Input:	call    LCD_clear
		movlw   17
		movwf   count, 0
		movwf   counter, 0
		movff   messageLocation1, messageLocation
		movff   Stored_Message1, message
		call    Read_Prompt
		movf    count, 0, 0
		lfsr    2, messageLocation1
		call    LCD_Write_Message
		call    LCD_line2
		call    writeNumPlayers	
		movlw   100
		call    LCD_delay_ms
		call    LCD_clear
		movlw   14
		movwf   count, 0
		movwf   counter, 0
		movff   messageLocation2, messageLocation
		movff   Stored_Message2, message
		call    Read_Prompt
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
		movlw   11
		movwf   count, 0
		movwf   counter, 0
		movff   messageLocation3, messageLocation
		movff   Stored_Message3, message
		call    Read_Prompt
		movf    count, 0, 0
		lfsr    2, messageLocation3
		call    LCD_Write_Message
		call    LCD_line2
		call    Write_Y_Or_N
		movlw   100
		call    LCD_delay_ms
		return