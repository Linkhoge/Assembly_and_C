*-----------------------------------------------------------
* Title      : part3.X68
* Written by : Ariel Fajimiyo
* Date       : 14/1/25
* Description: Demonstrates text and output via TRAP
*-----------------------------------------------------------

    ORG    $1000
START:
    
    MOVE.B #$64, D1
    LEA text, A1
    MOVE #14, D0
    TRAP #15
    
    MOVE #3, D0
    TRAP #15

    SIMHALT

text    DC.B 'Data Register: ', 0 

    END    START           
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
