#include <xc.inc>
    
global		KeyPad_Rows, KeyPad_Columns, KeyPad_Setup, Check_KeyPress, KeyPad_Value, row, column
psect		udata_acs   
KeyPad_counter: ds  1       
KeyPad_Value:   ds  1
row:		ds  1
column:		ds  1
   
psect		KeyPad_code, class = CODE

KeyPad_Setup:	clrf	LATE, A
                movlb	0x0f
                bsf     REPU
                clrf    TRISD, A
                return
psect	code, abs
rst:	org	0x0

Table_Set_Up:   bcf     CFGS
		bsf	EEPGD
		db      0x11, 0x21, 0x41, 0x81
		db      0x12, 0x22, 0x42, 0x82
		db	0x14, 0x24, 0x44, 0x84
		db      0x18, 0x28, 0x48, 0x88
		Lookup_Table  EQU 0x300
		counter	      EQU 0x10
		align	      2
goto test  
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
test:
movlw   00001000B
movwf   KeyPad_Value
KeyPad_Output:
		movlw   00001111B
		andwf   KeyPad_Value, 0
		CPFSEQ  00000001B
		bra     next1
		movlw   1
		movwf   row
next1:          CPFSEQ  00000010B
		bra     next2
		movlw   2
		movwf   row
next2:          CPFSEQ  00000100B
		bra     next3
		movlw   3
		movwf   row
next3:          CPFSEQ  00001000B
		bra     next4
		movlw   4
		movwf   row   
		
next4:		movlw   11110000B
		andwf   KeyPad_Value, 0
		CPFSEQ  00010000B
		bra     next5
		movlw   1
		movwf   column
next5:          CPFSEQ  00100000B
		bra     next6
		movlw   2
		movwf   column
next6:          CPFSEQ  01000000B
		bra     next7
		movlw   3
		movwf   column
next7:          CPFSEQ  10000000B
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
  ; currently writes random values at start of table, don't know why, so added offset to account for this.
		movf    row
		addwf   column
		movwf   counter
		movlw   3
		addwf   counter
		movwf   counter
loop:		tblrd*+
		movff   TABLAT, KeyPad_Value
		decfsz  counter, A
		bra     loop
		goto    0
                
delay:		movlw   0x40
                movwf   KeyPad_counter, A
		
countdown:      decfsz  KeyPad_counter, A           
                bra     countdown
                return