#include <xc.inc>

extrn           LCD_Send_Byte_D, LCD_clear
global		KeyPad_Setup, writeNumPlayers, writeNumCards, Write_Y_Or_N, numCardsDigit1, numCardsDigit2, numPlayers, resetVar, KeyPad_Value

psect		udata_acs   
KeyPad_counter: ds  1       
KeyPad_Value:   ds  1
value:		ds  1
row:		ds  1
column:		ds  1
counter:	ds  1
checkIfPressed: ds  1
enter:		ds  1
numPlayers:	ds  1
numCardsDigit1:	ds  1
numCardsDigit2:	ds  1
test:		ds  1
delayVariable:	ds  1
resetVar:	ds  1
conversion:	ds  1
   
psect		KeyPad_code, class = CODE

KeyPad_Setup:	clrf	LATJ, A	    ; Clears the requred ports. We use pins from multiple ports for the keypad.
		clrf    LATE, A
                movlb	0x0f	    ; Sets the pull-up resistors.
                bsf     REPU
		bsf     RJPU
                return

Table_Set_Up:   db      00110001B, 00110100B, 00110111B, 01000001B   ; Defines the ascii characters for the keypad.
		db      00110010B, 00110101B, 00111000B, 00110000B
		db	00110011B, 00110110B, 00111001B, 01000010B
		db      01000110B, 01000101B, 01000100B, 01000011B
		Lookup_Table  EQU 0x300

KeyPad_Columns:	movlw   0x0f		; Sets up to read the column number.
                movwf   TRISJ, A
		bcf     TRISE, 0, 0
		bcf     TRISE, 1, 0
		bsf     TRISE, 3, 0
                return
    
KeyPad_Rows:				; Sets up to read the row number.
                movlw   0xf0
                movwf   TRISJ, A
		bsf     TRISE, 0, 0
		bsf     TRISE, 1, 0
		bcf     TRISE, 3, 0
                return
		
	
Convert:	movlw   00000001B		; Collates data from each port connected to the keypad.
J5toE0:		andwf   PORTE, 0, 0		; We use port J for most of the keypad connections, except for J5, 6 and 2. 
		tstfsz  WREG, 0			; This tests the relevant bit in the other ports connected to the keypad.   
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
                call    delay
		movff   PORTJ, conversion, A
                call    Convert
		movff   conversion, KeyPad_Value
	    	call    KeyPad_Rows
		call    delay
                movff   PORTJ, conversion, A
		call    conversion
		movf    conversion, 0, 0
		andwf   KeyPad_Value, 0, 0
                xorlw   0xff
                movwf   KeyPad_Value, A
	nop
;Check_KeyPress: movlw   0
;		movwf   KeyPad_Value, A
;                call    KeyPad_Rows
;                call    delay
;                movff   PORTJ, KeyPad_Value, A
;		movlw   00001000B
;		andwf   PORTE, 0, 0
;		movwf   var, A
;		tstfsz  var, 0
;		goto    notZero60
;		goto    zero60
;notZero60:	bsf     KeyPad_Value, 2, 0
;		goto    moveOn60
;zero60:		bcf     KeyPad_Value, 2, 0
;moveOn60:	call    KeyPad_Columns	
;		call    delay
;                movlw   0x0f
;                andwf   KeyPad_Value, W, A
;                iorwf   PORTJ, W, A
;		movwf   KeyPad_Value, A
;		movlw   00000001B 
;		andwf   PORTE, 0, 0
;		movwf   var, A
;		tstfsz  var, 0
;		goto    notZero10
;		goto    zero10
;notZero10:	bsf     KeyPad_Value, 5, 0
;		goto    moveOn10
;zero10:		bcf     KeyPad_Value, 5, 0
;moveOn10:	movlw   00000010B 
;		andwf   PORTE, 0, 0
;		movwf   var, A
;		tstfsz  var, 0
;		goto    notZero70
;		goto    zero70
;notZero70:	bsf     KeyPad_Value, 6, 0
;		goto    moveOn70
;zero70:		bcf     KeyPad_Value, 6, 0
;moveOn70:	movf    KeyPad_Value, 0, 0
;                xorlw   0xff
;                movwf   KeyPad_Value, A
		
KeyPad_Output:	movlw   0			    ; Maps the keypad output to ascii. Loops if keypad output is invalid.
		movwf   row, A
		movwf   column, A 
		
initialise1:	movlw   00001111B
		andwf   KeyPad_Value, 0, 0
		movwf   value, A
		
next0:		movlw   00000001B
		cpfseq  value, 0
		bra     next1
		movlw   1
		movwf   row, A
		goto    initialise2
