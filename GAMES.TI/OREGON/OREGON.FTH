\ ORGEGON TRAIL BY  majestyx on Atariage
\ RE-WRITE for  CAMEL99 Forth. Game specific language demonstration
\ Brian Fox  Dec 12, 2019

\ INCLUDE DSK1.TOOLS
INCLUDE DSK1.RANDOM
INCLUDE DSK1.INPUT
INCLUDE DSK1.FASTCASE
INCLUDE DSK1.CASE
INCLUDE DSK1.ENUM
INCLUDE DSK1.VDPMEM

CR
CR .( OREGON2 file must be in DISK 3)
CR .( Press a key to continue) KEY DROP

INCLUDE DSK3.OREGON2

CR
CR .( OREGON3 file must be in DISK 3)
CR .( Press a key to continue) KEY DROP

INCLUDE DSK3.OREGON3

20 CASH !
: .CASH    ." You have " CASH @ DOLLARS ." cash" ;

: BUYFOOD
         PRINT." How much do you want to spend?"
         CR .CASH
         TEMP 1 CASH @ VALID-INPUT
         DUP CASH DEBIT  FOOD CREDIT
         CR .CASH ." left"
;

\ ================================================
\ status testers begin with a ?

: ?FOOD  \ test if we have enough Food points left
          FOOD @ 1 < IF   STARVED  ENDIF
          FOOD @ 10 <
          IF
              PRINT." You need to do some hunting or by some food!!!"
              PRINT." 1. Hunt"
              PRINT." 2. Buy Food"
              PRINT." Enter to go on"
              CR
              KEY
              CASE
                  [CHAR] 1 OF HUNT     ENDOF
                  [CHAR] 2 OF BUYFOOD  ENDOF
              ENDCASE
          ENDIF ;

: ?WOUNDED
         WOUNDED @ 0 <>
         IF CR
            PRINT." Did you know you are wounded?"
            DOCTOR?
         ENDIF
;

: TOOLONG
           CR PRINT." It's a terrible shame."
           1000 MS
           PRINT." Y'all didn't get to Oregon
           PRINT." in time.
           1000 MS
           PRINT." I reckon yer lost"
           CR CR
           SORRY ;


: ?TIMEOUT    DAY @ 25 > IF TOOLONG  ENDIF ;

\ GOOD STUFF THAT CAN HAPPEN
: NATIVES
      CR
      PRINT." You bumped into friendly Haida people."
      50 %CHANCE:
          PRINT." They gave you fresh food"
          20 RANDOM 4 +  FOOD CREDIT
          5 HEALTH CREDIT
      ;CHANCE

      60 %CHANCE:
          PRINT." and fed your animals!"
          40 OXEN CREDIT
      ;CHANCE
;

: HUNTER  50 %CHANCE:
             CR PRINT." You met a hunter and he gave you a " ANIMAL

          ;CHANCE
;

: GRAZING
         50 %CHANCE:
             CR
             PRINT." Good luck!"
             PRINT." Your Oxen found some nice grazing."
             15 RANDOM 2+  OXEN CREDIT
         ;CHANCE
;

: GOODWEATHER
          50 %CHANCE:
             CR
             PRINT." The weather is good for travelling."
             1 OXEN CREDIT
             1 HEALTH CREDIT
             1 CLOTHING CREDIT
          ;CHANCE

;

CASE: LUCKY   | NATIVES  | HUNTER  | GRAZING  ;CASE

: HAPPYDAYS   3 RANDOM LUCKY  ;

: AreWeThereYet?
         MILEAGE @ DESTINATION  >
         IF
            CONGRATS
         THEN
         PRINT." We travelled "  MILEAGE @ . ." miles."
;

: CONSUME  \  things are used up every day
      10 RANDOM 1+ HEALTH DEBIT
      40 RANDOM 1+ OXEN# @ * 5 + OXEN DEBIT
      10 RANDOM 1+ FOOD DEBIT
      10 RANDOM 1+ CLOTHES DEBIT
      10 RANDOM 1+ MISC DEBIT
;

: ?OXEN
         OXEN @ 10 <
         IF  PRINT." Yer oxen are almost dead!"
             PRINT." Wanna stop for grazing"
             Y/N?
             IF ...
                ROLL-DICE OXEN CREDIT
                48 %CHANCE:
                   CR PRINT." Uhoh, we got company!"
                   HOSTILE-DECIDE
                ELSE
                   ROLL-DICE 5 * OXEN CREDIT
                   PRINT." Oxen are now worth" OXEN @ DOLLARS
                   CR
               ;CHANCE
             ENDIF
        ENDIF
;

: TITLE-PAGE
         TEXT  GREEN
         CENTER." * O R E G O N  T R A I L *"
         CR CENTER." The game that time forgot"
         CR CR CR
         2000 MS
         CENTER." Based on BASIC version
         CENTER." by Majestyx on Atariage"
         1000 MS
         CR CR CR CR CR
         CENTER." Re-write in Forth by TheBF"
         0 22 AT-XY
         CENTER." Press a key to begin"
         KEY DROP
;

: OPENING
         TITLE-PAGE
         YELLOW PAGE
         PRINT."  -- You're on the Oregon trail" ...
         12 RANDOM 1+ MONTH !
         1 DAY !
         CR .DATE ...
         SETUP
;

: CAMP   CR
         PRINT." Oxen are tied up, fire is lit."
         PRINT." Get some sleep partner" ...
         33 %CHANCE:
              PRINT." Uhoh! I heard some footsteps"
              PRINT." over yonder!"
              HOSTILE-DECIDE
        OTHERWISE
              CR
              PRINT." We had a peacful night"
              PRINT." Eat some vittles and git goin'"
              10 RANDOM 1+  FOOD DEBIT
              10 HEALTH CREDIT
              50 RANDOM 15 + OXEN CREDIT
        ;CHANCE
;

: VALIDATE ( c addr len -- ? )  ROT SCAN NIP ;

: MENU-KEY ( c)
         BEGIN
            KEY  DUP S" 12349" VALIDATE
         0= WHILE
            DROP
         REPEAT ;

: MENU
     CR
     PRINT." It's " .DAY
     PRINT." What do you want to do?"
     PRINT." 1) Keep moving"
     PRINT." 2) Setup Camp for the night"
     PRINT." 3) Hunt"
     PRINT." 4) Check supplies"
     CR ." > " MENU-KEY
     CASE
       [CHAR] 1 OF CONTINUE    ENDOF
       [CHAR] 2 OF CAMP        ENDOF
       [CHAR] 3 OF HUNT        ENDOF
       [CHAR] 4 OF .SUPPLIES   ENDOF
       [CHAR] 9 OF  ." Secret programmer escape ;-)" ABORT ENDOF
    ENDCASE
;

: RUN ( -- )
    NEWGAME
    OPENING
    BEGIN
      MENU
      CONSUME
     ( 2 oxen multiplies the credit)
      14 RANDOM 2+  OXEN# @ *  MILEAGE CREDIT
       AreWeThereYet?

      30 %CHANCE: SHITHAPPENS   ;CHANCE
      15 %CHANCE:  HAPPYDAYS    ;CHANCE

      ( test our status)
      ?FOOD  ?OXEN  ?BROKE  ?DEAD
      ?WOUNDED  ?HEALTH  ?BROKE
      1 DAY CREDIT
      ?TIMEOUT
   AGAIN
;

RUN 
