; ------------------------------------------------
;				 STEPHEN SAMPSON
;			MSP-430 EMULATOR TEST FILE
;				 ALL INSTRUCTIONS
; ------------------------------------------------
; For this test file, registers were initialized
; as shown below. This was done because at this
; stage I was not 100% sure the MOV instruction 
; worked as it should and wanted to isolate 
; possible causes of error.
; ------------------------------------------------
;uint16_t registers[16] = {							
;	0,      0xFFC0, 0x0008, 0,						 
;	4094,   0xFF00, 0x8AAB, 0x0080,					
;	0,      0xF000, 0x0F00, 0x00F0,					
;	0x000F, 0x000F, 0x000F, 0x000F					
;};		
; ------------------------------------------------


; DATA IN LOW MEMORY (>32)
ORG $FFC
DATA WORD $1357
DATA2 WORD $1234

; SET ADDRESS OF FIRST INSTRUCTION
ORG $1000

; ONE OPERAND INSTRUCTIONS
rrc		@R4+		
; LOC: 4094	 		= 	0x1234 (0001 0010 0011 0100) --> 0x091A (0000 1001 0001 1010)
; SREG {V, N, Z, C}	=	{0, 0, 0, 0}
; R4 incremented from 0x0FFE to 0x1000
					
swpb	R5			
; LOC: R5  			= 	0xFF00 (1111 1111 0000 0000) --> 0x00FF (0000 0000 1111 1111)
; SREG {V, N, Z, C}	=	{0, 0, 0, 0}				
					
rra		R6			
; LOC: R6 			=	0x8AAB (1000 1010 1010 1011) --> 0xC555 (1100 0101 0101 0101)
; SREG {V, N, Z, C}	=	{0, 1, 0, 1}					
					
sxt		R7			
; Loc: R7 			= 	0x0080 (0000 0000 1000 0000) --> 0xFF80 (1111 1111 1000 0000)
; SREG {V, N, Z, C}	=	{0, 1, 0, 1}					
					
push	R7			
; Loc: 65470 		=	0xFF80 (1111 1111 1000 0000)
; SREG {V, N, Z, C}	=	{0, 1, 0, 1}
					
END

;	After test, registers should contain the following:
;	0xFFBE	0xFFBE	0x000D	0x0000
;	0x1000	0x00FF	0xC555	0xFF80
;	0x0000	0xF000	0x0F00	0x00F0
;	0x000F	0x000F	0x000F	0x000F


