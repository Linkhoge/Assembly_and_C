*-----------------------------------------------------------
*Title: Parameter Passing Example for EASY68k (Modified)
*Written by: Linkhoge
*Date Created: March-25-2025
*Description: Demonstrates passing parameters using registers and stack, performing arithmetic operations,
*             and running a loop to keep a running sum.
*             Highlights security vulnerabilities related to stack handling, input validation, and memory access.
*-----------------------------------------------------------

    ORG $1000

START
    CLR.L D3       ; Running sum initialized to 0
    MOVE.W #3, D4  ; Loop counter set to 3

GAME_LOOP
    MOVE.B #14, D0
    LEA PROMPT, A1
    TRAP #15

    * Read input as a string to control length
    LEA INPUT_BUFFER, A1
    MOVE.B #2, D0   ; Task 2: Read string into A1
    MOVE.W #10, D1  ; Max 10 chars (to fit 32-bit signed int)
    TRAP #15

    * Convert string to number with validation
    BSR STRING_TO_NUM
    TST.W D5        ; Check if conversion true
    BNE INVALID_INPUT
    MOVE.L D1, D2   ; Store first number in D2

    * Second number
    MOVE.B #14, D0
    LEA PROMPT, A1
    TRAP #15

    LEA INPUT_BUFFER, A1
    MOVE.B #2, D0
    MOVE.W #10, D1
    TRAP #15

    BSR STRING_TO_NUM
    TST.W D5
    BNE INVALID_INPUT
    BSR REGISTER_ADDER
    ADD.L D1, D3

    MOVE.B #14, D0
    LEA RESULT, A1
    TRAP #15

    MOVE.B #3, D0
    MOVE.L D1, D2
    TRAP #15

    BSR NEW_LINE

    SUBQ.W #1, D4
    BNE GAME_LOOP

    MOVE.B #14, D0
    LEA FINAL_RESULT, A1
    TRAP #15

    MOVE.L D3, D1
    MOVE.B #3, D0
    TRAP #15

    SIMHALT

INVALID_INPUT
    MOVE.B #14, D0
    LEA ERROR_MSG, A1
    TRAP #15
    BSR NEW_LINE
    BRA GAME_LOOP   ; Retry input

* Subroutine to convert string to number with validation
STRING_TO_NUM
    CLR.L D1        ; Result
    CLR.W D5        ; Error flag (0 = valid, 1 = invalid)
    MOVE.L A1, A2   ; Save string pointer
    MOVE.B (A2)+, D0 ; Check for negative sign
    CMP.B #'-', D0
    BNE POSITIVE
    MOVE.B #1, D6   ; Flag for negative number
    BRA START_CONVERT

POSITIVE
    MOVE.B #0, D6   ; Positive number
    SUBQ.L #1, A2   ; Rewind pointer

START_CONVERT
    CLR.L D1
    MOVE.L #0, D7   ; Digit counter

CONVERT_LOOP
    MOVE.B (A2)+, D0
    CMP.B #0, D0    ; Check for null terminator
    BEQ CHECK_RANGE

    CMP.B #'0', D0
    BLT INVALID
    CMP.B #'9', D0
    BGT INVALID

    SUB.B #'0', D0  ; Convert ASCII to digit
    MULU #10, D1    ; Shift left (D1 = D1 * 10)
    ADD.L D0, D1    ; Add new digit
    ADDQ.L #1, D7   ; Increment digit counter
    CMP.L #10, D7   ; Too many digits?
    BGT INVALID
    BRA CONVERT_LOOP

CHECK_RANGE
    TST.B D6        ; Negative number?
    BEQ POS_RANGE
    CMP.L #2147483648, D1
    BGT INVALID
    NEG.L D1        ; Make negative
    BRA DONE_CONVERT

POS_RANGE
    CMP.L #2147483647, D1
    BGT INVALID

DONE_CONVERT
    RTS

INVALID
    MOVE.W #1, D5   ; Set error flag
    RTS

REGISTER_ADDER
    * Check for arithmetic overflow
    MOVE.L D1, D0
    ADD.L D2, D0
    BVS OVERFLOW    ; Branch if overflow occurs
    MOVE.L D0, D1
    RTS

OVERFLOW
    MOVE.B #14, D0
    LEA OVERFLOW_MSG, A1
    TRAP #15
    CLR.L D1        ; Reset
    RTS

NEW_LINE
    MOVE.B #14, D0
    LEA CRLF, A1
    TRAP #15
    RTS

PROMPT DC.B 'Enter number: ',0
RESULT DC.B 'The sum is: ',0
FINAL_RESULT DC.B 'Final sum is: ',0
ERROR_MSG DC.B 'Invalid input! Please enter a valid number',0
OVERFLOW_MSG DC.B 'Arithmetic overflow occurred!',0
CRLF DC.B 13,10,0

INPUT_BUFFER DS.B 12  ; Buffer for string input

    END START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
