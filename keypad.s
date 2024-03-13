#include <xc.inc>

extrn           LCD_Send_Byte_D, LCD_Setup
global		Check_KeyPress, KeyPad_Rows, KeyPad_Columns, KeyPad_Setup, Check_KeyPress, KeyPad_Value, KeyPad_Output, writeNumPlayers, writeNumCards, numPlayersDigit1, numPlayersDigit2, numCardsDigit1, numCardsDigit2
global		numPlayersDigit1, numPlayersDigit2, checkIfPressed, enter, KeyPad_Value, test, numCardsDigit1, numCardsDigit2, validInput
psect		udata_acs   
KeyPad_counter: ds  1       
KeyPad_Value:   ds  1
value:		ds  1
row:		ds  1
column:		ds  1
counter:	ds  1
checkIfPressed: ds  1
enter:		ds  1
numPlayersDigit1:	ds  1
numPlayersDigit2:	ds  1
numCardsDigit1:	ds  1
numCardsDigit2:	ds  1
test:		ds  1
validInput:	ds  1
   
psect		KeyPad_code, class = CODE

KeyPad_Setup:	clrf	LATE, A
                movlb	0x0f
                bsf     REPU
                clrf    TRISD, A
                return

Table_Set_Up:   db      0x11, 0x21, 0x41, 0x81
		db      0x12, 0x22, 0x42, 0x82
		db	0x14, 0x24, 0x44, 0x84
		db      0x18, 0x28, 0x48, 0x88
		Lookup_Table  EQU 0x300

KeyPad_Rows:	movlw   0x0f
                movwf   TRISE, A
                return
    
KeyPad_Columns:
                movlw   0xf0
                movwf   TRISE, A
                return
    
Check_KeyPress: movlw   0
		movwf   KeyPad_Value, A
                call    KeyPad_Rows
                call    delay
                movff   PORTE, KeyPad_Value, A
                call    KeyPad_Columns
                call    delay
                movlw   0x0f
                andwf   KeyPad_Value, W, A
                iorwf   PORTE, W, A
                xorlw   0xff
                movwf   KeyPad_Value, A

KeyPad_Output:	movlw   0
		movwf   row, A
		movwf   column, A 
		movwf   validInput, A
		
initialise0:	movlw   00001111B
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
		goto    checkValidInput
next5:          movlw   00100000B
		cpfseq  value, 0
		bra     next6
		movlw   2
		movwf   column, A
		goto    checkValidInput
next6:          movlw   01000000B
		cpfseq  value, 0
		bra     next7
		movlw   3
		movwf   column, A
		goto    checkValidInput
next7:          movlw   10000000B
		cpfseq  value, 0
		goto    Check_KeyPress
		movlw   4
		movwf   column, A

checkValidInput:movlw   1
		movwf   validInput, A
		
Read_Lookup_Table:
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
		return
                
delay:		movlw   0x40
                movwf   KeyPad_counter, A
		
countdown:      decfsz  KeyPad_counter, A           
                bra     countdown
                return

; These functions allow the user to input the number of players and cards respectively into the keypad.
; The maximum number of digits is 2, and the F key is the enter key.
writeNumPlayers: call    KeyPad_Setup
		movlw   11110000B             ; Condition to check if keypad button is pressed or not.
		movwf   checkIfPressed, A
		movlw   01000110B
		movwf   enter, A                 ; Condition to see if enter key has been pressed (F on the keypad).
		movlw   0
		movwf   numPlayersDigit1, A
		movwf   numPlayersDigit2, A
		movwf   test, A
everywhere1:	call    Check_KeyPress
		movf    KeyPad_Value, 0, 0
		cpfseq  enter, 0
		goto    there1
		return
there1:		call    LCD_Send_Byte_D
		tstfsz  test, 0
		goto    somewhere1
		movwf   numPlayersDigit1, A
		setf    test, 0
here1:		movf    PORTE, 0, 0
		cpfseq  checkIfPressed, 0
		goto    here1
		goto    everywhere1	
somewhere1:	movwf   numPlayersDigit2, A
		return

writeNumCards:  call    KeyPad_Setup
		movlw   11110000              ; Condition to check if keypad button is pressed or not.
		movwf   checkIfPressed, A
		movlw   01000110B
		movwf   enter, A                 ; Condition to see if enter key has been pressed (F on the keypad).
		movlw   0
		movwf   numCardsDigit1, A
		movwf   numCardsDigit2, A
		movwf   test, A
skip2:		call    Check_KeyPress
		tstfsz  KeyPad_Value, 0
		goto    not2
		goto    skip2
not2:		call    KeyPad_Output
		movf    KeyPad_Value, 0, 0
		cpfseq  enter, 0
		goto    there2
		return
there2:		call    LCD_Send_Byte_D
		tstfsz  test, 0
		goto    somewhere2
		movwf   numCardsDigit1, A
		setf    test, 0
here2:		movf    PORTE, 0, 0
		cpfseq  checkIfPressed, 0
		goto    here2
		goto    skip2	
somewhere2:	movwf   numCardsDigit2, A
		return
		