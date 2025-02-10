*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000

; D0 Used for Trap Codes, An Counting ENEMIES
; D1 Used for Players Health
; D2 Used for Enemy Positions
; D4 Used for ENEMY count
; A0 for counting enemies
; A1 for progress messages
; A2 used for PLAYER_X
; A3 used for ENEMY_POSITIONS

DAMAGE          EQU 10              ; Damage when Collisions occur

START:                  
    LEA         PLAYER_X, A2        ; Player will move along X axis
    LEA         ENEMY_POSITIONS, A3 ; Enemy positions or spawn points
    BRA         GAME_LOOP
    
GAME_LOOP:
    BSR         COUNT_ENEMIES
    MOVE.B      D0, D4
    
    LEA         MSG_GAMELOOP, A1
    BSR         DRAW

* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
