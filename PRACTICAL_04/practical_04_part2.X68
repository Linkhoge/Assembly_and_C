*-----------------------------------------------------------
* Title      : Player Health and NPC Interaction Simulation
* Written by : Ariel Fajimiyo
* Date       : 04/02/25
* Description: This program simulates player health updates and NPC interactions.
*              It also includes examples of OR, NOT, and EOR operations.
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

; Move Health to Memory Location $3000
    MOVE.B  #100, $3000

; Move Location of Player into Data Register
; X first Byte 0 to 15
; Y second Byte 0 to 15
    MOVE.B  #$12, D2

; Move Location of NPC into Data Register
; X first Byte 0 to 15
; Y second Byte 0 to 15
    MOVE.B  #$22, D3

; Bitwise AND D2 and D3
; Whats new location of Player
    AND.B   D2, D3

; Load Memory Address $3000 into
; Address Register A1
    LEA     $3000, A1

; Hit by NPC
; Non Player Character
    SUB.B   #20, (A1)

; Pickup Health Found
    ADD.B   #10, (A1)

; Example of OR operation
    MOVE.B  #3, D4      
    MOVE.B  #5, D5     
    OR.B    D4, D5       ; D5 = D5 OR D4 (Result: 7)

; Example of NOT operation
    MOVE.B  #3, D6       ;
    NOT.B   D6           ; D6 = NOT D6 (Result: -4)

; Example of EOR (XOR) operation
    MOVE.B  #6, D7       
    MOVE.B  #3, D0       
    EOR.B   D7, D0       ; D0 = D0 XOR D7 (Result: 5)


    SIMHALT                ; halt simulator

* Put variables and constants here

    END    START           ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
