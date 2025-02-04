*-----------------------------------------------------------
* Title      : Boss Fight RPG
* Written by : Ariel Fajimiyo
* Date       : 04/02/25
* Description: Simulates Boss losing HP to Player
*-----------------------------------------------------------
    ORG $1000


START:  ; Start of the program

    ; Initialize Player Data
    MOVE.B #$64, D0         ; Player Health = 100%
    MOVE.B #0, D1           ; Player Points = 0
    MOVE.B #$10, D2         ; Player X Position = 16
    MOVE.B #$20, D3         ; Player Y Position = 32

    ; Initialize Boss Data
    MOVE.B #$C8, D4         ; Boss Health = 200%
    MOVE.B #$30, D5         ; Boss X Position = 48
    MOVE.B #$40, D6         ; Boss Y Position = 64

    ; Address Register for Player Health
    LEA $3000, A0
    MOVE.B D0, (A0)         ; Store Player Health in memory

    ; Address Register for Boss Health
    LEA $3001, A1
    MOVE.B D4, (A1)         ; Store Boss Health in memory

    ; Player encounters Boss
    SUB.B #$10, (A0)        ; Player takes damage, Health -= 16
    SUB.B #$20, (A1)        ; Boss takes damage, Health -= 32

    ; Player gains points
    ADD.B #$5, D1           ; Player Points += 5

    ; Logical Operations
    AND.B D2, D5            ; AND Player X with Boss X
    OR.B D3, D6             ; OR Player Y with Boss Y
    EOR.B D2, D3            ; XOR Player X with Player Y

    SIMHALT                 ; Halt the simulator

    END START               ; End of the program
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
