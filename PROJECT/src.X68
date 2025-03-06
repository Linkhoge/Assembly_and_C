*-----------------------------------------------------------
* Title      : House Builder
* Written by : Ariel Fajimiyo
* Date       : 28/02/25
* Description: Assembly Game for my Final Project. Involves simple math operations for buying and creating houses.
*-----------------------------------------------------------

*-------------------------------------------------------
* STARTING MEMORY ADDRESS FOR THE PROGRAMME $1000
*-------------------------------------------------------
	ORG $1000
*-------------------------------------------------------
*CHOOSE TO BE A MINI KNIGHT OR A TINY EXPLORER
*-------------------------------------------------------

*-------------------------------------------------------
*VALIDATION VALUES TO BE USED, MODIFY AS NEEDED
*-------------------------------------------------------
EXIT		EQU 0			;USED TO EXIT ASSEMBLY PROGRAM

*-------------------------------------------------------
* HOUSE BUILDING COSTS
*-------------------------------------------------------
DETACHED_COST_WOOD:    EQU 10   ; WOOD REQUIRED TO BUILD A DETACHED HOUSE
DETACHED_COST_STONE:   EQU 5    ; STONE REQUIRED TO BUILD A DETACHED HOUSE
DETACHED_COST_METAL:   EQU 3    ; METAL REQUIRED TO BUILD A DETACHED HOUSE

APARTMENT_COST_WOOD:   EQU 20   ; WOOD REQUIRED TO BUILD AN APARTMENT
APARTMENT_COST_STONE:  EQU 10   ; STONE REQUIRED TO BUILD AN APARTMENT
APARTMENT_COST_METAL:  EQU 5    ; METAL REQUIRED TO BUILD AN APARTMENT

BUILDING_COST_WOOD:    EQU 50   ; WOOD REQUIRED TO BUILD A BUILDING
BUILDING_COST_STONE:   EQU 30   ; STONE REQUIRED TO BUILD A BUILDING
BUILDING_COST_METAL:   EQU 10   ; METAL REQUIRED TO BUILD A BUILDING

MANSION_COST_WOOD:     EQU 100  ; WOOD REQUIRED TO BUILD A MANSION
MANSION_COST_STONE:    EQU 50   ; STONE REQUIRED TO BUILD A MANSION
MANSION_COST_METAL:    EQU 20   ; METAL REQUIRED TO BUILD A MANSION

DANGER_LOC  EQU 100         ;USED FOR SIMPLE COLLISION DETECTION
                            ;* EXAMPLE FOR A HIT (GIANT FOOTSTEP)

*START OF GAME
START:
    MOVE.B  #100,$4000      ; PUT BRAVERY POINTS IN MEMORY LOCATION $4000
    LEA     $4000,A3        ; ASSIGN ADDRESS A3 TO THAT MEMORY LOCATION

    ; INITIALIZE VARIABLES
    MOVE.W  #0,HOUSES       ; INITIALIZE HOUSES BUILT TO 0
    MOVE.W  #100,BUCKS      ; INITIALIZE BUCKS TO 100
    MOVE.W  #0,PROFIT       ; INITIALIZE PROFIT TO 0
    MOVE.W  #0,WOOD         ; INITIALIZE WOOD TO 0
    MOVE.W  #0,STONE        ; INITIALIZE STONE TO 0
    MOVE.W  #0,METAL        ; INITIALIZE METAL TO 0

    BSR     WELCOME         ; BRANCH TO THE WELCOME SUBROUTINE
    BSR     DISPLAY_OBJECTIVE ; DISPLAY OBJECTIVE AND WAIT FOR KEY PRESS
    BSR     GAME            ; BRANCH TO THE GAME SUBROUTINE
    
*GAME LOOP
    ORG     $3000           ;THE REST OF THE PROGRAM IS TO BE LOCATED FROM 3000 ONWARDS

*-------------------------------------------------------
*-------------------GAME SUBROUTINE---------------------
*-------------------------------------------------------
GAME:
    BSR     GAMELOOP        ;BRANCH TO GAMELOOP SUBROUTINE
    RTS                     ;RETURN FROM GAME: SUBROUTINE
          
END:
    SIMHALT

*-------------------------------------------------------
*-------------------WELCOME SUBROUTINE------------------
*-------------------------------------------------------
WELCOME:
    BSR     ENDL
    LEA     WELCOME_MSG,A1  ; DISPLAY WELCOME MESSAGE
    MOVE.B  #14,D0
    TRAP    #15

*-------------------------------------------------------
*---------GAMEPLAY INPUT VALUES SUBROUTINE--------------
*-------------------------------------------------------    
INPUT:
    RTS

