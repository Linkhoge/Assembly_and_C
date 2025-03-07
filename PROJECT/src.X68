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

*START OF GAME
START:
    MOVE.B  #100,$4000      ; PUT BRAVERY POINTS IN MEMORY LOCATION $4000
    LEA     $4000,A3        ; ASSIGN ADDRESS A3 TO THAT MEMORY LOCATION

    ; INITIALIZE VARIABLES
    MOVE.W  #0,HOUSES       ; INITIALIZE HOUSES BUILT TO 0
    MOVE.W  #0,DETACHED_HOUSES       ; ^
    MOVE.W  #0,APARTMENT_HOUSES      ; ^
    MOVE.W  #0,BUILDING_HOUSES       ; ^
    MOVE.W  #0,MANSION_HOUSES        ; ^
    MOVE.W  #100,BUCKS      ; INITIALIZE BUCKS TO 100
    MOVE.W  #0,PROFIT       ; INITIALIZE PROFIT TO 0
    MOVE.W  #0,WOOD         ; INITIALIZE WOOD TO 0
    MOVE.W  #0,STONE        ; INITIALIZE STONE TO 0
    MOVE.W  #0,METAL        ; INITIALIZE METAL TO 0
    MOVE.W  #100,ENERGY     ; INITIALIZE ENERGY TO 100
    MOVE.W  #1,DAY          ; INITIALIZE DAY TO 1

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
    ; CHECK IF BUCKS == 0 AT THE START OF THE LOOP
    MOVE.W  BUCKS,D1        ; LOAD BUCKS INTO D1
    CMP.W   #0,D1           ; ARE BUCKS EQUAL TO 0?
    BEQ     LOSE_GAME       ; IF BUCKS == 0, BRANCH TO LOSE_GAME

    BSR     INPUT           ; BRANCH TO INPUT SUBROUTINE
    BSR     UPDATE          ; BRANCH TO UPDATE GAME SUBROUTINE 
    ;BSR     CLEAR_SCREEN    ; CLEARS THE SCREEN 
    BSR     DRAW            ; BRANCH TO DRAW GAME SUBROUTINE           
    ;BSR     CLEAR_SCREEN    ; CLEARS THE SCREEN 
    BSR     GAMEPLAY        ; BRANCH TO GAMEPLAY SUBROUTINE
    ;BSR     CLEAR_SCREEN    ; CLEARS THE SCREEN        
    ;BSR     HUD             ; BRANCH TO HUD SUBROUTINE
    ;BSR     CLEAR_SCREEN    ; CLEARS THE SCREEN
    
    BSR     REPLAY          ; BRANCH TO REPLAY SUBROUTINE 
    BSR     CLEAR_SCREEN    ; CLEARS THE SCREEN
    RTS                     ; RETURN FROM GAMELOOP: SUBROUTINE     

*-----------------------------------------------------------
*----------------UPDATE QUEST PROGRESS------------------
*  COMPLETE QUEST
*-----------------------------------------------------------
UPDATE:
    MOVEM.L D0-D1/A1,-(A7)  ; SAVE REGISTERS TO STACK
    BSR     ENDL            ; BRANCH TO ENDL SUBROUTINE
    BSR     DECORATE        ; BRANCH TO DECORATE SUBROUTINE   
    LEA     UPDATE_MSG,A1   ; ASSIGN MESSAGE TO ADDRESS REGISTER A1 
    MOVE.B  #14,D0          ; MOVE LITERAL 14 TO D0
    TRAP    #15             ; TRAP AND INTERPRET VALUE IN D0

    ; CHECK ENERGY LEVEL
    CMP.W   #20,ENERGY      ; IS ENERGY BELOW 20?
    BGT     SKIP_ENERGY_CHECK ; IF NOT, SKIP THE ENERGY CHECK
    LEA     LOW_ENERGY_MSG,A1 ; DISPLAY LOW ENERGY MESSAGE
    MOVE.B  #14,D0
    TRAP    #15
    BSR     PRESS_CONTINUE  ; WAIT FOR CONTINUE, THEN SKIP TO NEXT DAY
    BSR     SKIP_TO_NEXT_DAY ; ADVANCE TO NEXT DAY AND REPLENISH ENERGY

SKIP_ENERGY_CHECK:
    ; CHECK NEW WIN CONDITION (HOUSES >= 5)
    MOVE.W  HOUSES,D1       ; LOAD TOTAL HOUSES INTO D1
    CMP.W   #5,D1           ; DID PLAYER BUILD 5 HOUSES?
    BGE     WIN_GAME_HOUSES ; IF HOUSES >= 5, WIN

    ; CHECK WIN CONDITION (BUCKS >= TARGET_BUCKS)
    MOVE.W  BUCKS,D1        ; LOAD BUCKS INTO D1
    CMP.W   #TARGET_BUCKS,D1 ; DID PLAYER REACH TARGET BUCKS?
    BLT     CHECK_LOSE      ; IF BUCKS < TARGET_BUCKS, CHECK LOSE
    BSR     WIN_GAME        ; IF BUCKS >= TARGET_BUCKS, WIN

CHECK_LOSE:
    ; CHECK LOSE CONDITION (BUCKS <= 0)
    MOVE.W  BUCKS,D1         ; LOAD BUCKS INTO D1 AGAIN
    CMP.W   #0,D1            ; ARE BUCKS 0 OR LESS?
    BLE     LOSE_GAME       ; IF BUCKS <= 0, LOSE (CHANGED FROM BGT TO BLE)

UPDATE_END:
    MOVEM.L (A7)+,D0-D1/A1  ; RESTORE REGISTERS
    BSR     DECORATE        ; BRANCH TO DECORATE SUBROUTINE
    RTS  

*-----------------------------------------------------------
* WIN/LOSE SUBROUTINE
* HANDLES THE WIN AND LOSS
*-----------------------------------------------------------
WIN_GAME:
    BSR     ENDL
    BSR     DECORATE
    LEA     WIN_MSG,A1          ; DISPLAY "CONGRATULATIONS! You reached "
    MOVE.B  #14,D0
    TRAP    #15

    MOVE.W  #TARGET_BUCKS,D1    ; DISPLAY TARGET BUCKS VALUE
    MOVE.B  #3,D0
    TRAP    #15

    LEA     WIN_BUCKS_MSG,A1    ; DISPLAY " bucks in "
    MOVE.B  #14,D0
    TRAP    #15

    MOVE.W  DAY,D1              ; DISPLAY DAYS (SCORE)
    MOVE.B  #3,D0
    TRAP    #15

    LEA     WIN_DAYS_MSG,A1     ; DISPLAY " days! The fewer days, the better your score!"
    MOVE.B  #14,D0
    TRAP    #15

    BSR     DECORATE
    SIMHALT                     ; END THE GAME

