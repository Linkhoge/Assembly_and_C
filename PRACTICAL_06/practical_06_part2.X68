*-----------------------------------------------------------
* Title      : Trap Task Examples
* Written by : Ariel Fajimiyo
* Date       : 25/02/25
* Description: Demonstrates all trap tasks
*-----------------------------------------------------------
    ORG    $1000

START:                  ; first instruction of program

    ; Task 0
    LEA MESSAGE1, A1    ; Load address of MESSAGE1 into A1
    MOVE.B #0, D0       ; Trap #0: Display string with CR, LF
    TRAP #15

    ; Task 1
    LEA MESSAGE2, A1    ; Load address of MESSAGE2 into A1
    MOVE.B #1, D0       ; Trap #1: Display string without CR, LF
    TRAP #15

    ; Task 2
    LEA BUFFER, A1 ; Load address of INPUT_BUFFER into A1
    MOVE.B #2, D0       ; Trap #2: Read string from keyboard
    TRAP #15

    ; Task 4
    MOVE.B #4, D0       ; Trap #4: Read number from keyboard
    TRAP #15

    ; Task 5
    MOVE.B #5, D0       ; Trap #5: Read single character
    TRAP #15

    ; Task 6
    MOVE.B #'A', D1     ; Load character 'A' into D1
    MOVE.B #6, D0       ; Trap #6: Display single character
    TRAP #15

    ; Task 7
    MOVE.W #$0F0F, D1   ; Set cursor to row 15, column 15
    MOVE.B #11, D0      ; Trap #11: Set cursor position
    TRAP #15

    ; Task 12
    MOVE.B #0, D1
    MOVE.B #12, D0
    TRAP #15

    ; Task 13
    LEA MESSAGE3, A1
    MOVE.B #13, D0
    TRAP #15

    ; Task 14
    LEA MESSAGE4, A1
    MOVE.B #14, D0
    TRAP #15

    ; Task 16
    MOVE.B #2, D1       ; Do not display line feed when Enter is pressed
    MOVE.B #16, D0      ; Trap #16: Adjust display properties
    TRAP #15

    ; Task 17
    LEA MESSAGE5, A1
    MOVE.L #1234, D1
    MOVE.B #17, D0
    TRAP #15

    ; Task 18
    LEA MESSAGE6, A1
    MOVE.B #18, D0
    TRAP #15

    ; Task 19
    MOVE.L #$00000000, D1
    MOVE.B #19, D0
    TRAP #15

    ; Task 21
    MOVE.L #$00FF0000, D1
    MOVE.B #%0001, D2
    MOVE.B #21, D0
    TRAP #15

    ; Task 9
    SIMHALT             ; halt simulator

* Variables and constants
MESSAGE1: DC.B 'Hello, World!', 0  ; Null-terminated string
MESSAGE2: DC.B 'No CR, LF here!', 0 ; Null-terminated string
MESSAGE3: DC.B 'String with CR, LF', 0 ; Null-terminated string
MESSAGE4: DC.B 'String without CR, LF', 0 ; Null-terminated string
MESSAGE5: DC.B 'Number: ', 0       ; Null-terminated string
MESSAGE6: DC.B 'Enter a number: ', 0 ; Null-terminated string
BUFFER: DS.B 50              ; Buffer for keyboard input

    END    START        ; last line of source
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