*-------------------------------------------------------
*----------------GAMELOOP (MAIN LOOP)-------------------
*------------------------------------------------------- 
GAMELOOP:
    BSR     INPUT           ;BRANCH TO INPUT SUBROUTINE
    BSR     UPDATE          ;BRANCH TO UPDATE GAME SUBROUTINE 
    ;BSR     CLEAR_SCREEN    ;CLEARS THE SCREEN 
    BSR     DRAW            ;BRANCH TO DRAW GAME SUBROUTINE           
    ;BSR     CLEAR_SCREEN    ;CLEARS THE SCREEN 
    BSR     GAMEPLAY        ;BRANCH TO GAMEPLAY SUBROUTINE
    ;BSR     CLEAR_SCREEN    ;CLEARS THE SCREEN        
    ;BSR     HUD             ;BRANCH TO HUD SUBROUTINE
    ;BSR     CLEAR_SCREEN    ;CLEARS THE SCREEN
    
    BSR     REPLAY          ;BRANCH TO REPLAY SUBROUTINE 
    BSR     CLEAR_SCREEN    ;CLEARS THE SCREEN
    RTS                     ;RETURN FROM GAMELOOP: SUBROUTINE       

*-------------------------------------------------------
*----------------UPDATE QUEST PROGRESS------------------
*  COMPLETE QUEST
*------------------------------------------------------- 
UPDATE:
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE   
    LEA     UPDATE_MSG,A1   ;ASSIGN MESSAGE TO ADDRESS REGISTER A1 
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE
    RTS                     

*-------------------------------------------------------
*-----------------DRAW QUEST UPDATES--------------------
* DRAW THE GAME PROGRESS INFORMATION, STATUS REGARDING
* QUEST
*------------------------------------------------------- 
DRAW:
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE            
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE    
    LEA     DRAW_MSG,A1     ;ASSIGN MESSAGE TO ADDRESS REGISTER A1     
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE
    RTS                     ;RETURN FROM DRAW: SUBROUTINE

*-------------------------------------------------------
*---GAME PLAY (QUEST PROGRESS)--------------------------
*------------------------------------------------------- 
*-------------------------------------------------------
* GAMEPLAY SUBROUTINE
* HANDLES THE MAIN GAME LOOP AND MENU OPTIONS
*-------------------------------------------------------
GAMEPLAY:
    BSR     ENDL            ; NEW LINE
    BSR     DECORATE        ; DECORATE THE SCREEN
    LEA     GAMEPLAY_MSG,A1 ; LOAD GAMEPLAY MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15

GAMEPLAY_MENU:
    BSR HUD
    BSR     DECORATE        ; DECORATE THE SCREEN
    LEA     GAMEPLAY_MENU_MSG,A1 ; LOAD GAMEPLAY MENU MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15

    ; READ PLAYER INPUT
    MOVE.B  #4,D0           ; READ PLAYER INPUT
    TRAP    #15             ; WAIT FOR KEY PRESS

    ; CHECK FOR DEV MODE (666)
    CMP.W   #666,D1         ; CHECK IF INPUT IS 666
    ; BEQ     DEV_MODE        ; IF YES, BRANCH TO DEV MODE

    ; VALIDATE NORMAL INPUT (1-5)
    CMP.B   #1,D1           ; CHECK IF PLAYER CHOSE 1 (GATHER RESOURCES)
    BEQ     OPTION_1        ; BRANCH TO OPTION 1 HANDLER
    CMP.B   #2,D1           ; CHECK IF PLAYER CHOSE 2 (BUILD HOUSE)
    BEQ     OPTION_2        ; BRANCH TO OPTION 2 HANDLER
    CMP.B   #3,D1           ; CHECK IF PLAYER CHOSE 3 (SELL HOUSE)
    BEQ     OPTION_3        ; BRANCH TO OPTION 3 HANDLER
    CMP.B   #4,D1           ; CHECK IF PLAYER CHOSE 4 (VIEW STATS)
    BEQ     OPTION_4        ; BRANCH TO OPTION 4 HANDLER
    CMP.B   #5,D1           ; CHECK IF PLAYER CHOSE 5 (QUIT GAME)
    BEQ     OPTION_5        ; BRANCH TO OPTION 5 HANDLER

    ; INVALID INPUT, LOOP BACK
    LEA     INVALID_INPUT_MSG,A1 ; LOAD INVALID INPUT MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    BRA     GAMEPLAY_MENU   ; LOOP BACK TO DISPLAY MENU AGAIN

*-------------------------------------------------------
* OPTION 1: GATHER RESOURCES
*-------------------------------------------------------
OPTION_1:
    BSR     GATHER_RESOURCES ; BRANCH TO GATHER_RESOURCES SUBROUTINE
    BRA     GAMEPLAY_MENU    ; RETURN TO GAMEPLAY MENU

*-------------------------------------------------------
* OPTION 2: BUILD HOUSE
*-------------------------------------------------------
OPTION_2:
    BSR     BUILD_HOUSE_MENU     ; BRANCH TO BUILD_HOUSE SUBROUTINE
    BSR     PRESS_CONTINUE  ; RETURN TO MAIN MENU

*-------------------------------------------------------
* OPTION 3: SELL HOUSE
*-------------------------------------------------------
OPTION_3:
    BSR     SELL_HOUSE      ; BRANCH TO SELL_HOUSE SUBROUTINE
    BSR     PRESS_CONTINUE  ; RETURN TO MAIN MENU

*-------------------------------------------------------
* OPTION 4: VIEW STATS
*-------------------------------------------------------
OPTION_4:
    BSR     VIEW_STATS      ; BRANCH TO VIEW_STATS SUBROUTINE
    BSR     PRESS_CONTINUE  ; RETURN TO MAIN MENU

