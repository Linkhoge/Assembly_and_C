*-----------------------------------------------------------
* Title      : Stack Manipulation Task
* Written by : Ariel Fajimiyo
* Date       : 24/02/25
* Description: Testing stack manipulation using MOVE.B instructions
*-----------------------------------------------------------
    ORG    $1000

START:                  ; first instruction of program
    LEA $4000, A7       
    
    ; Push byte value onto the stack
    MOVE.B #1, -(A7)
    MOVE.B #2, -(A7)
    MOVE.B #3, -(A7)
    MOVE.B #4, -(A7)
    
    ; Pop byte value from stack into register D1
    MOVE.B (A7)+, D1
    MOVE.B (A7)+, D1
    MOVE.B (A7)+, D1
    MOVE.B (A7)+, D1

END:

* Put variables and constants here

    END    START        ; last line of source
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
