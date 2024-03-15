#include <xc.inc>

extrn           LCD_Send_Byte_D, LCD_Setup, LCD_delay_ms
global		Check_KeyPress, KeyPad_Rows, KeyPad_Columns, KeyPad_Setup, Check_KeyPress, KeyPad_Value, KeyPad_Output, writeNumPlayers, writeNumCards, numPlayersDigit1, numPlayersDigit2, numCardsDigit1, numCardsDigit2
global		numPlayersDigit1, numPlayersDigit2, checkIfPressed, enter, KeyPad_Value, test, numCardsDigit1, numCardsDigit2, var, var2
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
    
Check_KeyPress: movlw   0
		movwf   KeyPad_Value, A
                call    KeyPad_Rows
                call    delay
                movff   PORTJ, KeyPad_Value, A
		movlw   00001000B
		andwf   PORTE, 0, 0
		movwf   var, A
		tstfsz  var, 0
		goto    notZero6
		goto    zero6
notZero6:	bsf     KeyPad_Value, 2, 0
		goto    moveOn6
zero6:		bcf     KeyPad_Value, 2, 0
moveOn6:	call    KeyPad_Columns	
		call    delay
                movlw   0x0f
                andwf   KeyPad_Value, W, A
                iorwf   PORTJ, W, A
		movwf   KeyPad_Value, A
		movlw   00000001B 
		andwf   PORTE, 0, 0
		movwf   var, A
		tstfsz  var, 0
		goto    notZero1
		goto    zero1
notZero1:	bsf     KeyPad_Value, 5, 0
		goto    moveOn1
zero1:		bcf     KeyPad_Value, 5, 0
moveOn1:	movlw   00000010B 
		andwf   PORTE, 0, 0
		movwf   var, A
		tstfsz  var, 0
		goto    notZero7
		goto    zero7
notZero7:	bsf     KeyPad_Value, 6, 0
		goto    moveOn7
zero7:		bcf     KeyPad_Value, 6, 0
moveOn7:	movf    KeyPad_Value, 0, 0
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

; These functions allow the user to input the number of players and cards respectively into the keypad.
; The maximum number of digits is 2, and the F key is the enter key.
writeNumPlayers: call    KeyPad_Setup
		movlw   11110000B             ; Condition to check if keypad button is pressed or not.
		movwf   checkIfPressed, A
		movlw   01000110B
		movwf   enter, A                 ; Condition to see if enter key has been pressed (F on the keypad).
		movlw   0
		movwf   test, A
		movlw   0xff
		movwf   numPlayersDigit1, A
		movwf   numPlayersDigit2, A
everywhere1:	call    Check_KeyPress
		movf    KeyPad_Value, 0, 0
		cpfseq  enter, 0
		goto    there1
		return
there1:		call    LCD_Send_Byte_D
		;movlw   255
		;call    LCD_delay_ms
		tstfsz  test, 0
		goto    somewhere1
		movff   KeyPad_Value, numPlayersDigit1
		movlw   1
		movwf   test, A
here1:		movlw   00000001B 
		andwf   PORTE, 0, 0
		movwf   var, A	
		movff   PORTJ, var2
		tstfsz  var, 0
		goto    notZero2
		goto    zero2
notZero2:	bsf     var2, 5, 0
		goto    moveOn2
zero2:		bcf     var2, 5, 0		
moveOn2:	movlw   00000010B 
		andwf   PORTE, 0, 0
		movwf   var, A
		tstfsz  var, 0
		goto    notZero8
		goto    zero8
notZero8:	bsf     KeyPad_Value, 6, 0
		goto    moveOn8
zero8:		bcf     KeyPad_Value, 6, 0
moveOn8:	movlw   00001000B 
		andwf   PORTE, 0, 0
		movwf   var, A
		tstfsz  var, 0
		goto    notZero9
		goto    zero9
notZero9:	bsf     KeyPad_Value, 2, 0
		goto    moveOn9
zero9:		bcf     KeyPad_Value, 2, 0
moveOn9:  	movf    var2, 0, 0
		cpfseq  checkIfPressed, 0
		goto    here1
		goto    everywhere1	
somewhere1:	movlw   00000001B 
		andwf   PORTE, 0, 0
		movwf   var, A	
		movff   PORTJ, var2
		tstfsz  var, 0
		goto    notZero4
		goto    zero4