*-------------------------------------------------------
* OPTION 5: QUIT GAME
*-------------------------------------------------------
OPTION_5:
    LEA     OPTION_5_MSG,A1 ; LOAD QUIT GAME MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    SIMHALT                 ; HALT THE PROGRAM (QUIT GAME)

*-------------------------------------------------------
* BUILD_HOUSE_MENU SUBROUTINE
* DISPLAYS A SUBMENU FOR BUILDING DIFFERENT TYPES OF HOUSES
*-------------------------------------------------------
BUILD_HOUSE_MENU:
    BSR     ENDL            ; NEW LINE
    BSR     DECORATE        ; DECORATE THE SCREEN
    LEA     BUILD_HOUSE_MENU_MSG,A1 ; LOAD BUILD HOUSE MENU MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15

    ; READ PLAYER INPUT
    MOVE.B  #4,D0           ; READ PLAYER INPUT
    TRAP    #15             ; WAIT FOR KEY PRESS

    ; VALIDATE INPUT
    CMP.B   #1,D1           ; CHECK IF PLAYER CHOSE 1 (DETACHED)
    BEQ     BUILD_DETACHED  ; BRANCH TO BUILD_DETACHED HANDLER
    CMP.B   #2,D1           ; CHECK IF PLAYER CHOSE 2 (APARTMENT)
    BEQ     BUILD_APARTMENT ; BRANCH TO BUILD_APARTMENT HANDLER
    CMP.B   #3,D1           ; CHECK IF PLAYER CHOSE 3 (BUILDING)
    BEQ     BUILD_BUILDING  ; BRANCH TO BUILD_BUILDING HANDLER
    CMP.B   #4,D1           ; CHECK IF PLAYER CHOSE 4 (MANSION)
    BEQ     BUILD_MANSION   ; BRANCH TO BUILD_MANSION HANDLER
    CMP.B   #5,D1           ; CHECK IF PLAYER CHOSE 5 (BACK TO MAIN MENU)
    BEQ     BACK_TO_MAIN    ; BRANCH BACK TO MAIN MENU

    ; INVALID INPUT, LOOP BACK
    LEA     INVALID_INPUT_MSG,A1 ; LOAD INVALID INPUT MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    BRA     BUILD_HOUSE_MENU ; LOOP BACK TO DISPLAY MENU AGAIN

*-------------------------------------------------------
* BUILD_HOUSE SUBROUTINE
* BUILDS A HOUSE BASED ON THE SELECTED TYPE
*-------------------------------------------------------

*-------------------------------------------------------
* BUILD_DETACHED SUBROUTINE
* BUILDS A DETACHED HOUSE
*-------------------------------------------------------
BUILD_DETACHED:
    ; CHECK RESOURCES FOR DETACHED HOUSE
    CMP.W   #10,WOOD        ; REQUIRE 10 WOOD
    BLT     NOT_ENOUGH_WOOD
    CMP.W   #5,STONE        ; REQUIRE 5 STONE
    BLT     NOT_ENOUGH_STONE
    CMP.W   #3,METAL        ; REQUIRE 3 METAL
    BLT     NOT_ENOUGH_METAL

    ; DEDUCT RESOURCES
    SUB.W   #10,WOOD        ; DEDUCT 10 WOOD
    SUB.W   #5,STONE        ; DEDUCT 5 STONE
    SUB.W   #3,METAL        ; DEDUCT 3 METAL

    ; INCREMENT HOUSES BUILT
    ADD.W   #1,HOUSES       ; ADD 1 HOUSE

    ; DISPLAY HOUSE ART
    LEA     HOUSE_ART,A1    ; LOAD HOUSE ART ADDRESS
    MOVE.B  #14,D0          ; DISPLAY STRING (TRAP #15, FUNCTION 14)
    TRAP    #15             ; PRINT THE HOUSE ART

    ; DISPLAY SUCCESS MESSAGE
    LEA     DETACHED_BUILT_MSG,A1 ; LOAD DETACHED HOUSE BUILT MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    RTS                     ; RETURN FROM BUILD_DETACHED

*-------------------------------------------------------
* BUILD_APARTMENT SUBROUTINE
* BUILDS AN APARTMENT
*-------------------------------------------------------
BUILD_APARTMENT:
    ; CHECK RESOURCES FOR APARTMENT
    CMP.W   #20,WOOD        ; REQUIRE 20 WOOD
    BLT     NOT_ENOUGH_WOOD
    CMP.W   #10,STONE       ; REQUIRE 10 STONE
    BLT     NOT_ENOUGH_STONE
    CMP.W   #5,METAL        ; REQUIRE 5 METAL
    BLT     NOT_ENOUGH_METAL

    ; DEDUCT RESOURCES
    SUB.W   #20,WOOD        ; DEDUCT 20 WOOD
    SUB.W   #10,STONE       ; DEDUCT 10 STONE
    SUB.W   #5,METAL        ; DEDUCT 5 METAL

    ; INCREMENT HOUSES BUILT
    ADD.W   #1,HOUSES       ; ADD 1 HOUSE

    ; DISPLAY APARTMENT ART
    LEA     APARTMENT_ART,A1 ; LOAD APARTMENT ART ADDRESS
    MOVE.B  #14,D0          ; DISPLAY STRING (TRAP #15, FUNCTION 14)
    TRAP    #15             ; PRINT THE APARTMENT ART


    ; DISPLAY SUCCESS MESSAGE
    LEA     APARTMENT_BUILT_MSG,A1 ; LOAD APARTMENT BUILT MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    RTS                     ; RETURN FROM BUILD_APARTMENT