* NEW WIN CONDITION FOR 5 HOUSES
WIN_GAME_HOUSES:
    BSR     ENDL
    BSR     DECORATE
    LEA     WIN_HOUSES_MSG,A1   ; DISPLAY "CONGRATULATIONS! You built 5 houses in "
    MOVE.B  #14,D0
    TRAP    #15

    MOVE.W  DAY,D1              ; DISPLAY DAYS (SCORE)
    MOVE.B  #3,D0
    TRAP    #15

    LEA     WIN_DAYS_MSG,A1     ; DISPLAY " days! The fewer days, the better your score!"
    MOVE.B  #14,D0
    TRAP    #15

    BSR     DECORATE
    SIMHALT                     ; END THE GAME

LOSE_GAME:
    BSR     ENDL
    BSR     DECORATE
    LEA     LOSE_MSG,A1         ; DISPLAY "GAME OVER! You ran out of bucks after "
    MOVE.B  #14,D0
    TRAP    #15

    MOVE.W  DAY,D1              ; DISPLAY DAYS (SCORE)
    MOVE.B  #3,D0
    TRAP    #15

    LEA     LOSE_DAYS_MSG,A1    ; DISPLAY " days."
    MOVE.B  #14,D0
    TRAP    #15

    BSR     DECORATE
    SIMHALT                     ; END THE GAME

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
*-----------------------------------------------------------
* GAMEPLAY SUBROUTINE
* HANDLES THE MAIN GAME LOOP AND MENU OPTIONS
*-----------------------------------------------------------
GAMEPLAY:
    BSR     ENDL            ; NEW LINE
    BSR     DECORATE        ; DECORATE THE SCREEN
    LEA     GAMEPLAY_MSG,A1 ; LOAD GAMEPLAY MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15

GAMEPLAY_MENU:
    BSR     HUD
    BSR     DECORATE        ; DECORATE THE SCREEN
    LEA     GAMEPLAY_MENU_MSG,A1 ; LOAD GAMEPLAY MENU MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15

    ; READ PLAYER INPUT
    MOVE.B  #4,D0           ; READ PLAYER INPUT
    TRAP    #15             ; WAIT FOR KEY PRESS

    ; CHECK FOR DEV MODE (666)
    CMP.W   #666,D1         ; CHECK IF INPUT IS 666
    BEQ     DEV_MODE        ; IF YES, BRANCH TO DEV MODE

    ; VALIDATE NORMAL INPUT (1-6)
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
    CMP.B   #6,D1           ; CHECK IF PLAYER CHOSE 6 (SKIP TO NEXT DAY)
    BEQ     OPTION_6        ; BRANCH TO OPTION 6 HANDLER

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
    BSR     SELL_HOUSE_MENU      ; BRANCH TO SELL_HOUSE SUBROUTINE
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
* OPTION 5: SKIP DAY 
*-------------------------------------------------------
OPTION_6:
    BSR     SKIP_TO_NEXT_DAY ; BRANCH TO SKIP_TO_NEXT_DAY SUBROUTINE
    BRA     GAMEPLAY_MENU    ; RETURN TO GAMEPLAY MENU

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
* SELL_HOUSE_MENU SUBROUTINE
* DISPLAYS A SUBMENU FOR SELLING DIFFERENT TYPES OF HOUSES
*-------------------------------------------------------
SELL_HOUSE_MENU:
    BSR     ENDL            ; NEW LINE
    BSR     DECORATE        ; DECORATE THE SCREEN
    LEA     SELL_HOUSE_MENU_MSG,A1 ; LOAD SELL HOUSE MENU MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15

    ; READ PLAYER INPUT
    MOVE.B  #4,D0           ; READ PLAYER INPUT
    TRAP    #15             ; WAIT FOR KEY PRESS

    ; VALIDATE INPUT
    CMP.B   #1,D1           ; CHECK IF PLAYER CHOSE 1 (DETACHED)
    BEQ     SELL_DETACHED   ; BRANCH TO SELL_DETACHED HANDLER
    CMP.B   #2,D1           ; CHECK IF PLAYER CHOSE 2 (APARTMENT)
    BEQ     SELL_APARTMENT  ; BRANCH TO SELL_APARTMENT HANDLER
    CMP.B   #3,D1           ; CHECK IF PLAYER CHOSE 3 (BUILDING)
    BEQ     SELL_BUILDING   ; BRANCH TO SELL_BUILDING HANDLER
    CMP.B   #4,D1           ; CHECK IF PLAYER CHOSE 4 (MANSION)
    BEQ     SELL_MANSION    ; BRANCH TO SELL_MANSION HANDLER
    CMP.B   #5,D1           ; CHECK IF PLAYER CHOSE 5 (BACK TO MAIN MENU)
    BEQ     BACK_TO_MAIN    ; BRANCH BACK TO MAIN MENU

    ; INVALID INPUT, LOOP BACK
    LEA     INVALID_INPUT_MSG,A1 ; LOAD INVALID INPUT MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    BRA     SELL_HOUSE_MENU ; LOOP BACK TO DISPLAY MENU AGAIN

