#include <xc.inc>

extrn           LCD_Send_Byte_D, LCD_Setup, LCD_delay_ms, LCD_clear
global		Check_KeyPress, KeyPad_Rows, KeyPad_Columns, KeyPad_Setup, Check_KeyPress, KeyPad_Value, KeyPad_Output, writeNumPlayers, writeNumCards, numPlayersDigit1, numPlayersDigit2, numCardsDigit1, numCardsDigit2
global		numPlayersDigit1, numPlayersDigit2, checkIfPressed, enter, KeyPad_Value, test, numCardsDigit1, numCardsDigit2, var, var2, Write_Y_Or_N, resetVar
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
delayVariable:	ds  1
var:		ds  1
var2:		ds  1
resetVar:	ds  1
   
psect		KeyPad_code, class = CODE

KeyPad_Setup:	clrf	LATJ, A
		clrf    LATE, A
                movlb	0x0f
                bsf     REPU
		bsf     RJPU
                return

Table_Set_Up:   db      00110001B, 00110100B, 00110111B, 01000001B
		db      00110010B, 00110101B, 00111000B, 00110000B
		db	00110011B, 00110110B, 00111001B, 01000010B
		db      01000110B, 01000101B, 01000100B, 01000011B
		Lookup_Table  EQU 0x300

KeyPad_Rows:	movlw   0x0f
                movwf   TRISJ, A
		bcf     TRISE, 0, 0
		bcf     TRISE, 1, 0
		bsf     TRISE, 3, 0
                return
    
KeyPad_Columns:
                movlw   0xf0
                movwf   TRISJ, A
		bsf     TRISE, 0, 0
		bsf     TRISE, 1, 0
		bcf     TRISE, 3, 0
                return
		
	
Convert:	movlw   00000001B 
J5toE0:		andwf   PORTE, 0, 0
		movwf   var, A
		tstfsz  var, 0
		goto    notZero1
		goto    zero1
notZero1:	bsf     KeyPad_Value, 5, 0
		goto    J6toE1
zero1:		bcf     KeyPad_Value, 5, 0
J6toE1:	    	movlw   00000010B 
		andwf   PORTE, 0, 0
		movwf   var, A
		tstfsz  var, 0
		goto    notZero2
		goto    zero2
notZero2:	bsf     KeyPad_Value, 6, 0
		goto    J2toE3
zero2:		bcf     KeyPad_Value, 6, 0
J2toE3:		movlw   00001000B 
		andwf   PORTE, 0, 0
		movwf   var, A
		tstfsz  var, 0
		goto    notZero3
		goto    zero3
notZero3:	bsf     KeyPad_Value, 2, 0
		return
zero3:		bcf     KeyPad_Value, 2, 0
		return
    
Check_KeyPress: movlw   0
		movwf   KeyPad_Value, A
                call    KeyPad_Rows
                call    delay
		movff   PORTJ, KeyPad_Value, A
                call    Convert
	    	call    KeyPad_Columns	
		call    delay
                movlw   0x0f
                andwf   KeyPad_Value, W, A
                iorwf   PORTJ, W, A
		movwf   KeyPad_Value, A
		call    Convert
		movf    KeyPad_Value, 0, 0
                xorlw   0xff
                movwf   KeyPad_Value, A
	
KeyPad_Output:	movlw   0
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

Check_No_KeyPress:
		movff   PORTJ, KeyPad_Value, A
		call    Convert
		movf    KeyPad_Value, 0, 0
		cpfseq  checkIfPressed, 0
		goto    Check_No_KeyPress
		return

; These functions allow the user to input the number of players and cards respectively into the keypad.
; The maximum number of digits is 2, and the F key is the enter key.
writeNumPlayers: 
		movlw   11110000B             ; Condition to check if keypad button is pressed or not.
		movwf   checkIfPressed, A
		movlw   01000110B
		movwf   enter, A                 ; Condition to see if enter key has been pressed (F on the keypad).
		movlw   0
		movwf   test, A
		movlw   0xff
		movwf   numPlayersDigit1, A
		movwf   numPlayersDigit2, A
digit1Or2P:	call    Check_KeyPress
		movf    KeyPad_Value, 0, 0
		cpfseq  enter, 0
		goto    digit1P
		return
digit1P:	call    LCD_Send_Byte_D
		tstfsz  test, 0
		goto    digit2P
		movff   KeyPad_Value, numPlayersDigit1
		movlw   1
		movwf   test, A
		call    Check_No_KeyPress
		goto    digit1Or2P
digit2P:	movff   KeyPad_Value, numPlayersDigit2
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
		goto    digit1C
		return
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