*-------------------------------------------------------
* BUILD_BUILDING SUBROUTINE
* BUILDS A BUILDING
*-------------------------------------------------------
BUILD_BUILDING:
    ; CHECK RESOURCES FOR BUILDING
    CMP.W   #50,WOOD        ; REQUIRE 50 WOOD
    BLT     NOT_ENOUGH_WOOD
    CMP.W   #30,STONE       ; REQUIRE 30 STONE
    BLT     NOT_ENOUGH_STONE
    CMP.W   #10,METAL       ; REQUIRE 10 METAL
    BLT     NOT_ENOUGH_METAL

    ; DEDUCT RESOURCES
    SUB.W   #50,WOOD        ; DEDUCT 50 WOOD
    SUB.W   #30,STONE       ; DEDUCT 30 STONE
    SUB.W   #10,METAL       ; DEDUCT 10 METAL

    ; INCREMENT HOUSES BUILT
    ADD.W   #1,HOUSES       ; ADD 1 HOUSE

    ; DISPLAY BUILDING ART
    LEA     BUILDING_ART,A1 ; LOAD BUILDING ART ADDRESS
    MOVE.B  #14,D0          ; DISPLAY STRING (TRAP #15, FUNCTION 14)
    TRAP    #15             ; PRINT THE BUILDING ART

    ; DISPLAY SUCCESS MESSAGE
    LEA     BUILDING_BUILT_MSG,A1 ; LOAD BUILDING BUILT MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    RTS                     ; RETURN FROM BUILD_BUILDING

    BUILD_MANSION:
    ; CHECK RESOURCES FOR MANSION
    CMP.W   #100,WOOD       ; REQUIRE 100 WOOD
    BLT     NOT_ENOUGH_WOOD
    CMP.W   #50,STONE       ; REQUIRE 50 STONE
    BLT     NOT_ENOUGH_STONE
    CMP.W   #20,METAL       ; REQUIRE 20 METAL
    BLT     NOT_ENOUGH_METAL

    ; DEDUCT RESOURCES
    SUB.W   #100,WOOD       ; DEDUCT 100 WOOD
    SUB.W   #50,STONE       ; DEDUCT 50 STONE
    SUB.W   #20,METAL       ; DEDUCT 20 METAL

    ; INCREMENT HOUSES BUILT
    ADD.W   #1,HOUSES       ; ADD 1 HOUSE

    ; DISPLAY MANSION ART
    LEA     MANSION_ART,A1  ; LOAD MANSION ART ADDRESS
    MOVE.B  #14,D0          ; DISPLAY STRING (TRAP #15, FUNCTION 14)
    TRAP    #15             ; PRINT THE MANSION ART

    ; DISPLAY SUCCESS MESSAGE
    LEA     MANSION_BUILT_MSG,A1 ; LOAD MANSION BUILT MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    RTS                     ; RETURN FROM BUILD_MANSION

*-------------------------------------------------------
* BACK_TO_MAIN SUBROUTINE
* RETURNS TO THE MAIN MENU
*-------------------------------------------------------
BACK_TO_MAIN:
    RTS                     ; RETURN TO MAIN MENU
    
*-------------------------------------------------------
*-----------------HEADS UP DISPLAY (SCORE)--------------
*-------------------------------------------------------   
HUD:
    BSR     ENDL            
    BSR     DECORATE        
    LEA     HUD_MSG,A1      
    MOVE.B  #14,D0          
    TRAP    #15             
    MOVE.W  WOOD,D1         ; DISPLAY WOOD
    MOVE.B  #3,D0           
    TRAP    #15             
    LEA     STONE_MSG,A1    
    MOVE.B  #14,D0          
    TRAP    #15             
    MOVE.W  STONE,D1        ; DISPLAY STONE
    MOVE.B  #3,D0           
    TRAP    #15             
    LEA     METAL_MSG,A1    
    MOVE.B  #14,D0          
    TRAP    #15             
    MOVE.W  METAL,D1        ; DISPLAY METAL
    MOVE.B  #3,D0           
    TRAP    #15             
    LEA     HOUSES_MSG,A1   
    MOVE.B  #14,D0          
    TRAP    #15             
    MOVE.W  HOUSES,D1       ; DISPLAY HOUSES
    MOVE.B  #3,D0           
    TRAP    #15             
    LEA     BUCKS_MSG,A1   
    MOVE.B  #14,D0          
    TRAP    #15             
    MOVE.W  BUCKS,D1       ; DISPLAY PROFIT
    MOVE.B  #3,D0           
    TRAP    #15             
    BSR     DECORATE        
    RTS                                     

*-------------------------------------------------------
* DISPLAY OBJECTIVE SUBROUTINE
*-------------------------------------------------------
DISPLAY_OBJECTIVE:
    BSR     ENDL            ; NEW LINE
    LEA     OBJECTIVE_MSG,A1 ; LOAD OBJECTIVE MESSAGE ADDRESS
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15

    ; WAIT FOR PLAYER TO PRESS ANY KEY
    LEA     CONTINUE_MSG,A1 ; LOAD "PRESS ANYKEY TO CONTINUE" MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15

    MOVE.B  #4,D0           ; READ PLAYER INPUT
    TRAP    #15             ; WAIT FOR KEY PRESS
    RTS
    
