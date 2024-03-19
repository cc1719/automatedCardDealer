#include <xc.inc>

extrn   resetVar, Write_Y_Or_N, LCD_delay_ms, LCD_clear, LCD_Write_Message, LCD_line2, LCD_Setup, KeyPad_Setup, Check_KeyPress, KeyPad_Value, KeyPad_Output, writeNumPlayers, writeNumCards, numPlayers, numCardsDigit1, numCardsDigit2
global  Settings_Setup, Settings_Input, count1, count2, numPlayers, numCards, Reset_Settings
psect	udata_acs  
counter:        ds  1
count1:		ds  1
count2:		ds  1
count3:		ds  1
numCards:	ds  1
 
psect		settings_code, class = CODE

Stored_Message1: db     'Enter no players'
		message1  EQU 0x240
Stored_Message2: db     'Enter no cards'
		message2  EQU 0x250
Stored_Message3: db     'Re-deal? 1-Y 2-N'
		message3  EQU 0x260
  
Settings_Setup:	call    KeyPad_Setup
		call    LCD_Setup
		return
		
Read_Prompt1:	lfsr    2, message1
		movlw   low highword(Stored_Message1)
		movwf   TBLPTRU, A
		movlw   high(Stored_Message1)
		movwf   TBLPTRH, A
		movlw   low(Stored_Message1)
		movwf   TBLPTRL, A
		movlw   17
		movwf   count1,  A
		movwf   counter, A
loop1:		tblrd*+
		movff   TABLAT, POSTINC2
		decfsz  counter, A
		goto    loop1
		return

Read_Prompt2:	lfsr    2, message2
		movlw   low highword(Stored_Message2)
		movwf   TBLPTRU, A
		movlw   high(Stored_Message2)
		movwf   TBLPTRH, A
		movlw   low(Stored_Message2)
		movwf   TBLPTRL, A
		movlw   14
		movwf   count2,  A
		movwf   counter, A
loop2:		tblrd*+
		movff   TABLAT, POSTINC2
		decfsz  counter, A
		goto    loop2
		return    

Read_Prompt3:	lfsr    2, message3
		movlw   low highword(Stored_Message3)
		movwf   TBLPTRU, A
		movlw   high(Stored_Message3)
		movwf   TBLPTRH, A
		movlw   low(Stored_Message3)
		movwf   TBLPTRL, A
		movlw   11
		movwf   count3,  A
		movwf   counter, A
loop3:		tblrd*+
		movff   TABLAT, POSTINC2
		decfsz  counter, A
		goto    loop3
		return    

Settings_Input:	call    LCD_clear
		call    Read_Prompt1
		movf    count1, 0, 0
		lfsr    2, message1
		call    LCD_Write_Message
		call    LCD_line2
		call    writeNumPlayers	
		movlw   100
		call    LCD_delay_ms
		call    LCD_clear
		call    Read_Prompt2
		movf    count2, 0, 0
		lfsr    2, message2
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
		movf    count3, 0, 0
		lfsr    2, message3
		call    LCD_Write_Message
		call    LCD_line2
		call    Write_Y_Or_N
		movlw   100
		call    LCD_delay_ms
		return