#include <xc.inc>

extrn           LCD_Send_Byte_D, LCD_clear, LCD_delay_ms, LCD_Write_Message, LCD_line2, Settings_Input, Read_Prompt1, messageLocation1, Read_Prompt2, messageLocation2, count
global		KeyPad_Setup, writeNumPlayers, writeNumCards, Write_Reset, numCardsDigit1, numCardsDigit2, numPlayers, KeyPad_Value, conversion, testVar

psect		udata_acs   
KeyPad_counter: ds  1       
KeyPad_Value:   ds  1
value:		ds  1
row:		ds  1
column:		ds  1
counter:	ds  1
checkIfPressed: ds  1
checkIfZero:	ds  1
enter:		ds  1
numPlayers:	ds  1
numCardsDigit1:	ds  1
numCardsDigit2:	ds  1
test:		ds  1
delayVariable:	ds  1
conversion:	ds  1
clear:		ds  1
one:		ds  1
two:		ds  1
beginning:	ds  1
testVar:	ds  1
    
psect		KeyPad_code, class = CODE

KeyPad_Setup:	clrf	LATJ, A	    ; Clears the required ports 
		clrf    LATE, A
                movlb	0x0f	    ; Sets the pull-up resistors
                bsf     REPU
		bsf     RJPU
                return

Table_Set_Up:   db      00110001B, 00110100B, 00110111B, 01000001B   ; Defines the ascii characters for the keypad. This table is transposed relative to actual keypad.
		db      00110010B, 00110101B, 00111000B, 00110000B   ; As explained later, we read the column and row number of the actual keypad	
		db	00110011B, 00110110B, 00111001B, 01000010B   ; and then set a row and column variable to read from the lookup table.
		db      01000110B, 01000101B, 01000100B, 01000011B   ; However as the table is transposed the read column number sets the row variable and  
		Lookup_Table  EQU 0x300				     ; vice versa.	

KeyPad_Columns:	movlw   0x0f		; Sets up to read the column number
                movwf   TRISJ, A
		bcf     TRISE, 0, 0
		bcf     TRISE, 1, 0
		bsf     TRISE, 3, 0
                return
    
KeyPad_Rows:				; Sets up to read the row number
                movlw   0xf0
                movwf   TRISJ, A
		bsf     TRISE, 0, 0	; Uses these pins instead of J5,6,2
		bsf     TRISE, 1, 0
		bcf     TRISE, 3, 0
                return
		
	
Convert:	movlw   00000001B		; Collates data from each port connected to the keypad.
J5toE0:		andwf   PORTE, 0, 0		; We use port J for most of the keypad connections, except for J5, 6 and 2.
		tstfsz  WREG, 0			; Tests the relevant bit in the other ports connected to the keypad
		goto    notZero1		; and sets the corresponding bit accordingly.
		goto    zero1
notZero1:	bsf     conversion, 5, 0
		goto    J6toE1
zero1:		bcf     conversion, 5, 0
J6toE1:	    	movlw   00000010B 
		andwf   PORTE, 0, 0
		tstfsz  WREG, 0
		goto    notZero2
		goto    zero2
notZero2:	bsf     conversion, 6, 0
		goto    J2toE3
zero2:		bcf     conversion, 6, 0
J2toE3:		movlw   00001000B 
		andwf   PORTE, 0, 0
		tstfsz  WREG, 0
		goto    notZero3
		goto    zero3
notZero3:	bsf     conversion, 2, 0
		return
zero3:		bcf     conversion, 2, 0
		return
    
Check_KeyPress: movlw   0			    ; Reads the column and row number and outputs a variable with a 1 in the place
		movwf   KeyPad_Value, A		    ; of the column in the low nibble and row for the high nibble.
                call    KeyPad_Columns
                call    delay			    ; Small delay to allow time to set up to read columns.
		movff   PORTJ, conversion, A	    ; Receive PORTJ value.
                call    Convert			    ; Converts J2,5,6 to the corresponding E pins.
		movff   conversion, KeyPad_Value    ; Stores result in KeyPad_Value.
	    	call    KeyPad_Rows		    ; Sets up to read rows.
		call    delay			    ; Small delay to allow set up.	
                movff   PORTJ, conversion, A
		call    Convert
		movf    conversion, 0, 0
		iorwf   KeyPad_Value, 0, 0	    ; Collates result of column and row read.	
                xorlw   0xff                        ; Changes the byte so there are two ones and the rest zeros instead of two zeros and the rest ones.
                movwf   KeyPad_Value, A
		
KeyPad_Output:	movlw   0			        ; Maps the keypad output to ascii and loops if input is invalid.
		movwf   row, A				; Initialises row and column variables to be set momentarily.
		movwf   column, A 
		
initialise1:	movlw   00001111B			; Checks row input against each possible value, loops if not valid.
		andwf   KeyPad_Value, 0, 0		; Takes lower nibble to test for column number.
		movwf   value, A			; Puts result in value variable.
		