*-------------------------------------------------------
*-----------------------BEING ATTACKED------------------
* THIS COULD BE USED FOR COLLISION DETECTION
*-------------------------------------------------------
COLLISION:                  
    MOVE.B  #DANGER_LOC,D1  ;MOVE LITERAL DANGER_LOC TO D1
    CMP     #100,D1         ;  IS( X == 100)?
    BNE     COLLISION_MISS  ;  IF NOT, BRANCH TO COLLISION_MISS
    BSR     COLLISION_HIT   ;  ELSE, BRANCH TO COLLISION_HIT
    RTS                     ;RETURN FROM COLLISION: SUBROUTINE  

*-------------------------------------------------------
* COLLISION_HIT SUBROUTINE
*-------------------------------------------------------
COLLISION_HIT:
    LEA     HIT_MSG,A1       ; DISPLAY HIT MESSAGE
    MOVE.B  #14,D0
    TRAP    #15
    RTS

*-------------------------------------------------------
* COLLISION_MISS SUBROUTINE
*-------------------------------------------------------
COLLISION_MISS:
    LEA     MISS_MSG,A1      ; DISPLAY MISS MESSAGE
    MOVE.B  #14,D0
    TRAP    #15
    RTS
    
*-------------------------------------------------------
* GATHER_RESOURCES SUBROUTINE
* ADDS RESOURCES TO THE PLAYER'S INVENTORY
*-------------------------------------------------------
GATHER_RESOURCES:
    BSR     ENDL            ; NEW LINE
    LEA     GATHER_RESOURCES_MSG,A1 ; LOAD GATHER RESOURCES MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15

    ; ADD RESOURCES
    ADD.W   #10,WOOD        ; ADD 10 WOOD
    ADD.W   #5,STONE        ; ADD 5 STONE
    ADD.W   #3,METAL        ; ADD 3 METAL


    RTS                     ; RETURN FROM GATHER_RESOURCES
 
NOT_ENOUGH_WOOD:
    LEA     NOT_ENOUGH_WOOD_MSG,A1 ; LOAD NOT ENOUGH WOOD MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    RTS

NOT_ENOUGH_STONE:
    LEA     NOT_ENOUGH_STONE_MSG,A1 ; LOAD NOT ENOUGH STONE MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    RTS

NOT_ENOUGH_METAL:
    LEA     NOT_ENOUGH_METAL_MSG,A1 ; LOAD NOT ENOUGH METAL MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    RTS
    
*-------------------------------------------------------
* SELL_HOUSE SUBROUTINE
* SELLS A HOUSE FOR PROFIT AND BUCKS
*-------------------------------------------------------
SELL_HOUSE:
    BSR     ENDL            ; NEW LINE

    ; CHECK IF PLAYER HAS HOUSES TO SELL
    CMP.W   #1,HOUSES       ; REQUIRE AT LEAST 1 HOUSE
    BLT     NO_HOUSES_TO_SELL

    ; SELL HOUSE
    SUB.W   #1,HOUSES       ; DEDUCT 1 HOUSE
    ADD.W   #100,BUCKS      ; ADD $100 TO BUCKS
    SUB.W   #50,PROFIT      ; SUBTRACT $50 FROM PROFIT (COST OF BUILDING THE HOUSE)

    ; DISPLAY SUCCESS MESSAGE
    LEA     HOUSE_SOLD_MSG,A1 ; LOAD HOUSE SOLD MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15

    ; DISPLAY UPDATED PROFIT
    LEA     PROFIT_MSG,A1   ; LOAD PROFIT MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    MOVE.W  PROFIT,D1       ; LOAD PROFIT VALUE
    MOVE.B  #3,D0           ; DISPLAY VALUE
    TRAP    #15
    BSR     ENDL            ; NEW LINE

    RTS                     ; RETURN FROM SELL_HOUSE

NO_HOUSES_TO_SELL:
    LEA     NO_HOUSES_MSG,A1 ; LOAD NO HOUSES MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    RTS
    
