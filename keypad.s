#include <xc.inc>
    
global		KeyPad_Rows, KeyPad_Columns, KeyPad_Setup, Check_KeyPress
psect		udata_acs   
KeyPad_counter: ds  1       
KeyPad_Value:   ds  1
   
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
		db      0x11, 0x21, 0x41, 0x81, 0x12, 0x22, 0x42, 0x82
		db	0x14, 0x24, 0x44, 0x84, 0x18, 0x28, 0x48, 0x88
		Lookup_Table  EQU 0x300
		counter	      EQU 0x10
		align	      2

Read_Lookup_Table:
		lfsr    0, Lookup_Table
		movlw   low highword(Table_Set_Up)
		movwf   TBLPTRU, A
		movlw   high(Table_Set_Up)
		movwf   TBLPTRH, A
		movlw   low(Table_Set_Up)
		movwf   TBLPTRL, A
		movlw   16   ; currently writes random values at start of table, don't know why
		movwf   counter, A
loop:		tblrd*+
		movff   TABLAT, POSTINC0
		decfsz  counter, A
		bra     loop
		goto    0

    
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
                
delay:		movlw   0x40
                movwf   KeyPad_counter, A
		
countdown:      decfsz  KeyPad_counter, A           
                bra     countdown
                return