*-------------------------------------------------------
* SELL_DETACHED SUBROUTINE
* SELLS A DETACHED HOUSE AT HARDCODED PRICE
*-------------------------------------------------------
SELL_DETACHED:
    CMP.W   #1,DETACHED_HOUSES ; CHECK IF PLAYER HAS AT LEAST 1 DETACHED HOUSE
    BLT     NO_HOUSES_TO_SELL  ; IF NOT, DISPLAY ERROR

    BSR     ENDL
    LEA     SCANNING_MSG,A1    ; DISPLAY "Scanning for offers..."
    MOVE.B  #14,D0
    TRAP    #15

    ; AUTOMATIC SALE AT HARDCODED PRICE
    SUB.W   #1,DETACHED_HOUSES ; DECREMENT DETACHED HOUSE COUNT
    SUB.W   #1,HOUSES          ; DECREMENT TOTAL HOUSES (OPTIONAL)
    MOVE.W  #DETACHED_SELL_PRICE,D2 ; HARDCODED PRICE (45)
    ADD.W   D2,BUCKS           ; ADD SELL PRICE TO BUCKS
    SUB.W   #DETACHED_BUCKS_COST,D2 ; CALCULATE PROFIT (45 - 30 = 15)
    ADD.W   D2,PROFIT          ; ADD PROFIT TO TOTAL
    LEA     DETACHED_SOLD_MSG,A1 ; LOAD SUCCESS MESSAGE
    MOVE.B  #14,D0
    TRAP    #15
    BSR     PRESS_CONTINUE     ; WAIT FOR KEY PRESS AND RETURN TO MENU
    RTS

*-------------------------------------------------------
* SELL_APARTMENT SUBROUTINE
* SELLS AN APARTMENT AT HARDCODED PRICE
*-------------------------------------------------------
SELL_APARTMENT:
    CMP.W   #1,APARTMENT_HOUSES ; CHECK IF PLAYER HAS AT LEAST 1 APARTMENT
    BLT     NO_HOUSES_TO_SELL   ; IF NOT, DISPLAY ERROR

    BSR     ENDL
    LEA     SCANNING_MSG,A1    ; DISPLAY "Scanning for offers..."
    MOVE.B  #14,D0
    TRAP    #15

    ; AUTOMATIC SALE AT HARDCODED PRICE
    SUB.W   #1,APARTMENT_HOUSES ; DECREMENT APARTMENT COUNT
    SUB.W   #1,HOUSES           ; DECREMENT TOTAL HOUSES (OPTIONAL)
    MOVE.W  #APARTMENT_SELL_PRICE,D2 ; HARDCODED PRICE (75)
    ADD.W   D2,BUCKS            ; ADD SELL PRICE TO BUCKS
    SUB.W   #APARTMENT_BUCKS_COST,D2 ; CALCULATE PROFIT (75 - 50 = 25)
    ADD.W   D2,PROFIT           ; ADD PROFIT TO TOTAL
    LEA     APARTMENT_SOLD_MSG,A1 ; LOAD SUCCESS MESSAGE
    MOVE.B  #14,D0
    TRAP    #15
    BSR     PRESS_CONTINUE      ; WAIT FOR KEY PRESS AND RETURN TO MENU
    RTS

*-------------------------------------------------------
* SELL_BUILDING SUBROUTINE
* SELLS A BUILDING AT HARDCODED PRICE
*-------------------------------------------------------
SELL_BUILDING:
    CMP.W   #1,BUILDING_HOUSES ; CHECK IF PLAYER HAS AT LEAST 1 BUILDING
    BLT     NO_HOUSES_TO_SELL  ; IF NOT, DISPLAY ERROR

    BSR     ENDL
    LEA     SCANNING_MSG,A1    ; DISPLAY "Scanning for offers..."
    MOVE.B  #14,D0
    TRAP    #15

    ; AUTOMATIC SALE AT HARDCODED PRICE
    SUB.W   #1,BUILDING_HOUSES ; DECREMENT BUILDING COUNT
    SUB.W   #1,HOUSES          ; DECREMENT TOTAL HOUSES (OPTIONAL)
    MOVE.W  #BUILDING_SELL_PRICE,D2 ; HARDCODED PRICE (150)
    ADD.W   D2,BUCKS           ; ADD SELL PRICE TO BUCKS
    SUB.W   #BUILDING_BUCKS_COST,D2 ; CALCULATE PROFIT (150 - 100 = 50)
    ADD.W   D2,PROFIT          ; ADD PROFIT TO TOTAL
    LEA     BUILDING_SOLD_MSG,A1 ; LOAD SUCCESS MESSAGE
    MOVE.B  #14,D0
    TRAP    #15
    BSR     PRESS_CONTINUE     ; WAIT FOR KEY PRESS AND RETURN TO MENU
    RTS

*-------------------------------------------------------
* SELL_MANSION SUBROUTINE
* SELLS A MANSION AT HARDCODED PRICE
*-------------------------------------------------------
SELL_MANSION:
    CMP.W   #1,MANSION_HOUSES ; CHECK IF PLAYER HAS AT LEAST 1 MANSION
    BLT     NO_HOUSES_TO_SELL ; IF NOT, DISPLAY ERROR

    BSR     ENDL
    LEA     SCANNING_MSG,A1    ; DISPLAY "Scanning for offers..."
    MOVE.B  #14,D0
    TRAP    #15

    ; AUTOMATIC SALE AT HARDCODED PRICE
    SUB.W   #1,MANSION_HOUSES ; DECREMENT MANSION COUNT
    SUB.W   #1,HOUSES         ; DECREMENT TOTAL HOUSES (OPTIONAL)
    MOVE.W  #MANSION_SELL_PRICE,D2 ; HARDCODED PRICE (300)
    ADD.W   D2,BUCKS          ; ADD SELL PRICE TO BUCKS
    SUB.W   #MANSION_BUCKS_COST,D2 ; CALCULATE PROFIT (300 - 200 = 100)
    ADD.W   D2,PROFIT         ; ADD PROFIT TO TOTAL
    LEA     MANSION_SOLD_MSG,A1 ; LOAD SUCCESS MESSAGE
    MOVE.B  #14,D0
    TRAP    #15
    BSR     PRESS_CONTINUE    ; WAIT FOR KEY PRESS AND RETURN TO MENU
    RTS

*-------------------------------------------------------
* REJECT_OFFER SUBROUTINE
* HANDLES OFFER REJECTION
*-------------------------------------------------------
REJECT_OFFER:
    LEA     OFFER_REJECTED_MSG,A1 ; LOAD REJECTION MESSAGE
    MOVE.B  #14,D0
    TRAP    #15
    BSR     PRESS_CONTINUE        ; WAIT FOR KEY PRESS AND RETURN TO MENU
    RTS