next1:          movlw   00000010B
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
		goto    Check_KeyPress
		movlw   4
		movwf   row, A
		
initialise2:	movlw   11110000B
		andwf   KeyPad_Value, 0, 0
		movwf   value, A
		
next4:		movlw   00010000B
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
		
Read_Lookup_Table:					; Reads the look-up table into data memory.
		lfsr    0, Lookup_Table
		movlw   low highword(Table_Set_Up)
		movwf   TBLPTRU, A
		movlw   high(Table_Set_Up)
		movwf   TBLPTRH, A
		movlw   low(Table_Set_Up)
		movwf   TBLPTRL, A
		movlw   1
		subwf   row, 1, 0
		movlw   4
		mulwf   row, 0
		movf    PRODL, 0, 0
		addwf   column, 0, 0
		movwf   counter, A
loop:		tblrd*+
		movff   TABLAT, KeyPad_Value
		decfsz  counter, A
		bra     loop
		
		movlw   01000101B		    ; Checks if the output is a letter, if so it loops until valid input entered.
		cpfseq  KeyPad_Value, 0
		goto    next8
		goto    Check_KeyPress
next8:		movlw   01000100B
		cpfseq  KeyPad_Value, 0
		goto    next9
		goto    Check_KeyPress
next9:		movlw   01000011B
		cpfseq  KeyPad_Value, 0
		goto    next10
		goto    Check_KeyPress
next10:		movlw   01000001B
		cpfseq  KeyPad_Value, 0
		goto    next11
		goto    Check_KeyPress
next11:		movlw   01000010B
		cpfseq  KeyPad_Value, 0
		return
		goto    Check_KeyPress
                
delay:		movlw   0x40
                movwf   KeyPad_counter, A
		
countdown:      decfsz  KeyPad_counter, A           
                bra     countdown
                return

Check_No_KeyPress:					; This loops until no keys are pressed.
		movff   PORTJ, KeyPad_Value, A
		call    Convert
		movf    KeyPad_Value, 0, 0
		cpfseq  checkIfPressed, 0
		goto    Check_No_KeyPress
		return

writeNumPlayers:					
		movlw   11110000B           
		movwf   checkIfPressed, A
		movlw   01000110B
		movwf   enter, A                 ; Condition to see if enter key has been pressed (F on the keypad).
		call    Check_KeyPress
		movf    KeyPad_Value, 0, 0
		cpfseq  enter, 0
		goto    testIfZeroP
		goto    writeNumPlayers
testIfZeroP:	movlw   00110000B
		cpfseq  KeyPad_Value, 0
		goto    digit1P
		goto    writeNumPlayers
		return
digit1P:	call    LCD_Send_Byte_D
		movff   KeyPad_Value, numPlayers	
		call    Check_No_KeyPress
		return

writeNumCards: 
		movlw   11110000B             ; Condition to check if keypad button is pressed or not.
		movwf   checkIfPressed, A
		movlw   01000110B
		movwf   enter, A                 ; Condition to see if enter key has been pressed (F on the keypad).
		movlw   0
		movwf   test, A
		movlw   0xff
		movwf   numCardsDigit1, A
		movwf   numCardsDigit2, A
digit1Or2C:	call    Check_KeyPress
		movf    KeyPad_Value, 0, 0
		cpfseq  enter, 0
		goto    testIfZeroC
		return
testIfZeroC:	tstfsz  test, 0
		goto    digit1C
		movlw   00110000B
		cpfseq  KeyPad_Value, 0
		goto    digit1C
		goto    writeNumCards
digit1C:	call    LCD_Send_Byte_D
		tstfsz  test, 0
		goto    digit2C
		movff   KeyPad_Value, numCardsDigit1
		movlw   1
		movwf   test, A
		call    Check_No_KeyPress
		goto    digit1Or2C	
digit2C:        movff   KeyPad_Value, numCardsDigit2
		call    Check_No_KeyPress
		return

Write_Y_Or_N:	movlw   0
		movwf   resetVar, A
		movlw   11110000B             ; Condition to check if keypad button is pressed or not.
		movwf   checkIfPressed, A
again:		call    LCD_clear
	    	call    Check_KeyPress
		movf    KeyPad_Value, 0, 0
		call    LCD_Send_Byte_D	
		call    Check_No_KeyPress
		movlw   00110001B
		cpfseq  KeyPad_Value, 0
		goto    carryon1
		goto    Yes
carryon1:	movlw	00110010B
		cpfseq  KeyPad_Value, 0
		goto    carryon2
		goto    No
carryon2:	goto    again
Yes:		movlw   1
		movwf   resetVar, A
		return
No:		movlw   0
		movwf   resetVar, A
		return


