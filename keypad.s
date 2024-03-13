#include <xc.inc>
 
extrn           LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Write_Dec, LCD_Send_Byte_D, LCD_clear, LCD_line1, LCD_line2
global		KeyPad_Rows, KeyPad_Columns, KeyPad_Setup, Check_KeyPress, KeyPad_Value, KeyPad_Output
psect		udata_acs   
KeyPad_counter: ds  1       
KeyPad_Value:   ds  1
value:		ds  1
row:		ds  1
column:		ds  1
counter:	ds  1
    
psect	code, abs
;test:		call    LCD_Setup
;		call    LCD_clear
;		movlw   't'
;		movwf   0x20
;		movlw   'e'
;		movwf   0x21
;		movlw   's'
;		movwf   0x22
;		movlw   't'
;		movwf   0x23
;		lfsr    2, 0x20
;		movlw   4
;		call    LCD_Write_Message
;		nop

KeyPad_Setup:	clrf	LATE, A
                movlb	0x0f
                bsf     REPU
                clrf    TRISD, A
               ; return

Table_Set_Up:   db      'Hello'
		db      0x12, 0x22, 0x42, 0x82
		db	0x14, 0x24, 0x44, 0x84
		db      0x18, 0x28, 0x48, 0x88
		Lookup_Table  EQU 0x20
		align	      2
goto Read_Lookup_Table
KeyPad_Rows:	movlw   0x0f
                movwf   TRISE, A
                return
    
KeyPad_Columns:
                movlw   0xf0
                movwf   TRISE, A
                return
    
Check_KeyPress:
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
                return

KeyPad_Output:	movlw   1
		movwf   row
		movwf   column  ; If an invalid input is entered, row and column remain their initialised values so the output of the keypad is just whatever this maps to.
		movlw   00001111B
		andwf   KeyPad_Value, 0
		movwf   value
		movlw   00000001B
		cpfseq  value
		bra     next1
		movlw   1
		movwf   row
next1:          movlw   00000010B
		cpfseq  value
		bra     next2
		movlw   2
		movwf   row
next2:          movlw   00000100B
		cpfseq  value
		bra     next3
		movlw   3
		movwf   row
next3:          movlw   00001000B
		cpfseq  value
		bra     next4
		movlw   4
		movwf   row 
		
next4:		movlw   11110000B
		andwf   KeyPad_Value, 0
		movwf   value
		
		movlw   00010000B
		cpfseq  value
		bra     next5
		movlw   1
		movwf   column
next5:          movlw   00100000B
		cpfseq  value
		bra     next6
		movlw   2
		movwf   column
next6:          movlw   01000000B
		cpfseq  value
		bra     next7
		movlw   3
		movwf   column
next7:          movlw   10000000B
		cpfseq  value
		bra     next8
		movlw   4
		movwf   column
next8:		

Read_Lookup_Table:
		lfsr    0, Lookup_Table
		movlw   low highword(Table_Set_Up)
		movwf   TBLPTRU, A
		movlw   high(Table_Set_Up)
		movwf   TBLPTRH, A
		movlw   low(Table_Set_Up)
		movwf   TBLPTRL, A
		movlw   1
		subwf   row, 1
		movlw   4
		mulwf   row
		movf    PRODL, 0
		addwf   column, 1
		movlw   4 ; currently writes random values at start of table, don't know why, so added offset to account for this.
		addwf   column, 0
		movwf   counter
loop:		tblrd*+
		movff   TABLAT, POSTINC0
		decfsz  counter, A
		bra     loop
		return
                
delay:		movlw   0x40
                movwf   KeyPad_counter, A
		
countdown:      decfsz  KeyPad_counter, A           
                bra     countdown
                return