*-------------------------------------------------------
* NO_HOUSES_TO_SELL SUBROUTINE
* DISPLAYS ERROR IF NO HOUSES OF THAT TYPE ARE AVAILABLE
*-------------------------------------------------------
NO_HOUSES_TO_SELL:
    LEA     NO_HOUSES_MSG,A1 ; LOAD NO HOUSES MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    BSR     PRESS_CONTINUE  ; WAIT FOR KEY PRESS AND RETURN TO MENU
    RTS

*-------------------------------------------------------
* BACK_TO_MAIN SUBROUTINE
* RETURNS TO THE MAIN MENU
*-------------------------------------------------------
BACK_TO_MAIN:
    RTS                     ; RETURN TO MAIN MENU

*-------------------------------------------------------
* SKIP_TO_NEXT_DAY SUBROUTINE
* SKIPS TO NEXT DAY AND REPLENTISHES ENERGY
*-------------------------------------------------------
SKIP_TO_NEXT_DAY:
    BSR     ENDL
    ADD.W   #1,DAY          ; INCREMENT DAY
    MOVE.W  #100,ENERGY     ; REPLENISH ENERGY TO 100
    ADD.W   #DAILY_PAYMENT,BUCKS ; ADD DAILY PAYMENT TO BUCKS

    BSR     DECORATE        ; ADD DOTS BEFORE MESSAGES
    LEA     NEW_DAY_MSG,A1  ; DISPLAY ENERGY REPLENISH MESSAGE
    MOVE.B  #14,D0
    TRAP    #15

    LEA     PAYMENT_MSG,A1  ; DISPLAY PAYMENT MESSAGE
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.W  #DAILY_PAYMENT,D1 ; DISPLAY PAYMENT AMOUNT
    MOVE.B  #3,D0
    TRAP    #15
    LEA     PAYMENT_END_MSG,A1 ; FINISH PAYMENT MESSAGE
    MOVE.B  #14,D0
    TRAP    #15
    BSR     DECORATE        ; ADD DOTS AFTER MESSAGES

    LEA     DAY_MSG,A1      ; DISPLAY NEW DAY
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.W  DAY,D1
    MOVE.B  #3,D0
    TRAP    #15
    BSR     ENDL

    RTS

*-------------------------------------------------------
* BUILD_DETACHED SUBROUTINE
* BUILDS A DETACHED HOUSE
*-------------------------------------------------------
BUILD_DETACHED:
    ; CHECK BUCKS FOR DETACHED HOUSE
    CMP.W   #DETACHED_BUCKS_COST,BUCKS ; REQUIRE 30 BUCKS
    BGE     CHECK_WOOD_DETACHED        ; IF ENOUGH BUCKS, PROCEED
    LEA     NOT_ENOUGH_BUCKS_MSG,A1    ; IF NOT, DISPLAY ERROR
    MOVE.B  #14,D0
    TRAP    #15
    RTS

CHECK_WOOD_DETACHED:
    ; CHECK RESOURCES FOR DETACHED HOUSE
    CMP.W   #10,WOOD        ; REQUIRE 10 WOOD
    BLT     NOT_ENOUGH_WOOD
    CMP.W   #5,STONE        ; REQUIRE 5 STONE
    BLT     NOT_ENOUGH_STONE
    CMP.W   #3,METAL        ; REQUIRE 3 METAL
    BLT     NOT_ENOUGH_METAL

    ; DEDUCT BUCKS
    SUB.W   #DETACHED_BUCKS_COST,BUCKS ; DEDUCT 30 BUCKS

    ; DEDUCT RESOURCES
    SUB.W   #10,WOOD        ; DEDUCT 10 WOOD
    SUB.W   #5,STONE        ; DEDUCT 5 STONE
    SUB.W   #3,METAL        ; DEDUCT 3 METAL

    ; INCREMENT HOUSES BUILT
    ADD.W   #1,HOUSES       ; ADD 1 HOUSE
    ADD.W #1, DETACHED_HOUSES ; ADD 1 DETACHED

    ; DISPLAY HOUSE ART
    LEA     HOUSE_ART,A1    ; LOAD HOUSE ART ADDRESS
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15

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
    ; CHECK BUCKS FOR APARTMENT
    CMP.W   #APARTMENT_BUCKS_COST,BUCKS ; REQUIRE 50 BUCKS
    BGE     CHECK_WOOD_APARTMENT        ; IF ENOUGH BUCKS, PROCEED
    LEA     NOT_ENOUGH_BUCKS_MSG,A1     ; IF NOT, DISPLAY ERROR
    MOVE.B  #14,D0
    TRAP    #15
    RTS

CHECK_WOOD_APARTMENT:
    ; CHECK RESOURCES FOR APARTMENT
    CMP.W   #20,WOOD        ; REQUIRE 20 WOOD
    BLT     NOT_ENOUGH_WOOD
    CMP.W   #10,STONE       ; REQUIRE 10 STONE
    BLT     NOT_ENOUGH_STONE
    CMP.W   #5,METAL        ; REQUIRE 5 METAL
    BLT     NOT_ENOUGH_METAL

    ; DEDUCT BUCKS
    SUB.W   #APARTMENT_BUCKS_COST,BUCKS ; DEDUCT 50 BUCKS

    ; DEDUCT RESOURCES
    SUB.W   #20,WOOD        ; DEDUCT 20 WOOD
    SUB.W   #10,STONE       ; DEDUCT 10 STONE
    SUB.W   #5,METAL        ; DEDUCT 5 METAL

    ; INCREMENT HOUSES BUILT
    ADD.W   #1,HOUSES       ; ADD 1 HOUSE
    ADD.W #1, APARTMENT_HOUSES ; ADD 1 APARTMENT

    ; DISPLAY APARTMENT ART
    LEA     APARTMENT_ART,A1 ; LOAD APARTMENT ART ADDRESS
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15

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
    ; CHECK BUCKS FOR BUILDING
    CMP.W   #BUILDING_BUCKS_COST,BUCKS ; REQUIRE 100 BUCKS
    BGE     CHECK_WOOD_BUILDING        ; IF ENOUGH BUCKS, PROCEED
    LEA     NOT_ENOUGH_BUCKS_MSG,A1    ; IF NOT, DISPLAY ERROR
    MOVE.B  #14,D0
    TRAP    #15
    RTS

