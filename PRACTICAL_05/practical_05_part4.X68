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
    BSR         COUNT_ENEMIES       ; Size of the ENEMY_POSITIONS Array
    MOVE.B      D0, D4              ; Reset Enemy count at begining of loop
    
    LEA         MSG_GAMELOOP, A1    ; Load and Draw Gameloop Message
    BSR         DRAW
    
    BSR         UPDATE              ; Call UPDATE
    BRA         GAME_LOOP           ; Call GAME_LOOP
    
UPDATE:

    MOVE.B      PLAYER_HEALTH, D1   ; Move Player Health into D1
    
    LEA         MSG_HEALTH, A1      ; Load and Draw Health Message
    BSR         DRAW
    
    MOVE.B      #3, D0              ; Display signed number in D1.L in decimal in smallest field.
    TRAP        #15
    
    LEA         CRLF, A1            ; Load and Carriage Return Line Feed
    BSR         DRAW
    
    
    CMP         #0, D1
    BLE         GAME_OVER
    ADD.L       #1, (A2)
    BSR         COLLISION
    RTS
    
DRAW:
    MOVE.B      #13, D0
    TRAP        #15
    RTS
    
COLLISION:
    MOVE.B      #1, D5
    LEA         ENEMY_POSITIONS, A3

ITERATE:
    CMP         D5, D4
    ADD.B       #1, D5
    BEQ         GAME_LOOP
    BNE         CHECK_ENEMIES
    RTS

CHECK_ENEMIES:
    MOVE.L      (A3)+, D2
    MOVE.L      (A2), D3
 
    CMP.L       D2, D3
    BEQ         REDUCE_HEALTH
    BNE         ITERATE
    
REDUCE_HEALTH:
    LEA         MSG_COLLISION, A1
    BSR         DRAW
    
    SUB.B       #DAMAGE, PLAYER_HEALTH
    
    LEA         MSG_DAMAGE, A1
    BSR         DRAW
    
    BRA         GAME_LOOP
    
GAME_OVER:
    LEA         MSG_GAMEOOVER, A1
    BSR         DRAW
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
