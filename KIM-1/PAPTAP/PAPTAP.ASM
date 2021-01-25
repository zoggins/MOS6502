;NAM PAPTAP
;* HIGH SPEED PAPER TAPE LOADER PROGRAM
;* DEVELOPED BY DR. CHARLES ADAMS
;* TEXAS A&M UNIVERSITY
;*
;* MODIFIED BY CHRISTOPHER MALLERY
;* - Ported to KIM-1
;*
            .org	$9000
           
PADD = $1701					; Define absolute address of
								; Data Direction Reg. A
PAD	 = $1700					; Define absolute address of
								; Data Reg. A
PBDD = $1703					; Define absolute address of
								; Data Direction Reg. B
PBD	 = $1702					; Define absolute address of
								; Data Reg. B

; These have to be in zero page, you may have to 
; adjust their location depending on what you are 
; loading
ADDRLO  = $0E                   ; DEST ADDRESS POINTER
ADDRHI  = $0F           

OUTCH = $1EA0                   ; OUTPUT CHARACTER ROUTINE

ENTER:      JSR     PIASUP      ; INIT PIA
START:      JSR     PIADAT      ; GET 1ST BYTE
            CMP     #$3B        ; IS IT AN ;?
            BNE     START       ; IF NOT, START OVER
            LDA     #$00        ; CLEAR CHECKSUM
            STA     CHKHI
            STA     CHKLO
            JSR     GETBYTE     ; GET THE BYTE COUNT
            STA     NUMBYT
            JSR     GETADDR     ; GET ADDRESS
            LDY     #$00
LOOP:       JSR     GETBYTE     ; READ THE BYTES
            DEC     NUMBYT
            BEQ     CHKCHK      ; LAST BYTE IS CHECKSUM
            STA     (ADDRLO),Y
            INY
            JMP     LOOP

CHKCHK:     JSR     GBNOCHK     ; CHECK THE CHECKSUM   
            CMP     CHKHI          
            BNE     FAIL
            JSR     GBNOCHK
            CMP     CHKLO
            BEQ     START       ; GO TO NEXT LINE
FAIL:       LDA     #$21
            JSR     OUTCH
            BRK                 ;FAILED CHECK SUM, SO INTERRUPT

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
            BMI     GETDAT      ; DATA PRESENT? (BIT 7 == 1)
            JMP     DATLOP      ; NOT YET. KEEP TRYING.
GETDAT:     LDA     PAD         ; YES. GET THE DATA,
            JSR     OUTCH       ; PRINT IT OUT
            INC     PBD         ; RAISE ACK        
            RTS                 ; AND LEAVE...

;*********** GETBYTE - READ ASCII HEX BYTE (2 digits)
GETBYTE:    CALL    GBNOCHK
            STA     TMPBYTE     ; STASH THE BYTE
            CLC                 ; ADD TO CHKSUM
            ADC     CHKLO
            STA     CHKLO
            BCC     GBEXIT
            INC     CHKHI
GBEXIT:     LDA     TMPBYTE
            RTS

GBNOCHK:    JSR     A2H         ; GET FIRST CHARACTER TO HEX
            ASL     A           ; MOVE IT UP 4 BITS
            ASL     A
            ASL     A
            ASL     A
            STA     TMPBYTE
            JSR     A2H         ; GET SECOND CHARACTER TO HEX
            ADC     TMPBYTE     ; ADD THEM TOGETHER
            RTS

;*********** GETADDR - READ ADDRESS AND LOAD X
GETADDR:    JSR     GETBYTE
            STA     ADDRHI
            JSR     GETBYTE
            STA     ADDRLO
            RTS

;*********** A2H - READ SINGLE ASCII BYTE AND CONVERT TO HEX
A2H:        JSR     PIADAT      
            SBC     #$30        
            CMP     #09
            BCC     RT
            BEQ     RT
            SBC     #7
RT:         RTS

NUMBYT:     .byte   1           ; BYTES LEFT TO READ
TMPBYTE:    .byte   1
CHKHI:      .byte   1           ; RUNNING CHECKSUM
CHKLO:      .byte   1    

            .end