CHECK_WOOD_BUILDING:
    ; CHECK RESOURCES FOR BUILDING
    CMP.W   #50,WOOD        ; REQUIRE 50 WOOD
    BLT     NOT_ENOUGH_WOOD
    CMP.W   #30,STONE       ; REQUIRE 30 STONE
    BLT     NOT_ENOUGH_STONE
    CMP.W   #10,METAL       ; REQUIRE 10 METAL
    BLT     NOT_ENOUGH_METAL

    ; DEDUCT BUCKS
    SUB.W   #BUILDING_BUCKS_COST,BUCKS ; DEDUCT 100 BUCKS

    ; DEDUCT RESOURCES
    SUB.W   #50,WOOD        ; DEDUCT 50 WOOD
    SUB.W   #30,STONE       ; DEDUCT 30 STONE
    SUB.W   #10,METAL       ; DEDUCT 10 METAL

    ; INCREMENT HOUSES BUILT
    ADD.W   #1,HOUSES       ; ADD 1 HOUSE
    ADD.W #1, BUILDING_HOUSES ; ADD 1 BUILDING

    ; DISPLAY BUILDING ART
    LEA     BUILDING_ART,A1 ; LOAD BUILDING ART ADDRESS
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15

    ; DISPLAY SUCCESS MESSAGE
    LEA     BUILDING_BUILT_MSG,A1 ; LOAD BUILDING BUILT MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    RTS                     ; RETURN FROM BUILD_BUILDING

*-------------------------------------------------------
* BUILD_MANSION SUBROUTINE
* BUILDS A MANSION
*-------------------------------------------------------
BUILD_MANSION:
    ; CHECK BUCKS FOR MANSION
    CMP.W   #MANSION_BUCKS_COST,BUCKS ; REQUIRE 200 BUCKS
    BGE     CHECK_WOOD_MANSION        ; IF ENOUGH BUCKS, PROCEED
    LEA     NOT_ENOUGH_BUCKS_MSG,A1   ; IF NOT, DISPLAY ERROR
    MOVE.B  #14,D0
    TRAP    #15
    RTS

CHECK_WOOD_MANSION:
    ; CHECK RESOURCES FOR MANSION
    CMP.W   #100,WOOD       ; REQUIRE 100 WOOD
    BLT     NOT_ENOUGH_WOOD
    CMP.W   #50,STONE       ; REQUIRE 50 STONE
    BLT     NOT_ENOUGH_STONE
    CMP.W   #20,METAL       ; REQUIRE 20 METAL
    BLT     NOT_ENOUGH_METAL

    ; DEDUCT BUCKS
    SUB.W   #MANSION_BUCKS_COST,BUCKS ; DEDUCT 200 BUCKS

    ; DEDUCT RESOURCES
    SUB.W   #100,WOOD       ; DEDUCT 100 WOOD
    SUB.W   #50,STONE       ; DEDUCT 50 STONE
    SUB.W   #20,METAL       ; DEDUCT 20 METAL

    ; INCREMENT HOUSES BUILT
    ADD.W   #1,HOUSES       ; ADD 1 HOUSE
    ADD.W #1, MANSION_HOUSES ; ADD 1 MANSION

    ; DISPLAY MANSION ART
    LEA     MANSION_ART,A1  ; LOAD MANSION ART ADDRESS
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15

    ; DISPLAY SUCCESS MESSAGE
    LEA     MANSION_BUILT_MSG,A1 ; LOAD MANSION BUILT MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    RTS                     ; RETURN FROM BUILD_MANSION

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
    MOVE.W  BUCKS,D1        ; DISPLAY BUCKS
    MOVE.B  #3,D0           
    TRAP    #15             
    LEA     ENERGY_MSG,A1   ; DISPLAY ENERGY
    MOVE.B  #14,D0          
    TRAP    #15             
    MOVE.W  ENERGY,D1       
    MOVE.B  #3,D0           
    TRAP    #15             
    LEA     DAY_MSG,A1      ; DISPLAY DAY
    MOVE.B  #14,D0          
    TRAP    #15             
    MOVE.W  DAY,D1          
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

    ; DISPLAY GOAL MESSAGE WITH DECORATION
    BSR     DECORATE        ; ADD DOTS BEFORE GOAL MESSAGE
    LEA     GOAL_MSG,A1     ; LOAD GOAL MESSAGE
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.W  #TARGET_BUCKS,D1 ; DISPLAY TARGET BUCKS VALUE
    MOVE.B  #3,D0
    TRAP    #15
    LEA     GOAL_END_MSG,A1  ; FINISH GOAL MESSAGE
    MOVE.B  #14,D0
    TRAP    #15
    BSR     DECORATE        ; ADD DOTS AFTER GOAL MESSAGE

    ; WAIT FOR PLAYER TO PRESS ANY KEY
    LEA     CONTINUE_MSG,A1 ; LOAD "PRESS ANYKEY TO CONTINUE" MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15

    MOVE.B  #4,D0           ; READ PLAYER INPUT
    TRAP    #15             ; WAIT FOR KEY PRESS
    RTS
    
GATHER_RESOURCES:
    BSR     ENDL            ; NEW LINE

    ; CHECK IF ENOUGH BUCKS
    CMP.W   #GATHER_BUCKS_COST,BUCKS ; DO YOU HAVE ENOUGH BUCKS?
    BGE     CHECK_ENERGY    ; IF YES, PROCEED TO ENERGY CHECK
    LEA     NOT_ENOUGH_BUCKS_MSG,A1 ; IF NO, DISPLAY ERROR
    MOVE.B  #14,D0
    TRAP    #15
    RTS                     ; RETURN WITHOUT GATHERING

CHECK_ENERGY:
    ; CHECK IF ENERGY IS 0
    CMP.W   #0,ENERGY       ; IS ENERGY 0?
    BGT     ENERGY_OK       ; IF ENERGY > 0, PROCEED TO GATHER
    LEA     NO_ENERGY_MSG,A1 ; LOAD "NO ENERGY" MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15
    RTS                     ; RETURN WITHOUT GATHERING RESOURCES

