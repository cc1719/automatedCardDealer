#include <xc.inc>

extrn   Write_Reset, LCD_delay_ms, LCD_clear, LCD_Write_Message, LCD_line2, LCD_Setup, KeyPad_Setup, writeNumPlayers, writeNumCards, numCardsDigit1, numPlayers, numCardsDigit2, testVar
global  Settings_Input, numCards, Reset_Settings, Dealing_Message, count, Read_Prompt1, Read_Prompt2, messageLocation1, messageLocation2
psect	udata_acs  
counter:        ds  1
count:		ds  1
messageLocation:	ds  1
message:	ds  1
numCards:	ds  1
 
psect		settings_code, class = CODE

Stored_Message1: db     'Enter no Players'	; Stores the various messages to output on the LCD in program memory
		messageLocation1  EQU 0x240	; These variables are the desired location in data memory
Stored_Message2: db     'Enter no Cards'
		messageLocation2  EQU 0x250
Stored_Message3: db     '1 to Restart'
		messageLocation3  EQU 0x260
Stored_Message4: db     'Dealing...'
		messageLocation4  EQU 0x270
							; These read the corresponding message from program memory, and copy them into data memory
Read_Prompt1:	lfsr    2, messageLocation1		; Loads file select register 2 with desired location in data memory for this prompt    
		movlw   low highword(Stored_Message1)	; Sets three bytes which point to table in program memory
		movwf   TBLPTRU, A
		movlw   high(Stored_Message1)
		movwf   TBLPTRH, A
		movlw   low(Stored_Message1)
		movwf   TBLPTRL, A
		movlw   17
		movwf   count, 0			; Remembers how long message was in count variable for use later
		movwf   counter, 0			; Also sets a counter which will stop the tblrd*+ function from continuing
loop1:		tblrd*+					; to read from program memory once the full message has been read
		movff   TABLAT, POSTINC2		; POSTINC2 increments the location in data memory, to avoid overwriting what was previously read
		decfsz  counter, A			; Counter decreases until 0
		goto    loop1
		return

Read_Prompt2:	lfsr    2, messageLocation2             ; Same for the rest of the Read_Prompt functions
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
		movlw   12
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

Settings_Input:	call    LCD_clear		; Prompts the user to input the settings, and reads the response and saves them to numPlayers and numCards
		call    Read_Prompt1		; Prompts number of players input
		movf    count, 0, 0		; Count variable from earlier contains length of message - must be in WR for LCD write to work
		lfsr    2, messageLocation1	; Load file select register 2 with the message's location in data memory - required for LCD write function
		call    LCD_Write_Message
		call    LCD_line2		; Move to line 2
		call    writeNumPlayers		; Receives input and sets in numPlayers	
		movlw   100
		call    LCD_delay_ms		; Small delay to ease user experience
		call    LCD_clear		
		call    Read_Prompt2		; Prompts number of cards input
		movf    count, 0, 0		; Same again here
		lfsr    2, messageLocation2
		call    LCD_Write_Message
		call    LCD_line2
		call    writeNumCards		; Receives input and sets in numCardsDigit1 and numCardsDigit2
		tstfsz  testVar, 0		; Checks if testVar is set. If so restart all settings input (set in keypad file)
		goto    Settings_Input
		movlw   100
		call    LCD_delay_ms
		call    LCD_clear
		
		movlw   48
		subwf   numPlayers, 1, 0	; Convert numPlayers to ascii
			
		movlw   0xff			; Checks if numCardsDigit2 is FF (initialised value). If so, converts digit1 to ascii and sets numCards to this
		cpfseq  numCardsDigit2, 0
		goto    Two_Digit_Cards		; If two digits have been entered, go here
		movlw   48
		subwf   numCardsDigit1, 0, 0
		movwf   numCards, A
		return
		
Two_Digit_Cards:	movlw   48		; Converts two digits for numCards into one total number in ascii
		subwf   numCardsDigit1, 1, 0
		movlw   10
		mulwf   numCardsDigit1, 0
		movff   PRODL, numCards
		movlw   48
		subwf   numCardsDigit2, 0, 0	; Conversion to ascii
		addwf   numCards, 1, 0
		return

Reset_Settings:	call    LCD_clear		; Called at end of deal, clears screen and prompts reset
		call    Read_Prompt3
		movf    count, 0, 0
		lfsr    2, messageLocation3
		call    LCD_Write_Message
		call    LCD_line2
		call    Write_Reset		; Sits in loop until rest key (1 on keypad) is pressed
		return
		
Dealing_Message:				; Outputs dealing message while dealing
		call    LCD_clear
		call    Read_Prompt4
		movf    count, 0, 0
		lfsr    2, messageLocation4
		call    LCD_Write_Message
		return