*-------------------------------------------------------
* VIEW_STATS SUBROUTINE
* DISPLAYS THE PLAYER'S INVENTORY AND STATS
*-------------------------------------------------------
VIEW_STATS:
    BSR     ENDL            ; NEW LINE
    BSR     DECORATE        ; DECORATE THE SCREEN
    LEA     STATS_HEADER,A1 ; LOAD STATS HEADER MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15

    ; DISPLAY WOOD
    LEA     WOOD_MSG,A1     ; LOAD WOOD MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    MOVE.W  WOOD,D1         ; LOAD WOOD VALUE
    MOVE.B  #3,D0           ; DISPLAY VALUE
    TRAP    #15
    BSR     ENDL            ; NEW LINE

    ; DISPLAY STONE
    LEA     STONE_MSG,A1    ; LOAD STONE MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    MOVE.W  STONE,D1        ; LOAD STONE VALUE
    MOVE.B  #3,D0           ; DISPLAY VALUE
    TRAP    #15
    BSR     ENDL            ; NEW LINE

    ; DISPLAY METAL
    LEA     METAL_MSG,A1    ; LOAD METAL MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    MOVE.W  METAL,D1        ; LOAD METAL VALUE
    MOVE.B  #3,D0           ; DISPLAY VALUE
    TRAP    #15
    BSR     ENDL            ; NEW LINE

    ; DISPLAY HOUSES
    LEA     HOUSES_MSG,A1   ; LOAD HOUSES MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    MOVE.W  HOUSES,D1       ; LOAD HOUSES VALUE
    MOVE.B  #3,D0           ; DISPLAY VALUE
    TRAP    #15
    BSR     ENDL            ; NEW LINE

    ; DISPLAY BUCKS
    LEA     BUCKS_MSG,A1    ; LOAD BUCKS MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    MOVE.W  BUCKS,D1        ; LOAD BUCKS VALUE
    MOVE.B  #3,D0           ; DISPLAY VALUE
    TRAP    #15
    BSR     ENDL            ; NEW LINE

    ; DISPLAY PROFIT
    LEA     PROFIT_MSG,A1   ; LOAD PROFIT MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    MOVE.W  PROFIT,D1       ; LOAD PROFIT VALUE
    MOVE.B  #3,D0           ; DISPLAY VALUE
    TRAP    #15
    BSR     ENDL            ; NEW LINE

    BSR     DECORATE        ; DECORATE THE SCREEN
    RTS                     ; RETURN FROM VIEW_STATS

*-------------------------------------------------------
*--------------------------LOOP-------------------------
*-------------------------------------------------------
LOOP:
    MOVE.B  #5, D3          ;LOOP COUNTER D3=5
NEXT:
    LEA     LOOP_MSG,A1     ;ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO          
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    SUB     #1,D3           ;DECREMENT LOOP COUNTER
    BNE     NEXT            ;REPEAT UNTIL D0=0

*-------------------------------------------------------
*------------------SCREEN DECORATION--------------------
*-------------------------------------------------------
DECORATE:
    MOVE.B  #60, D3         ;LOOP COUNTER D3=60
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
OUT:
    LEA     LOOP_MSG,A1     ;ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    SUB     #1,D3           ;DECREMENT LOOP COUNTER
    BNE     OUT             ;REPEAT UNTIL D0=0
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    RTS                     ;RETURN FROM DECORATE: SUBROUTINE
    
CLEAR_SCREEN: 
    MOVE.B  #11,D0          ;CLEAR SCREEN
    MOVE.W  #$FF00,D1       ;SET COLOUR
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    RTS                     ;RETURN FROM CLEAR_SCREEN: SUBROUTINE                

*-------------------------------------------------------
*------------------------REPLAY-------------------------
*-------------------------------------------------------
REPLAY:
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    LEA     REPLAY_MSG,A1   ;ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    
    MOVE.B  #4,D0           ;MOVE LITERAL 4 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0

    CMP     #EXIT,D1        ;COMPARE D1 TO EXIT
    BEQ     END             ;IF EQUAL, BRANCH TO END
    BSR     GAMELOOP        ;BRANCH TO GAMELOOP SUBROUTINE
    
*-------------------------------------------------------
*------------------------CONTINUE-------------------------
*-------------------------------------------------------
CONTINUE:
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    LEA     CONTINUE_MSG,A1 ;ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    
    MOVE.B  #4,D0           ;MOVE LITERAL 4 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    RTS                     ;RETURN FROM SUBROUTINE 