ENERGY_OK:
    LEA     GATHER_RESOURCES_MSG,A1 ; LOAD GATHER RESOURCES MESSAGE
    MOVE.B  #14,D0          ; DISPLAY STRING
    TRAP    #15

    ; DEDUCT BUCKS
    SUB.W   #GATHER_BUCKS_COST,BUCKS ; DEDUCT BUCKS COST

    ; ADD RESOURCES
    ADD.W   #10,WOOD        ; ADD 10 WOOD
    ADD.W   #5,STONE        ; ADD 5 STONE
    ADD.W   #3,METAL        ; ADD 3 METAL

    ; REDUCE ENERGY
    SUB.W   #20,ENERGY      ; REDUCE ENERGY BY 20
    CMP.W   #0,ENERGY       ; ENSURE ENERGY DOESN'T GO BELOW 0
    BGE     SKIP_ENERGY_FIX
    MOVE.W  #0,ENERGY       ; SET ENERGY TO 0 IF IT GOES NEGATIVE

SKIP_ENERGY_FIX:
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
    ADD.W   #50,PROFIT      ; SUBTRACT $50 FROM PROFIT (COST OF BUILDING THE HOUSE)

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

*-----------------------------------------------------------
* DEV_MODE SUBROUTINE
* ALLOWS DEVELOPER TO MODIFY GAME VARIABLES
*-----------------------------------------------------------
DEV_MODE:
    BSR     ENDL
    BSR     DECORATE
    LEA     DEV_MODE_MSG,A1  ; DISPLAY DEV MODE ACTIVATED MESSAGE
    MOVE.B  #14,D0
    TRAP    #15

    ; INPUT NEW WOOD VALUE
    LEA     ENTER_WOOD_MSG,A1 ; PROMPT FOR WOOD VALUE
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #4,D0            ; READ INPUT
    TRAP    #15
    MOVE.W  D1,WOOD          ; STORE NEW WOOD VALUE

    ; INPUT NEW STONE VALUE
    LEA     ENTER_STONE_MSG,A1 ; PROMPT FOR STONE VALUE
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #4,D0            ; READ INPUT
    TRAP    #15
    MOVE.W  D1,STONE         ; STORE NEW STONE VALUE

    ; INPUT NEW METAL VALUE
    LEA     ENTER_METAL_MSG,A1 ; PROMPT FOR METAL VALUE
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #4,D0            ; READ INPUT
    TRAP    #15
    MOVE.W  D1,METAL         ; STORE NEW METAL VALUE

    ; INPUT NEW HOUSES VALUE
    LEA     ENTER_HOUSES_MSG,A1 ; PROMPT FOR HOUSES VALUE
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #4,D0            ; READ INPUT
    TRAP    #15
    MOVE.W  D1,HOUSES        ; STORE NEW HOUSES VALUE

    ; INPUT NEW BUCKS VALUE
    LEA     ENTER_BUCKS_MSG,A1 ; PROMPT FOR BUCKS VALUE
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #4,D0            ; READ INPUT
    TRAP    #15
    MOVE.W  D1,BUCKS         ; STORE NEW BUCKS VALUE

    ; INPUT NEW PROFIT VALUE
    LEA     ENTER_PROFIT_MSG,A1 ; PROMPT FOR PROFIT VALUE
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #4,D0            ; READ INPUT
    TRAP    #15
    MOVE.W  D1,PROFIT        ; STORE NEW PROFIT VALUE

    ; DISPLAY SUCCESS MESSAGE
    LEA     VALUES_UPDATED_MSG,A1 ; DISPLAY VALUES UPDATED MESSAGE
    MOVE.B  #14,D0
    TRAP    #15
    BSR     PRESS_CONTINUE   ; WAIT FOR KEY PRESS AND RETURN TO MENU
    RTS

ENDL:
    MOVEM.L D0/A1,-(A7)     ;SAVE D0 AND A1
    MOVE    #14,D0          ;MOVE LITERAL 14 TO DO
    LEA     CRLF,A1         ;ASSIGN CRLF TO ADDRESS REGISTER A1
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    MOVEM.L (A7)+,D0/A1     ;RESTORE D0 AND A1
    RTS                     ;RETURN FROM ENDL: SUBROUTINE

*-----------------------------------------------------------
*-------------------DATA DECLARATIONS--------------------
*-----------------------------------------------------------

*-----------------------------------------------------------
* CONSTANTS
*-----------------------------------------------------------
EXIT                    EQU 0           ; USED TO EXIT ASSEMBLY PROGRAM
DAILY_PAYMENT           EQU 20          ; BUCKS EARNED WHEN SKIPPING TO NEXT DAY
TARGET_BUCKS            EQU 500         ; TARGET AMOUNT OF BUCKS TO WIN THE GAME
GATHER_BUCKS_COST       EQU 20          ; BUCKS REQUIRED TO GATHER RESOURCES
DETACHED_BUCKS_COST     EQU 30          ; BUCKS REQUIRED TO BUILD A DETACHED HOUSE
APARTMENT_BUCKS_COST    EQU 50          ; BUCKS REQUIRED TO BUILD AN APARTMENT
BUILDING_BUCKS_COST     EQU 100         ; BUCKS REQUIRED TO BUILD A BUILDING
MANSION_BUCKS_COST      EQU 200         ; BUCKS REQUIRED TO BUILD A MANSION
DETACHED_SELL_PRICE     EQU 45          ; MAX OFFER FOR A DETACHED HOUSE
APARTMENT_SELL_PRICE    EQU 75          ; MAX OFFER FOR AN APARTMENT
BUILDING_SELL_PRICE     EQU 150         ; MAX OFFER FOR A BUILDING
MANSION_SELL_PRICE      EQU 300         ; MAX OFFER FOR A MANSION

*-----------------------------------------------------------
* VARIABLES
*-----------------------------------------------------------
WOOD                    DS.W    1       ; AMOUNT OF WOOD
STONE                   DS.W    1       ; AMOUNT OF STONE
METAL                   DS.W    1       ; AMOUNT OF METAL
ENERGY                  DS.W  100       ; VALUE IN ENERGY
DAY                     DS.W    1       ; CURRENT DAY
DETACHED_HOUSES         DS.W    1       ; NUMBER OF DETACHED HOUSES BUILT
APARTMENT_HOUSES        DS.W    1       ; NUMBER OF APARTMENTS BUILT
BUILDING_HOUSES         DS.W    1       ; NUMBER OF BUILDINGS BUILT
MANSION_HOUSES          DS.W    1       ; NUMBER OF MANSIONS BUILT
HOUSES                  DS.W    1       ; TOTAL HOUSES BUILT (SUM OF ALL TYPES)
BUCKS                   DS.W    100     ; PLAYER'S MONEY (BUCKS)
PROFIT                  DS.W    1       ; TOTAL PROFIT EARNED
SCORE                   DS.W    1       ; RESERVE SPACE FOR SCORE

