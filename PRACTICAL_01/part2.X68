*-----------------------------------------------------------
* Title      : 
* Written by : Ariel Fajimiyo
* Date       : 14/1/25
* Description: MOVE operations in assembly
*-----------------------------------------------------------
    ORG    $1000        ; 
START:                  ; first instruction of program

    MOVE.L #%00001111, D1  ; move 32-bit value (Hexadecimal F) into D1
    MOVE.B D1, D2          ; move lower 8 bits of D1 into D2
    MOVE.B D1, $2000       ; move lower 8 bits of D1 into memory address $2000
    MOVE.B $2000, D2       ; move the byte from memory address $2000 into D2
    MOVE.B $2000, $3000    ; move the byte from $2000 to memory address $3000

    SIMHALT                ; halt simulator

* Put variables and constants here

    END    START           ; end of program

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
