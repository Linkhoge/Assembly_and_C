*-----------------------------------------------------------
* Title      : Game Health 
* Written by : Ariel Fajimiyo
* Date       : 25/02/25
* Description: Demonstrates game health via stack
*-----------------------------------------------------------
    ORG    $1000

START:                  
    MOVE.L #HEALTH, -(SP) 
    JSR GAME_LOOP       
    BSR HEADS_UP_DISPLAY 
    BRA END             

GAME_LOOP:
    MOVEA.L 4(SP), A1   
    SUB.B #10, (A1)     ; Subtract 10 from HEALTH
    RTS                 ; Return from subroutine

HEADS_UP_DISPLAY:
    LEA MESSAGE, A1
    MOVE.B #14, D0
    TRAP #15            ; Call TRAP #15 to display MESSAGE
    MOVE.B HEALTH, D1
    MOVE.B #3, D0       ; Set D0 to 3 (display value)
    TRAP #15
    RTS                 

HEALTH: DC.B 100        ; Define HEALTH with initial value 100
MESSAGE: DC.B 'Health:', 0 ; Define MESSAGE string

END:
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