*-----------------------------------------------------------
* MESSAGES
*-----------------------------------------------------------

*--- GENERAL MESSAGES ---
CRLF                    DC.B    $0D,$0A,0
LOOP_MSG                DC.B    '.',0
DEBUG_BUCKS_MSG         DC.B    'Current BUCKS: ', 0

*--- WELCOME AND OBJECTIVE MESSAGES ---
WELCOME_MSG             DC.B    '************************************************************',$0D,$0A
                        DC.B    'WELCOME TO THE ULTIMATE HOUSE BUILD',$0D,$0A
                        DC.B    '************************************************************',$0D,0
                        DC.B    $0D,$0A,0
OBJECTIVE_MSG           DC.B    '************************************************************',$0D,$0A
                        DC.B    'OBJECTIVE:',$0D,$0A
                        DC.B    'BUILD HOUSES BY GATHERING RESOURCES LIKE WOOD, STONE, AND METAL.',$0D,$0A
                        DC.B    'MANAGE YOUR RESOURCES WISELY TO CONSTRUCT HOUSES AND SELL THEM',$0D,$0A
                        DC.B    'FOR A PROFIT. BECOME THE BEST HOUSE BUILDER IN THE LAND!',$0D,$0A
                        DC.B    '************************************************************',$0D,$0A,0

*--- GAMEPLAY AND UPDATE MESSAGES ---
GAMEPLAY_MSG            DC.B    'WELCOME TO HOUSE BUILDER! LETS CONSTRUCT SOME HOUSES!',$0D,$0A,0
UPDATE_MSG              DC.B    'UPDATING CONSTRUCTION PROGRESS...',$0D,$0A,0
DRAW_MSG                DC.B    'REDRAWING CONSTRUCTION SITE...',$0D,0
REPLAY_MSG              DC.B    'ENTER 0 TO QUIT, ANY OTHER NUMBER TO REPLAY: ',0
CONTINUE_MSG            DC.B    'PRESS ANY KEY TO CONTINUE...', $0D, $0A, 0
PRESS_CONTINUE_MSG      DC.B    'PRESS ANYKEY TO CONTINUE: ',0
PAYMENT_MSG             DC.B    'You earned ',0
PAYMENT_END_MSG         DC.B    ' bucks for the day.', $0D, $0A, 0
NEW_DAY_MSG             DC.B    'YOU FEEL YOUR ENERGY REPLENISH..',$0D,$0A,0
DAY_MSG                 DC.B    ' DAY ',0
GOAL_MSG                DC.B    'GOAL: Make ',0
GOAL_END_MSG            DC.B    ' bucks as fast as you can! Fewer days = better score.', $0D, $0A, 0
STATS_HEADER            DC.B    'STATS:',$0D,$0A,0
HUD_MSG                 DC.B    'RESOURCES: WOOD=',0
WOOD_MSG                DC.B    ' WOOD=',0
STONE_MSG               DC.B    ' STONE=',0
METAL_MSG               DC.B    ' METAL=',0
HOUSES_MSG              DC.B    ' HOUSES BUILT=',0
PROFIT_MSG              DC.B    ' PROFIT=$',0
ENERGY_MSG              DC.B    ' ENERGY=',0
BUCKS_MSG               DC.B    ' BUCKS=$',0
GAMEPLAY_MENU_MSG       DC.B    'GAMEPLAY MENU:',$0D,$0A
                        DC.B    '1. GATHER RESOURCES',$0D,$0A
                        DC.B    '2. BUILD HOUSE',$0D,$0A
                        DC.B    '3. SELL HOUSE',$0D,$0A
                        DC.B    '4. VIEW STATS',$0D,$0A
                        DC.B    '5. QUIT GAME',$0D,$0A
                        DC.B    '6. SKIP TO NEXT DAY',$0D,$0A,0

INVALID_INPUT_MSG       DC.B    'INVALID INPUT! PLEASE CHOOSE 1, 2, 3, 4, OR 5.',$0D,$0A,0

*--- BUILDING AND SELLING MESSAGES ---
BUILD_HOUSE_MENU_MSG    DC.B    'BUILD HOUSE MENU:', $0D, $0A
                        DC.B    '1. DETACHED HOUSE (30 BUCKS, 10 WOOD, 5 STONE, 3 METAL)', $0D, $0A
                        DC.B    '2. APARTMENT (50 BUCKS, 20 WOOD, 10 STONE, 5 METAL)', $0D, $0A
                        DC.B    '3. BUILDING (100 BUCKS, 50 WOOD, 30 STONE, 10 METAL)', $0D, $0A
                        DC.B    '4. MANSION (200 BUCKS, 100 WOOD, 50 STONE, 20 METAL)', $0D, $0A
                        DC.B    '5. BACK TO MAIN MENU', $0D, $0A, 0
SELL_HOUSE_MENU_MSG     DC.B    'SELL HOUSE MENU:', $0D, $0A
                        DC.B    '1. SELL DETACHED HOUSE ($45)', $0D, $0A
                        DC.B    '2. SELL APARTMENT ($75)', $0D, $0A
                        DC.B    '3. SELL BUILDING ($150)', $0D, $0A
                        DC.B    '4. SELL MANSION ($300)', $0D, $0A
                        DC.B    '5. BACK TO MAIN MENU', $0D, $0A, 0
