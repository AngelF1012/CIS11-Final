;Option B Test Score Calculator
.ORIG X3000

LD R6 STACK_PTR
JSR INPUTS					; Jump to subroutine Inputs
JSR TEST_CALCS					; Jump to subroutine TEST_CALCS
JSR DISPLAY_OUTPUTS				; Jump to subroutine DISPLAY_OUTPUTS
HALT

INPUTS

	ST R7, TEMP_R7
	JSR PUSH_R7				; Jump to subroutine PUSH R7
	LD R5, ARR				; Load array adress to R5
	LD R7, ARR_LEN				; Load 5 inputs

GET_INPUTS_LOOP
	
	ST R7, TEMP_COUNTER			
	LEA R0, PROMPT_STR
	PUTS
	GETC
	OUT
	ADD R1, R0, #0
	LD R4, ASCII
	NOT R4, R4
	ADD R4, R4, #1
	ADD R1, R1, R4
						; Input validation

	BRn INVALID_INPUT
	LD R3, ASCII_UPPER_LIMIT
	NOT R3, R3
	ADD R3, R3, #1
	ADD R3, R0, R3
	BRzp INVALID_INPUT
	
	
	ADD R2, R1, R1				
	ADD R1, R2, R2
	ADD R1, R1, R1
	ADD R2, R2, R1 				; Multiply digit 1 times 10
	GETC
	OUT
	ADD R1, R0, #0

	ADD R1, R1, R4 				; Get digit 2
						; Input validation 

	BRn INVALID_INPUT
	LD R3, ASCII_UPPER_LIMIT
	NOT R3, R3
	ADD R3, R3, #1
	ADD R3, R0, R3
	BRzp INVALID_INPUT

	ADD R4, R1, R2 				; Add both digits together
	STR R4, R5, #0
	LD R0, NL
	OUT
	ADD R5, R5, #1
	LD R7, TEMP_COUNTER
	ADD R7, R7, #-1
	BRp GET_INPUTS_LOOP
	BR POP_R7
	
INVALID_INPUT
	
	LEA R0, INVALID_NUM_STR			; Invalid input validation message
	PUTS
	LD R7, TEMP_COUNTER
	BR GET_INPUTS_LOOP

TEST_CALCS
	ST R7, TEMP_R7
	JSR PUSH_R7

	LD R5, ARR				; Load the start of array
	LDR R0, R5, #0				; First value of arr
	ADD R5, R5, #1
	ADD R1, R0, #0				; Sum
	ADD R2, R0, #0				; Minimum
	ST R2, MIN
	ADD R3, R0, #0				; Maximum
	LD R7, ARR_LEN
	ADD R7, R7, #-1
						; start of Min, Max, Avg calculations

GET_EXTREMA_LOOP

	LDR R0, R5, #0
	ADD R1, R1, R0				; Add value to sum
	ST R6, TEMP_R6				; Save r6
	LD R2, MIN				; Compare value to current minimum
	NOT R6, R2
	ADD R6, R6, #1
	ADD R6, R0, R6
	BRn UPDATE_MIN
	BR CHECK_MAXIMUM

UPDATE_MIN
	ST R0, MIN

CHECK_MAXIMUM
	NOT R6, R3
	ADD R6, R6, #1
	ADD R6, R0, R6
	BRn SKIP_UPDATE
	ADD R3, R0, #0
SKIP_UPDATE
	LD R6, TEMP_R6				; R6 to stack pointer
	ADD R5, R5, #1
	ADD R7, R7, #-1
	BRp GET_EXTREMA_LOOP
	ST R3, MAX

						; done getting extrema, calculate average
	AND R0, R0, #0
	ADD R7, R1, #0
	LD R1, ARR_LEN				; Load divisor (5) into R1
	AND R2, R2, #0				; result for average
DIV_LOOP
	NOT R5, R1
	ADD R5, R5, #1
	ADD R7, R7, R5
	BRn DIV_EXIT
	ADD R2, R2, #1
	BR DIV_LOOP
