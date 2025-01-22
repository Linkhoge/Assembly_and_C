
    ORG    $1000
START:
    
    MOVE.L #100, D0         
    MOVE.L #$100, D1         
    MOVE.L #100, D2    

    MOVE.L D0, $3000        
    MOVE.L D1, $3010        
    MOVE.L D2, $3020        

    MOVE.W #100, D3          
    MOVE.W #$100, D4         

    MOVE.W D3, $3030        
    MOVE.W D4, $3040        

    MOVE.B #25, D5          
    MOVE.B #$64, D6             
    MOVE.B #%10001111, D7      

    MOVE.B D5, $3050        
    MOVE.B D6, $3060        
    MOVE.B D7, $3070        


    SIMHALT


    END    START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