SCANNING_MSG            DC.B    'Scanning for offers...', $0D, $0A, 0
DETACHED_SOLD_MSG       DC.B    'Detached house sold for $45!', $0D, $0A, 0
APARTMENT_SOLD_MSG      DC.B    'Apartment sold for $75!', $0D, $0A, 0
BUILDING_SOLD_MSG       DC.B    'Building sold for $150!', $0D, $0A, 0
MANSION_SOLD_MSG        DC.B    'Mansion sold for $300!', $0D, $0A, 0
DETACHED_BUILT_MSG      DC.B    'DETACHED HOUSE BUILT SUCCESSFULLY!', $0D, $0A, 0
APARTMENT_BUILT_MSG     DC.B    'APARTMENT BUILT SUCCESSFULLY!', $0D, $0A, 0
BUILDING_BUILT_MSG      DC.B    'BUILDING BUILT SUCCESSFULLY!', $0D, $0A, 0
MANSION_BUILT_MSG       DC.B    'MANSION BUILT SUCCESSFULLY!', $0D, $0A, 0
HOUSE_BUILT_MSG         DC.B    'HOUSE BUILT SUCCESSFULLY!',0
NO_ENERGY_MSG           DC.B    'You are too exhausted to gather resources! Rest until the next day.',$0D,$0A,0
NOT_ENOUGH_WOOD_MSG     DC.B    'NOT ENOUGH WOOD TO BUILD A HOUSE!',0
NOT_ENOUGH_STONE_MSG    DC.B    'NOT ENOUGH STONE TO BUILD A HOUSE!',0
NOT_ENOUGH_METAL_MSG    DC.B    'NOT ENOUGH METAL TO BUILD A HOUSE!',0
NOT_ENOUGH_BUCKS_MSG    DC.B    'Not enough bucks to perform this action!', $0D, $0A, 0
HOUSE_SOLD_MSG          DC.B    'HOUSE SOLD FOR $100 PROFIT AND $50 BUCKS!', $0D, $0A, 0
NO_HOUSES_MSG           DC.B    'NO HOUSES TO SELL!',0
LOW_ENERGY_MSG          DC.B    'Your construction workers have called it a day..',$0D,$0A,0
OPTION_1_MSG            DC.B    'STARTING QUEST...',$0D,$0A,0
OPTION_5_MSG            DC.B    'QUITTING GAME... GOODBYE!',$0D,$0A,0
GATHER_RESOURCES_MSG    DC.B    'GATHERING RESOURCES... WOOD, STONE, AND METAL ADDED TO YOUR INVENTORY.',$0D,$0A,0

*--- DEV MODE MESSAGES ---
DEV_MODE_MSG            DC.B    'DEV MODE ACTIVATED! ENTER NEW VALUES:', $0D, $0A, 0
ENTER_WOOD_MSG          DC.B    'ENTER NEW WOOD VALUE: ', 0
ENTER_STONE_MSG         DC.B    'ENTER NEW STONE VALUE: ', 0
ENTER_METAL_MSG         DC.B    'ENTER NEW METAL VALUE: ', 0
ENTER_HOUSES_MSG        DC.B    'ENTER NEW HOUSES VALUE: ', 0
ENTER_BUCKS_MSG         DC.B    'ENTER NEW BUCKS VALUE: ', 0
ENTER_PROFIT_MSG        DC.B    'ENTER NEW PROFIT VALUE: ', 0
VALUES_UPDATED_MSG      DC.B    'VALUES UPDATED SUCCESSFULLY!', $0D, $0A, 0

*--- WIN/LOSE MESSAGES ---
WIN_MSG                 DC.B    'CONGRATULATIONS! You reached ',0
WIN_BUCKS_MSG           DC.B    ' bucks in ',0
WIN_DAYS_MSG            DC.B    ' days! The fewer days, the better your score!', $0D, $0A, 0
LOSE_MSG                DC.B    'GAME OVER! You ran out of bucks after ',0
LOSE_DAYS_MSG           DC.B    ' days.', $0D, $0A, 0
WIN_HOUSES_MSG          DC.B    'CONGRATULATIONS! You built 5 houses in ', 0
OFFER_REJECTED_MSG      DC.B    'Offer rejected. Returning to menu...', $0D, $0A, 0

*--- ART ASSETS ---
HOUSE_ART               DC.B    '    _________H ,%%&%,', $0D, $0A
                        DC.B    '   /\     _   \%&&%%&%', $0D, $0A
                        DC.B    '  /  \___/^\___\%&%%&&', $0D, $0A
                        DC.B    '  |  | []   [] |%\Y&%''', $0D, $0A
                        DC.B    '  |  |   .-.   | ||  ', $0D, $0A
                        DC.B    '~~@._|@@_|||_@@|~||~~~~~~~~~~~~~', $0D, $0A
                        DC.B    '     `""") )"""`', $0D, $0A, 0
MANSION_ART             DC.B    '         (', $0D, $0A
                        DC.B    '           )', $0D, $0A
                        DC.B    '         ( _   _._', $0D, $0A
                        DC.B    '          |_|-''_~_`-.', $0D, $0A
                        DC.B    '       _.-''-_~_-~_-~-_`-._', $0D, $0A
                        DC.B    '   _.-''_~-_~-_-~-_~_~-_~-_`-._', $0D, $0A
                        DC.B    '  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~', $0D, $0A
                        DC.B    '    |  []  []   []   []  [] |', $0D, $0A
                        DC.B    '    |           __    ___   |', $0D, $0A
                        DC.B    '  ._|  []  []  | .|  [___]  |_._._._._._._._._._._._._._._._.', $0D, $0A
                        DC.B    '  |=|________()|__|()_______|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|', $0D, $0A
                        DC.B    '^^^^^^^^^^^^^^^ === ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^', $0D, $0A
                        DC.B    '    _______      ===', $0D, $0A
                        DC.B    '   <_4sale_>       ===', $0D, $0A
                        DC.B    '      ^|^             ===', $0D, $0A
                        DC.B    '       |                 ===', $0D, $0A, 0
BUILDING_ART            DC.B    '__                   ___                       ( )', $0D, $0A
                        DC.B    ' |""|  ___    _   __  |"""|  __                   `', $0D, $0A
                        DC.B    ' |""| |"""|  |"| |""| |"""| |""|        _._ _', $0D, $0A
                        DC.B    ' |""| |"""|  |"| |""| |"""| |""|       (__((_(', $0D, $0A
                        DC.B    ' |""| |"""|  |"| |""| |"""| |""|      \''-:--:-.', $0D, $0A
                        DC.B    ' "''''"''"''''""''''''"""''""''""~~~~~~''-----''~~~~  ldb', $0D, $0A, 0
APARTMENT_ART           DC.B    '   _______________', $0D, $0A
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
