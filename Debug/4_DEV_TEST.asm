;------------------------------------------------------------------
; 				 ECED3403 - COMPUTER ARCHITECTURE
;				ASSIGNMENT #2 - AN MSP430 EMULATOR
;						DEVICE TEST FILE
;------------------------------------------------------------------
;	THIS FILE CONTAINS:
;		A test suite to configure six interrupt 
;		driven devices1, three each as input 
;		and output and to verify that both 
;		input and output interrupts are detected
;		and handled properly.
;	SUGGESTED METHODOLOGY:
;		Suggest to have input interrupt occur first
;		reading data in to it's data register. 
;		When the paired output interrupt occurs this
;		data is moved to the output data register and
; 		printed to the output file. 
;	PAIRINGS:
;		DEV0, DEV1, DEV2 for input.
;			DEV 3: move DEV0 DR to DEV3 DR for output
;			DEV 4: move DEV1 DR to DEV4 DR for output
;			DEV 5: move DEV2 DR to DEV5 DR for output
;	INPUT FILE:
;		Actual input file used for test appended to the
;		end of this file.
;	EXPECTED RESULTS:
;		The data registers for devices 0, 1, and 2
;		will be moved to the data registers of 
;		devices 3, 4, and 5 respectfully then these
;		output interrupts occur. This data register 
;		is then printed to the devices.out file
;		as specified in the assignment spec.
;			DEV0: reads 3 at sys_clk = 10
;			DEV1: reads 7 at sys_clk = 100
;			DEV2: reads 8 at sys_clk = 200
;			DEV3: writes 3 at sys_clk = 300
;			DEV4: writes 7 at sys_clk = 320
;			DEV5: writes 8 at sys_clk = 340
;	NOTE RE: SYS_CLK:
;		Actual value of sys_clk @ input and output
; 		may not match exactly the time specified 
;		depending on how many clock cycles the instruction
;		executing when the interrupt takes place takes to 
;		complete. This is because check_for_status_change
;		takes place before each instruction fetch.
;		Also, if an interrupt takes place while another 
;		interrupt is being processed it may behave in a 
;		number of ways depending on the values of the arrival
;		and processing times. 
;	POSSIBLE BEHAVIOURS: 
;		1) No interrupts are lost but that the time one occurs
;		at is later than expected due to a previous interrupt 
;		needing to complete before it can occur
;		2) If more than one interrupt occurs while one is taking
;		place then:
;------------------------------------------------------------------

zeroSC      byte 0			; DEV 0 STATUS REGISTER
zeroDR      byte 0			; DEV 0 DATA REGISTER
oneSC      	byte 0			; DEV 0 STATUS REGISTER
oneDR		byte 0			; DEV 0 DATA REGISTER
twoSC   	byte 0			; DEV 0 STATUS REGISTER
twoDR   	byte 0			; DEV 0 DATA REGISTER
threeSC     byte 0			; DEV 0 STATUS REGISTER
threeDR     byte 0			; DEV 0 DATA REGISTER
fourSC      byte 0			; DEV 0 STATUS REGISTER
fourDR      byte 0			; DEV 0 DATA REGISTER
fiveSC      byte 0			; DEV 0 STATUS REGISTER
fiveDR      byte 0			; DEV 0 DATA REGISTER

ISR0TEMPDATA EQU 50			; TEMPORARY DATA STORAGE
ISR1TEMPDATA EQU 50			; TEMPORARY DATA STORAGE
ISR2TEMPDATA EQU 50			; TEMPORARY DATA STORAGE
ISR3TEMPDATA EQU 50			; TEMPORARY DATA STORAGE
ISR4TEMPDATA EQU 50			; TEMPORARY DATA STORAGE
ISR5TEMPDATA EQU 50			; TEMPORARY DATA STORAGE

org $100					; change LC to: 0x0100

main						; main program execution @ LOC:100

mov #$FFC0,R1				; specify top of stack

mov #3,&zeroSC				; enable input interrupts on dev0
mov #3,&oneSC				; enable input interrupts on dev1
mov #3,&twoSC				; enable input interrupts on dev2
mov #1,&threeSC				; enable output interrupts on dev0
mov #1,&fourSC				; enable output interrupts on dev1
mov #1,&fiveSC				; enable output interrupts on dev2

BIS #8,R2					; GIE = 1, enable global interrupts

Loop						; Loop (while(R6<10) 
add #1,R6					; add 1 to R6
cmp #$0A,R6					; compare [R6] to 10
jne Loop					; if not equal goto Loop

final jmp final				; hold emulator (infinite loop)

org $200					; CHANGE LC TO 0x0200 (ISR ENTRY POINTS)

zeroISR						; DEV0 ISR ENTRY POINT (LOC: 0x0200)
mov &zeroDR,&threeDR		; move dev0 data register to dev3 data register for output
mov #7,R7					; do another instruction for good measure - ensure value is in register after interrupt using CTRL+C
reti						; return from interrupt

oneISR						; DEV1 ISR ENTRY POINT (LOC: 0x020C)
mov &oneDR,&fourDR			; move dev1 data register to dev4 data register for output
add #8,R8					; do another instruction for good measure - ensure value is in register after interrupt using CTRL+C
reti						; return from interrupt

twoISR						; DEV2 ISR ENTRY POINT (LOC: 0x0218)
mov &twoDR,&fiveDR			; move dev2 data register to dev5 data register for output
add #9,R9					; do another instruction for good measure - ensure value is in register after interrupt using CTRL+C
reti						; return from interrupt

threeISR					; DEV3 ISR ENTRY POINT (LOC: 0x0224)
mov &threeDR,&ISR3TEMPDATA	; move dev3 data register to temp storage location (for fun mainly)
add #10,R10					; do another instruction for good measure - ensure value is in register after interrupt using CTRL+C
reti						; return from interrupt

fourISR						; DEV4 ISR ENTRY POINT (LOC: 0x0230)
mov &fourDR,&ISR4TEMPDATA	; move dev4 data register to temp storage location (for fun mainly)
add #11,R11					; do another instruction for good measure - ensure value is in register after interrupt using CTRL+C
reti						; return from interrupt

fiveISR						; DEV5 ISR ENTRY POINT (LOC: 0x023C)
mov &fiveDR,&ISR5TEMPDATA	; move dev5 data register to temp storage location (for fun mainly)
add #12,R12					; do another instruction for good measure - ensure value is in register after interrupt using CTRL+C
reti						; return from interrupt

org $FFC0					; CHANGE LOC TO 0xFFC0 (ISR VECTOR TABLE)

word 512					; ISR 0 ENTRY POINT
word 524					; ISR 1 ENTRY POINT
word 536					; ISR 2 ENTRY POINT
word 548					; ISR 3 ENTRY POINT
word 560					; ISR 4 ENTRY POINT
word 572					; ISR 5 ENTRY POINT

end							; END
