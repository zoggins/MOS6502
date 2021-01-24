;******************************
;* Demo of input and output
;* using switches and a speaker
;*
;* Schematic provided in folder
;* 
;* Adapted from the demo in the
;* KIM-1 manual.
;*
;******************************

			.org	$0200

PADD = $0903					; Define absolute address of
								; Data Direction Reg. A
PAD	 = $0901					; Define absolute address of
								; Data Reg. A

INIT:		LDA		#$01		; Define I/O  0=Input  1=Output
			STA		PADD		; PADD = PORT A DATA DIRECTION REG.
START:		INC		PAD			; Toggle PA0, PA1-PA7 Inputs
								; not affected
READ:		LDA		PAD			; READ switches into accumulator
			EOR		#$FF		; Complement switch value
			LSR		A			; Shift Accumulator 1 bit to the right
			TAX					; Transfer final count into X-Index
DELAY:		DEX					; Delay by an amount specified
			BPL		DELAY		; By the count in the X-Index
			BMI		START		; Go To START
			.end