notZero4:	bsf     var2, 5, 0
		goto    moveOn4
zero4:		bcf     var2, 5, 0		
moveOn4:	movlw   00000010B 
		andwf   PORTE, 0, 0
		movwf   var, A
		tstfsz  var, 0
		goto    notZero20
		goto    zero20
notZero20:	bsf     KeyPad_Value, 6, 0
		goto    moveOn20
zero20:		bcf     KeyPad_Value, 6, 0
moveOn20:	movlw   00001000B 
		andwf   PORTE, 0, 0
		movwf   var, A
		tstfsz  var, 0
		goto    notZero10
		goto    zero10
notZero10:	bsf     KeyPad_Value, 2, 0
		goto    moveOn10
zero10:		bcf     KeyPad_Value, 2, 0
moveOn10:	movf    var2, 0, 0
		cpfseq  checkIfPressed, 0
		goto    somewhere1
		movff   var2, numPlayersDigit2
		;movlw   255
		;call    LCD_delay_ms
		return

writeNumCards:  call    KeyPad_Setup
		movlw   11110000B             ; Condition to check if keypad button is pressed or not.
		movwf   checkIfPressed, A
		movlw   01000110B
		movwf   enter, A                 ; Condition to see if enter key has been pressed (F on the keypad).
		movlw   0
		movwf   test, A
		movlw   0xff
		movwf   numCardsDigit1, A
		movwf   numCardsDigit2, A
everywhere9:	call    Check_KeyPress
		movf    KeyPad_Value, 0, 0
		cpfseq  enter, 0
		goto    there9
		return
there9:		call    LCD_Send_Byte_D
		;movlw   255
		;call    LCD_delay_ms
		tstfsz  test, 0
		goto    somewhere9
		movff   KeyPad_Value, numCardsDigit1
		movlw   1
		movwf   test, A
here9:		movlw   00000001B 
		andwf   PORTE, 0, 0
		movwf   var, A	
		movff   PORTJ, var2
		tstfsz  var, 0
		goto    notZero11
		goto    zero11
notZero11:	bsf     var2, 5, 0
		goto    moveOn11
zero11:		bcf     var2, 5, 0		
moveOn11:	movlw   00000010B 
		andwf   PORTE, 0, 0
		movwf   var, A
		tstfsz  var, 0
		goto    notZero12
		goto    zero12
notZero12:	bsf     KeyPad_Value, 6, 0
		goto    moveOn12
zero12:		bcf     KeyPad_Value, 6, 0
moveOn12:	movlw   00001000B 
		andwf   PORTE, 0, 0
		movwf   var, A
		tstfsz  var, 0
		goto    notZero13
		goto    zero13
notZero13:	bsf     KeyPad_Value, 2, 0
		goto    moveOn13
zero13:		bcf     KeyPad_Value, 2, 0
moveOn13:  	movf    var2, 0, 0
		cpfseq  checkIfPressed, 0
		goto    here9
		goto    everywhere9	
somewhere9:	movlw   00000001B 
		andwf   PORTE, 0, 0
		movwf   var, A	
		movff   PORTJ, var2
		tstfsz  var, 0
		goto    notZero14
		goto    zero14
notZero14:	bsf     var2, 5, 0
		goto    moveOn14
zero14:		bcf     var2, 5, 0		
moveOn14:	movlw   00000010B 
		andwf   PORTE, 0, 0
		movwf   var, A
		tstfsz  var, 0
		goto    notZero15
		goto    zero15
notZero15:	bsf     KeyPad_Value, 6, 0
		goto    moveOn15
zero15:		bcf     KeyPad_Value, 6, 0
moveOn15:	movlw   00001000B 
		andwf   PORTE, 0, 0
		movwf   var, A
		tstfsz  var, 0
		goto    notZero16
		goto    zero16
notZero16:	bsf     KeyPad_Value, 2, 0
		goto    moveOn16
zero16:		bcf     KeyPad_Value, 2, 0
moveOn16:	movf    var2, 0, 0
		cpfseq  checkIfPressed, 0
		goto    somewhere1
		movff   var2, numCardsDigit2
		;movlw   255
		;call    LCD_delay_ms
		return