PRESS_CONTINUE:
    BSR     ENDL            ; NEW LINE
    LEA     PRESS_CONTINUE_MSG,A1 ; LOAD "PRESS ANY KEY TO CONTINUE" MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING (TRAP #15, FUNCTION 14)
    TRAP    #15

    ; WAIT FOR PLAYER INPUT
    MOVE.B  #4,D0           ; READ PLAYER INPUT
    TRAP    #15             ; WAIT FOR KEY PRESS

    ; RETURN TO MAIN MENU
    BRA     GAMEPLAY_MENU   ; BRANCH BACK TO MAIN MENU

ENDL:
    MOVEM.L D0/A1,-(A7)     ;SAVE D0 AND A1
    MOVE    #14,D0          ;MOVE LITERAL 14 TO DO
    LEA     CRLF,A1         ;ASSIGN CRLF TO ADDRESS REGISTER A1
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    MOVEM.L (A7)+,D0/A1     ;RESTORE D0 AND A1
    RTS                     ;RETURN FROM ENDL: SUBROUTINE

*-------------------------------------------------------
*-------------------DATA DECLARATIONS--------------------
*-------------------------------------------------------

CRLF:           DC.B    $0D,$0A,0
WELCOME_MSG:    DC.B    '************************************************************',$0D,$0A
                DC.B    'WELCOME TO THE ULTIMATE HOUSE BUILD',$0D,$0A
                DC.B    '************************************************************',$0D,0
                DC.B    $0D,$0A,0                


OBJECTIVE_MSG:  
    DC.B    '************************************************************',$0D,$0A
    DC.B    'OBJECTIVE:',$0D,$0A
    DC.B    'BUILD HOUSES BY GATHERING RESOURCES LIKE WOOD, STONE, AND METAL.',$0D,$0A
    DC.B    'MANAGE YOUR RESOURCES WISELY TO CONSTRUCT HOUSES AND SELL THEM',$0D,$0A
    DC.B    'FOR A PROFIT. BECOME THE BEST HOUSE BUILDER IN THE LAND!',$0D,$0A
    DC.B    '************************************************************',$0D,$0A,0
                
GAMEPLAY_MSG:   
    DC.B    'WELCOME TO HOUSE BUILDER! LETS CONSTRUCT SOME HOUSES!',$0D,$0A,0
UPDATE_MSG:     
    DC.B    'UPDATING CONSTRUCTION PROGRESS...',$0D,$0A,0

DRAW_MSG:       
    DC.B    'REDRAWING CONSTRUCTION SITE...',$0D,0

HIT_MSG:        
    DC.B    'OH NO! A STORM DAMAGED YOUR HOUSE!',0

MISS_MSG:       
    DC.B    'SAFE! THE WEATHER IS CLEAR FOR CONSTRUCTION.',0
LOOP_MSG:       DC.B    '.',0
REPLAY_MSG:     DC.B    'ENTER 0 TO QUIT, ANY OTHER NUMBER TO REPLAY: ',0
CONTINUE_MSG:   DC.B    'PRESS ANY KEY TO CONTINUE...', $0D, $0A, 0
PRESS_CONTINUE_MSG:   DC.B    'PRESS ANYKEY TO CONTINUE: ',0
HUD_MSG:        
    DC.B    'RESOURCES: WOOD=',0
WOOD_MSG:       
    DC.B    ' STONE=',0
STONE_MSG:      
    DC.B    ' STONE=',0
METAL_MSG:      
    DC.B    ' METAL=',0    
HOUSES_MSG:     
    DC.B    ' HOUSES BUILT=',0
PROFIT_MSG:     
    DC.B    ' PROFIT=$',0
BUCKS_MSG:     
    DC.B    ' BUCKS=$',0
WOOD:       DS.W    1   ; AMOUNT OF WOOD
STONE:      DS.W    1   ; AMOUNT OF STONE
METAL:      DS.W    1   ; AMOUNT OF METAL
*-------------------------------------------------------
* HOUSE VARIABLES
*-------------------------------------------------------
DETACHED_HOUSES:   DS.W    1   ; NUMBER OF DETACHED HOUSES BUILT
APARTMENT_HOUSES:  DS.W    1   ; NUMBER OF APARTMENTS BUILT
BUILDING_HOUSES:   DS.W    1   ; NUMBER OF BUILDINGS BUILT
MANSION_HOUSES:    DS.W    1   ; NUMBER OF MANSIONS BUILT
HOUSES:      DS.W    1   ; TOTAL HOUSES BUILT (SUM OF ALL TYPES)

BUCKS:      DS.W    100   ; PLAYER'S MONEY (BUCKS)
PROFIT:     DS.W    1   ; TOTAL PROFIT EARNED

SCORE:          DS.W    1   ;RESERVE SPACE FOR SCORE
STATS_HEADER:   DC.B    'STATS:',$0D,$0A,0
GAMEPLAY_MENU_MSG:
    DC.B    'GAMEPLAY MENU:',$0D,$0A
    DC.B    '1. GATHER RESOURCES',$0D,$0A
    DC.B    '2. BUILD HOUSE',$0D,$0A
    DC.B    '3. SELL HOUSE',$0D,$0A
    DC.B    '4. VIEW STATS',$0D,$0A
    DC.B    '5. QUIT GAME',$0D,$0A,0
    
HOUSE_BUILT_MSG:        
    DC.B    'HOUSE BUILT SUCCESSFULLY!',0
NOT_ENOUGH_WOOD_MSG:    
    DC.B    'NOT ENOUGH WOOD TO BUILD A HOUSE!',0
NOT_ENOUGH_STONE_MSG:   
    DC.B    'NOT ENOUGH STONE TO BUILD A HOUSE!',0
NOT_ENOUGH_METAL_MSG:   
    DC.B    'NOT ENOUGH METAL TO BUILD A HOUSE!',0
HOUSE_SOLD_MSG:         
    DC.B    'HOUSE SOLD FOR $100 PROFIT AND $50 BUCKS!', $0D, $0A, 0
NO_HOUSES_MSG:          
    DC.B    'NO HOUSES TO SELL!',0

BUILD_HOUSE_MENU_MSG:
    DC.B    'BUILD HOUSE MENU:', $0D, $0A
    DC.B    '1. DETACHED HOUSE (10 WOOD, 5 STONE, 3 METAL)', $0D, $0A
    DC.B    '2. APARTMENT (20 WOOD, 10 STONE, 5 METAL)', $0D, $0A
    DC.B    '3. BUILDING (50 WOOD, 30 STONE, 10 METAL)', $0D, $0A
    DC.B    '4. MANSION (100 WOOD, 50 STONE, 20 METAL)', $0D, $0A
    DC.B    '5. BACK TO MAIN MENU', $0D, $0A, 0

DETACHED_BUILT_MSG:
    DC.B    'DETACHED HOUSE BUILT SUCCESSFULLY!', $0D, $0A, 0

APARTMENT_BUILT_MSG:
    DC.B    'APARTMENT BUILT SUCCESSFULLY!', $0D, $0A, 0

BUILDING_BUILT_MSG:
    DC.B    'BUILDING BUILT SUCCESSFULLY!', $0D, $0A, 0

MANSION_BUILT_MSG:
    DC.B    'MANSION BUILT SUCCESSFULLY!', $0D, $0A, 0

INVALID_INPUT_MSG:
    DC.B    'INVALID INPUT! PLEASE CHOOSE 1, 2, 3, 4, OR 5.',$0D,$0A,0

OPTION_1_MSG:
    DC.B    'STARTING QUEST...',$0D,$0A,0

OPTION_5_MSG:
    DC.B    'QUITTING GAME... GOODBYE!',$0D,$0A,0

GATHER_RESOURCES_MSG:
    DC.B    'GATHERING RESOURCES... WOOD, STONE, AND METAL ADDED TO YOUR INVENTORY.',$0D,$0A,0
    
DEV_MODE_MSG:
    DC.B    'DEV MODE ACTIVATED! ENTER NEW VALUES:', $0D, $0A, 0

ENTER_WOOD_MSG:
    DC.B    'ENTER NEW WOOD VALUE: ', 0

ENTER_STONE_MSG:
    DC.B    'ENTER NEW STONE VALUE: ', 0

ENTER_METAL_MSG:
    DC.B    'ENTER NEW METAL VALUE: ', 0

ENTER_HOUSES_MSG:
    DC.B    'ENTER NEW HOUSES VALUE: ', 0

ENTER_BUCKS_MSG:
    DC.B    'ENTER NEW BUCKS VALUE: ', 0

ENTER_PROFIT_MSG:
    DC.B    'ENTER NEW PROFIT VALUE: ', 0

VALUES_UPDATED_MSG:
    DC.B    'VALUES UPDATED SUCCESSFULLY!', $0D, $0A, 0

    
HOUSE_ART:
    DC.B    '    _________H ,%%&%,', $0D, $0A
    DC.B    '   /\     _   \%&&%%&%', $0D, $0A
    DC.B    '  /  \___/^\___\%&%%&&', $0D, $0A
    DC.B    '  |  | []   [] |%\Y&%''', $0D, $0A
    DC.B    '  |  |   .-.   | ||  ', $0D, $0A
    DC.B    '~~@._|@@_|||_@@|~||~~~~~~~~~~~~~', $0D, $0A
    DC.B    '     `""") )"""`', $0D, $0A, 0

MANSION_ART:
    DC.B    '         (', $0D, $0A
    DC.B    '           )', $0D, $0A
    DC.B    '         ( _   _._', $0D, $0A
    DC.B    '          |_|-''_~_`-.', $0D, $0A
    DC.B    '       _.-''-_~_-~_-~-_`-._', $0D, $0A
    DC.B    '   _.-''_~-_~-_-~-_~_~-_~-_`-._', $0D, $0A
    DC.B    '  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~', $0D, $0A
    DC.B    '    |  []  []   []   []  [] |', $0D, $0A
    DC.B    '    |           __    ___   |', $0D, $0A
    DC.B    '  ._|  []  []  | .|  [___]  |_._._._._._._._._._._._._._._._._.', $0D, $0A
    DC.B    '  |=|________()|__|()_______|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|', $0D, $0A
    DC.B    '^^^^^^^^^^^^^^^ === ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^', $0D, $0A
    DC.B    '    _______      ===', $0D, $0A
    DC.B    '   <_4sale_>       ===', $0D, $0A
    DC.B    '      ^|^             ===', $0D, $0A
    DC.B    '       |                 ===', $0D, $0A, 0


BUILDING_ART:
    DC.B    '__                   ___                       ( )', $0D, $0A
    DC.B    ' |""|  ___    _   __  |"""|  __                   `', $0D, $0A
    DC.B    ' |""| |"""|  |"| |""| |"""| |""|        _._ _', $0D, $0A
    DC.B    ' |""| |"""|  |"| |""| |"""| |""|       (__((_(', $0D, $0A
    DC.B    ' |""| |"""|  |"| |""| |"""| |""|      \''-:--:-.', $0D, $0A
    DC.B    ' "''''"''"''''""''''''"""''""''""~~~~~~''-----''~~~~  ldb', $0D, $0A, 0

APARTMENT_ART:
    DC.B    '   _______________', $0D, $0A
    DC.B    '  |  []  []  []  |', $0D, $0A
    DC.B    '  |  []  []  []  |', $0D, $0A
    DC.B    '  |  []  []  []  |', $0D, $0A
    DC.B    '  |  []  []  []  |', $0D, $0A
    DC.B    '  |  []  []  []  |', $0D, $0A
    DC.B    '  |  []  []  []  |', $0D, $0A
    DC.B    '  |______________|', $0D, $0A
    DC.B    '  |              |', $0D, $0A
    DC.B    '  |    APARTMENT |', $0D, $0A
    DC.B    '  |______________|', $0D, $0A
    DC.B    '  |              |', $0D, $0A
    DC.B    '  |    FOR RENT  |', $0D, $0A
    DC.B    '  |______________|', $0D, $0A, 0

    END START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