DIV_EXIT
	ST R2, AVG
	BR POP_R7

DISPLAY_OUTPUTS

	ST R7, TEMP_R7
	JSR PUSH_R7	

	LEA R0, MIN_STR				; Display min
	PUTS
	LD R0, MIN
	JSR PRINT_NUMBER
	LD R0, NL
	OUT

	LEA R0, MAX_STR				; Display Max
	PUTS
	LD R0, MAX
	JSR PRINT_NUMBER
	LD R0, NL
	OUT

	LEA R0, AVG_STR				; Display average
	PUTS
	AND R4, R4, #0
	ADD R4, R4, #2
	ST R4, TEMP_R4 				; use for a conditional statement later
	LD R0, AVG	
	JSR PRINT_NUMBER
	LD R0, NL
	OUT

	BR POP_R7

PRINT_NUMBER
	ST R7, TEMP_R7
	JSR PUSH_R7
	AND R1, R1, #0 				; Quotient
	ADD R2, R0, #0 				; Remainder

PRINT_DIV_LOOP
	
	ADD R2, R2, #-10
	BRn PRINT_DIV_EXIT
	ADD R1, R1, #1
	BR PRINT_DIV_LOOP

PRINT_DIV_EXIT
	ADD R2, R2, #10
	LD R0, ASCII
	ADD R0, R0, R1
	OUT
	LD R0, ASCII
	ADD R0, R0, R2
	OUT
	LD R4, TEMP_R4				; Change letter grade output
	ADD R4, R4, #-2
	BRzp LETTER_GRADE
	BR POP_R7	

LETTER_GRADE
	ADD R4, R1, #-6				; Handling of grades past D => A=9,B=8,C=7,D=6,F<=5
	BRzp SKIP_ADJUST
	AND R1, R1, #0
	ADD R1, R1, #4
SKIP_ADJUST
	AND R3, R3, #0
	ADD R3, R3, #9				
	NOT R1, R1
	ADD R1, R1, #1 
	ADD R3, R3, R1 				; If A, remainder will be 9, so 9-9=0.
	LD R0, NL
	OUT
	LEA R0, LETTER_STR
	PUTS
	LD R4, GRADE_ASCII_OFFSET
	ADD R0, R3, R4
	OUT
	BR POP_R7
	

PUSH_R7

	ST R7, STACK_RETURN
	ADD R1, R6, #-1
	LD R3, STACK_LIMIT
	ADD R3, R3, R1
	BRn STACK_OVERFLOW
	ADD R6, R6, #-1
	LD R7, TEMP_R7
	STR R7, R6, #0
	LD R7, STACK_RETURN
	RET

POP_R7
	LDR R7, R6, #0
	ADD R6, R6, #1
	RET

STACK_OVERFLOW
	LEA R0, STACK_OVERFLOW_STR
	PUTS
	HALT

NL			.FILL X0A
ASCII			.FILL X30
ASCII_UPPER_LIMIT	.Fill x3A
GRADE_ASCII_OFFSET	.FILL X41
ARR			.FILL X3200
ARR_LEN			.FILL #5
MIN			.BLKW 1
MAX			.BLKW 1
AVG			.BLKW 1
TEMP_COUNTER		.BLKW 1
TEMP_R4			.BLKW 1
TEMP_R6			.BLKW 1
TEMP_R7			.BLKW 1
STACK_RETURN		.BLKW 1
STACK_PTR		.FILL X4000
STACK_LIMIT		.FILL XC300
INVALID_NUM_STR		.STRINGZ "\nInvalid input, try again.\n"
STACK_OVERFLOW_STR	.STRINGZ "\nSTACK OVERFLOW.\n"
PROMPT_STR		.STRINGZ "Input Grade (0-99): "
MIN_STR			.STRINGZ "Min: "
MAX_STR			.STRINGZ "Max: "
AVG_STR			.STRINGZ "Average: "
LETTER_STR		.STRINGZ "Letter Grade: "

.END