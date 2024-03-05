include <xc.inc>
    
global		KeyPad_Rows, KeyPad_Columns, KeyPad_Setup, Check_KeyPress

psect		udata_acs   
KeyPad_counter: ds  1       
KeyPad_Value:   ds  1
value:		ds  1  

Table_Set_Up:	movlw    00000001B
		movwf	 value, A
		FSR	 EQU 04
		INDF	 EQU 00
		movlw	 0x20
		movwf    FSR
		movf     value
loop:           movwf    INDF
		incf     FSR
		
		goto     loop



    
psect		KeyPad_code, class = CODE

KeyPad_Setup:	clrf     LATE, A
                movlb    0x0f
                bsf      REPU
                clrf     TRISD, A
                return
    
KeyPad_Rows:	movlw    0x0f
                movwf    TRISE, A
                return
    
KeyPad_Columns:
                movlw    0xf0
                movwf    TRISE, A
                return
    
Check_KeyPress:
                call     KeyPad_Rows
                call     delay
                movff    PORTE, KeyPad_Value, A
                call     KeyPad_Columns
                call     delay
                movlw    0x0f
                andwf    KeyPad_Value, W, A
                iorwf    PORTE, W, A
                xorlw    0xff
                movwf    KeyPad_Value, A
                return
                
delay:		movlw    0x40
                movwf    KeyPad_counter, A
		
countdown:      decfsz   KeyPad_counter, A           
                bra      countdown
                return

output:		
		CPFSEQ   