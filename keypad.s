#include <xc.inc>
    
global		KeyPad_Rows, KeyPad_Columns, KeyPad_Setup, Check_KeyPress, KeyPad_Value, KeyPad_Output
psect		udata_acs   
KeyPad_counter: ds  1       
KeyPad_Value:   ds  1
value:		ds  1
row:		ds  1
column:		ds  1
counter:	ds  1
   
psect		KeyPad_code, class = CODE

KeyPad_Setup:	clrf	LATE, A
                movlb	0x0f
                bsf     REPU
                clrf    TRISD, A
                return

Table_Set_Up:   bcf     CFGS
		bsf	EEPGD
		db      00110001B, 00110010B, 00110011B, 01000110B
		db      00110100B, 00110101B, 00110110B, 01000101B
		db	00110111B, 00111000B, 00111001B, 01000100B
		db      01000001B, 00110000B, 01000010B, 01000011B
		Lookup_Table  EQU 0x300
		align	      2

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

KeyPad_Output:
		movlw   00001111B
		andwf   KeyPad_Value, 0, 0
		movwf   value, 0
		movlw   00000001B
		CPFSEQ  value, 0
		bra     next1
		movlw   4
		movwf   column, 0
next1:          movlw   00000010B
		CPFSEQ  value, 0
		bra     next2
		movlw   3
		movwf   column, 0
next2:          movlw   00000100B
		CPFSEQ  value, 0
		bra     next3
		movlw   2
		movwf   column, 0
next3:          movlw   00001000B
		CPFSEQ  value, 0
		bra     next4
		movlw   1
		movwf   column, 0
		
next4:		movlw   11110000B
		andwf   KeyPad_Value, 0, 0
		movwf   value, 0
		
		movlw   00010000B
		CPFSEQ  value, 0
		bra     next5
		movlw   4
		movwf   row, 0
next5:          movlw   00100000B
		CPFSEQ  value, 0
		bra     next6
		movlw   3
		movwf   row, 0
next6:          movlw   01000000B
		CPFSEQ  value, 0
		bra     next7
		movlw   2
		movwf   row, 0
next7:          movlw   10000000B
		CPFSEQ  value, 0
		bra     next8
		movlw   1
		movwf   row, 0
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
		subwf   row, 1, 0
		movlw   4
		mulwf   row, 0
		movf    PRODL, 0
		addwf   column, 1, 0
		movlw   4 ; currently writes random values at start of table, don't know why, so added offset to account for this.
		addwf   column, 0, 0
		movwf   counter, 0
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