next0:		movlw   00000001B			; Checks if the one is in the first bit.
		cpfseq  value, 0
		bra     next1				; If not, skips
		movlw   1
		movwf   row, A				; If equals this value, sets row variable accordinly.
  							; As lookup table is transposed, ***the low nibble (which reads the columns) defines the row variable***.
		goto    initialise2			; Then skips the rest of the column checks
next1:          movlw   00000010B			; Same for rest of column checks
		cpfseq  value, 0
		bra     next2
		movlw   2
		movwf   row, A
		goto    initialise2
next2:          movlw   00000100B
		cpfseq  value, 0
		bra     next3
		movlw   3
		movwf   row, A
		goto    initialise2
next3:          movlw   00001000B
		cpfseq  value, 0
		goto    Check_KeyPress		; If not equal to any of them, the input is invalid and a new input is received
		movlw   4
		movwf   row, A
		
initialise2:	movlw   11110000B		; Now does the same for reading the rows
		andwf   KeyPad_Value, 0, 0	; Takes high nibble and puts it in the value variable
		movwf   value, A
		
next4:		movlw   00010000B		; Same checks to see which row, and if the check is positive, it sets the column variable accordingly (as lookup table is transposed)
		cpfseq  value, 0
		bra     next5
		movlw   1
		movwf   column, A
		goto    Read_Lookup_Table
next5:          movlw   00100000B
		cpfseq  value, 0
		bra     next6
		movlw   2
		movwf   column, A
		goto    Read_Lookup_Table
next6:          movlw   01000000B
		cpfseq  value, 0
		bra     next7
		movlw   3
		movwf   column, A
		goto    Read_Lookup_Table
next7:          movlw   10000000B
		cpfseq  value, 0
		goto    Check_KeyPress
		movlw   4
		movwf   column, A
		
Read_Lookup_Table:					; Reads the look-up table into data memory
		lfsr    0, Lookup_Table			; Loads file select register 0 with the location in data memory we want the table to be read into
		movlw   low highword(Table_Set_Up)	; Loads address in program memory of table into TBLPTRU, TBLPTRH, TBLPTRL
		movwf   TBLPTRU, A
		movlw   high(Table_Set_Up)
		movwf   TBLPTRH, A
		movlw   low(Table_Set_Up)
		movwf   TBLPTRL, A
		movlw   1
		subwf   row, 1, 0			; Logic to convert the row and column number of the lookup table into a counter
		movlw   4				; that will count through the table until the desired value.
		mulwf   row, 0
		movf    PRODL, 0, 0
		addwf   column, 0, 0
		movwf   counter, A
loop:		tblrd*+
		movff   TABLAT, KeyPad_Value		; Loops through lookup table until counter is 0
		decfsz  counter, A
		bra     loop
		
		movlw   01000001B                       ; Rejects invalid letter inputs A, D, F
		cpfseq  KeyPad_Value, 0
		goto    next8				; If not equal to, continue
		goto    Check_KeyPress			; If equal to, receive a new input
next8:		movlw   01000100B			; Same for the other letter checks
		cpfseq  KeyPad_Value, 0
		goto    next9
		goto    Check_KeyPress
next9:		movlw   01000110B
		cpfseq  KeyPad_Value, 0
		return
		goto    Check_KeyPress
		
delay:		movlw   0x40				; Delay routine
                movwf   KeyPad_counter, A
		
countdown:      decfsz  KeyPad_counter, A           
                bra     countdown
                return

Check_No_KeyPress:					; Loops until no keys are pressed
		movff   PORTJ, conversion, A		; Receives state of keypad input ports
		call    Convert				; Performs conversion as before
		movf    conversion, 0, 0
		cpfseq  checkIfPressed, 0		; checkIfPressed is the state when no keys are pressed.
		goto    Check_No_KeyPress		; Therefore, if equal to, no keys are pressed and return.
		return					; It not equal to, loop until no key is pressed.
		
writeNumPlayers:				; 1 digit input
		movlw   11110000B               ; Condition to check if keypad button is pressed or not
		movwf   checkIfPressed, A
		movlw   01000101B
		movwf   enter, A                ; Condition to see if enter key has been pressed (E on the keypad)
		movlw   00110000B
		movwf   checkIfZero, A		; Condition to see if '0' key is pressed
		movlw   01000011B
		movwf   clear, A		; Condition to see if clear key is pressed (C on keypad)
		movlw   01000010B
		movwf   beginning, A		; Condition to see if beginning key is pressed (B on keypad)
		movlw   0
		movwf   test, A
digit1Or2P:    	tstfsz  test, 0			; Checks if input is first or second digit (second digit here is assumed to be logic button e.g. enter)
		goto    digit2P
		goto    digit1P
digit1P:	call    Check_KeyPress		; Receives first digit input
		call    Check_No_KeyPress	; Checks key is released
		movf    KeyPad_Value, 0, 0
		cpfseq  enter, 0
		goto    zeroTest1
		goto    digit1P 
zeroTest1:	cpfseq  checkIfZero, 0		; Rejects if first digit is 0
		goto    clearTest1
		goto    digit1P
clearTest1:     cpfseq  clear, 0		; Rejects if first digit is clear button
		goto    beginningTest1
		goto    digit1P
beginningTest1:	cpfseq  beginning, 0		; Rejects if first digit is beginning button
		goto    negative1
		goto    digit1P
