;NAM PAPTAP
;* HIGH SPEED PAPER TAPE LOADER PROGRAM
;* DEVELOPED BY DR. CHARLES ADAMS
;* TEXAS A&M UNIVERSITY
;*
;* MODIFIED BY CHRISTOPHER MALLERY
;* - Ported to KIM-1
;*
;* D0 - D7  == PA 0-7
;* ACK      == PB 0
;* RDY      == PB 7

            .org	$9000
           
PADD = $1701					; Define absolute address of
								; Data Direction Reg. A
PAD	 = $1700					; Define absolute address of
								; Data Reg. A
PBDD = $1703					; Define absolute address of
								; Data Direction Reg. B
PBD	 = $1702					; Define absolute address of
								; Data Reg. B
OUTCH = $1EA0                   ; OUTPUT CHARACTER ROUTINE

PRTBYT = $1E3B                  ; PRINT BYTE IN ASCII HEX

; These have to be in zero page, you may have to 
; adjust their location depending on what you are 
; loading
ADDRLO  = $0000                 ; DEST ADDRESS POINTER
ADDRHI  = $0001           

ENTER:      JSR     PIASUP      ; INIT PIA
START:      JSR     PIADAT      ; GET 1ST BYTE
            CMP     #';'        ; IS IT AN ;?
            BNE     START       ; IF NOT, START OVER
            LDA     #$00        ; CLEAR CHECKSUM
            STA     CHKHI
            STA     CHKLO
            JSR     GETBYTE     ; GET THE BYTE COUNT
            STA     NUMBYT
            JSR     GETADDR     ; GET ADDRESS
LOOP:       JSR     GETBYTE     ; READ THE BYTES
            LDY     #$00
            STA     (ADDRLO),Y               
            DEC     NUMBYT
            BEQ     CHKCHK      ; LAST BYTE IS CHECKSUM
            INC     ADDRLO      ; INC DEST ADDRESS
            BNE     LOOP
            INC     ADDRHI
            JMP     LOOP

CHKCHK:     JSR     GBNOCHK     ; CHECK THE CHECKSUM   
            CMP     CHKHI          
            BNE     FAIL
            JSR     GBNOCHK
            CMP     CHKLO
            BEQ     START       ; GO TO NEXT LINE
FAIL:       LDA     #'!'
            JSR     OUTCH
            BRK                 ; FAILED CHECK SUM, SO INTERRUPT

;*********** PIASUP - PIA SETUP ROUTINE
PIASUP:     LDA		#$01		; Define I/O  0=Input  1=Output
			STA		PBDD		; PBDD = PORT B DATA DIRECTION REG.
            LDA     #$00        ; ACK = 0
            STA     PBD         
            LDA		#$00		; Define I/O  0=Input  1=Output
			STA		PADD		; PADD = PORT B DATA DIRECTION REG.
            INC     PBD         ; ACK = 1
            RTS                 ; LEAVE...

;*********** PIADAT - GET DATA FROM PIA
PIADAT:     INC     PBD         ; ACK = 0

DATLOP:     LDA     PBD         ; GET RDY 
            AND     #$80
            BMI     GETDAT      ; DATA PRESENT? (BIT 7 == 1)
            JMP     DATLOP      ; NOT YET. KEEP TRYING.
GETDAT:     LDA     PAD         ; YES. GET THE DATA,
            STA     TMPBYTE1
            JSR     OUTCH       ; PRINT IT OUT
            INC     PBD         ; RAISE ACK
            LDA     TMPBYTE1
            RTS                 ; AND LEAVE...

;*********** GETBYTE - READ ASCII HEX BYTE (2 digits)
GETBYTE:    JSR     GBNOCHK
            STA     TMPBYTE2     ; STASH THE BYTE
            CLC                  ; ADD TO CHKSUM
            ADC     CHKLO
            STA     CHKLO
            BCC     GBEXIT
            INC     CHKHI
GBEXIT:     LDA     TMPBYTE2
            RTS

GBNOCHK:    JSR     A2H         ; GET FIRST CHARACTER TO HEX
            ASL     A           ; MOVE IT UP 4 BITS
            ASL     A
            ASL     A
            ASL     A
            STA     TMPBYTE2
            JSR     A2H         ; GET SECOND CHARACTER TO HEX
            CLC
            ADC     TMPBYTE2     ; ADD THEM TOGETHER            
            RTS

;*********** GETADDR - READ ADDRESS AND LOAD X
GETADDR:    JSR     GETBYTE
            STA     ADDRHI
            JSR     GETBYTE
            STA     ADDRLO
            RTS

;*********** A2H - READ SINGLE ASCII BYTE AND CONVERT TO HEX
A2H:        JSR     PIADAT    
            SEC
            SBC     #'0'        
            CMP     #$0A
            BCC     RT
            SEC
            SBC     #7
RT:         RTS

NUMBYT:      .byte   1           ; BYTES LEFT TO READ
TMPBYTE1:    .byte   1
TMPBYTE2:    .byte   1
CHKHI:       .byte   1           ; RUNNING CHECKSUM
CHKLO:       .byte   1    

            .end