negative1:	call    LCD_Send_Byte_D		; Input is valid by this point, therefore display
		movff   KeyPad_Value, numPlayers	; Saves input
		movlw   1
		movwf   test, A
		goto    digit1Or2P	
digit2P:        call    Check_KeyPress		; Receives input and checks key is released
		call    Check_No_KeyPress
		movf    KeyPad_Value, 0, 0
		cpfseq  enter, 0		; If equal to enter, return
		goto    negative2
		return  
negative2:	cpfseq  clear, 0 		; If equal to clear button, clear and start again
		goto    beginningTest2
		call    LCD_clear
		call    Read_Prompt1
		movf    count, 0, 0
		lfsr    2, messageLocation1
		call    LCD_Write_Message
		call    LCD_line2
		goto    writeNumPlayers
beginningTest2:	cpfseq  beginning, 0		; If equal to beginning button, clear and start again (same as clear at this point)
		goto    digit2P
		call    LCD_clear
		call    Read_Prompt1
		movf    count, 0, 0
		lfsr    2, messageLocation1
		call    LCD_Write_Message
		call    LCD_line2
		goto    writeNumPlayers
	
writeNumCards: 					; 2 digit input
		movlw   0			; Set if beginning key is pressed, used in settings file to restart settings input
		movwf   testVar, A
		movlw   11110000B             	; Condition to check if keypad button is pressed
		movwf   checkIfPressed, A
		movlw   01000101B		; Condition to see if enter key has been pressed (E on the keypad).
		movwf   enter, A                 
		movlw   00110000B		; Condition to see if '0' key is pressed
		movwf   checkIfZero, A
		movlw   01000011B		; Condition to see if clear key is pressed (C on keypad)
		movwf   clear, A
		movlw   0			; Checks which digit input process is on
		movwf   test, A
		movlw   0xff
		movwf   numCardsDigit1, A
		movwf   numCardsDigit2, A
digit1Or2C:    	tstfsz  test, 0			; Checks which digit 
		goto    digit2C
		goto    digit1C
digit1C:	call    Check_KeyPress		; Receives first digit and checks key is released
		call    Check_No_KeyPress
		movf    KeyPad_Value, 0, 0
		cpfseq  enter, 0		; Rejects enter as first digit
		goto    zeroTest2
		goto    digit1C 
zeroTest2:	cpfseq  checkIfZero, 0		; Rejects 0 as first digit
		goto    clearTest2
		goto    digit1C
clearTest2:	cpfseq  clear, 0		; Rejects clear as first digit
		goto    beginningTest3
		goto    digit1C
beginningTest3:	cpfseq  beginning, 0		; If beginning key pressed, sets testVar and returns to settings file to reset
		goto    negative3
		movlw   1
		movwf   testVar, A
		return
negative3:	call    LCD_Send_Byte_D		; Valid input by this point, so display
		movff   KeyPad_Value, numCardsDigit1
		movlw   1
		movwf   test, A
		goto    digit1Or2C	
digit2C:        call    Check_KeyPress		; Receives second digit and checks key is released
		call    Check_No_KeyPress
		movf    KeyPad_Value, 0, 0
		cpfseq  enter, 0
		goto    clearTest3
		return  
clearTest3:     cpfseq  clear, 0		; If clear key is pressed, clear screen and return to start of numCards input
		goto    beginningTest4
		call    LCD_clear
		call    Read_Prompt2
		movf    count, 0, 0
		lfsr    2, messageLocation2
		call    LCD_Write_Message
		call    LCD_line2
		goto    writeNumCards
beginningTest4:	cpfseq  beginning, 0		; If beginning key pressed, set testVar and return to settings file to reset
		goto    negative4
		movlw   1
		movwf   testVar, A
		return
negative4:	call    LCD_Send_Byte_D		; Valid input by this point so display
		movff   KeyPad_Value, numCardsDigit2	
loop2:		call    Check_KeyPress		; Loop until logic key is pressed e.g. enter, clear, beginning
		movf    KeyPad_Value, 0, 0
		cpfseq  enter, 0		; If enter, return
		goto    clearTest4
		return
clearTest4:	cpfseq  clear, 0		; If clear, clear screen and go to numCards input
		goto    beginningTest5
		call    LCD_clear
		call    Read_Prompt2
		movf    count, 0, 0
		lfsr    2, messageLocation2
		call    LCD_Write_Message
		call    LCD_line2
		goto    writeNumCards  
beginningTest5:	cpfseq  beginning, 0		; If beginning, set testVar and return to settings file to reset
		goto    loop2
		movlw   1
		movwf   testVar, A
		return

Write_Reset:	movlw   11110000B               ; Condition to check if keypad button is pressed or not
		movwf   checkIfPressed, A
		movlw   00110001B		; Condition to check if '1' key is pressed	
		movwf   one, A
again:		call    Check_KeyPress		; Loops until 1 is pressed
		movf    KeyPad_Value, 0, 0
		cpfseq  one, 0
		goto    again
		call    Check_No_KeyPress
		movlw   50
		call    LCD_delay_ms
		return
