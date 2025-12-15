\ OREGON TRAIL GAME FILE: DSK3.OREGON2
\ ====================================================
\ VDP STRING and PRINT
 Replaces ." so that it compiles literal strings in VDP RAM.
\ Also adds PRINT." which is like BASIC print with leading CR

NEEDS VCOUNT FROM DSK1.VDPMEM

\ ====================================================
\ VDP string support
\ compile stack string into VDP memory
: VS,     ( $adr len-- )  VHERE OVER CHAR+  VALLOT VPLACE ;
: VSLITERAL  VS, POSTPONE LITERAL ;

\ Print a VDP stack string
: VTYPE   ( vdp_addr len -- ) BOUNDS ?DO   I VC@ EMIT   LOOP ;

: V.$   ( V$ -- ) VCOUNT VTYPE ;

\ Compile a VDP string, that types itself
: ."  ( -- )
    ?COMP
    VHERE
    [CHAR] " PARSE  VSLITERAL
    POSTPONE V.$
; IMMEDIATE

: PRINT."   POSTPONE CR  POSTPONE ." ; IMMEDIATE

\ Print a stack string centered on the screen
: CENTERTYPE  ( addr len -- ) DUP C/L@ SWAP - 2/ 1- SPACES TYPE ;

\ Compile text string and print on a newline centered on the screen
: CENTER."
        ?COMP
        POSTPONE CR
        POSTPONE S"
        POSTPONE CENTERTYPE ;  IMMEDIATE

\ =========================================
\ helpers for choice tables....
: CLIP     ( n lo hi -- n') ROT MIN MAX ;   \ clip input to lo/hi
: RANDOM   ( n -- )   1 OVER CLIP  RND ;    \ limit RND number to min(1)


\ =========================================
\ G A M E  L A N G U A G E

DECIMAL
: CHOICES,  ( addr... addr[n] n -- ) 0 ?DO  COMPILE, LOOP ;  \ compile addresses

: 3RD     ( a b c -- a b c a ) 2 PICK ;  \ get a copy of 3rd item on the stack

\ text game language extensions
: BETWEEN ( n lo hi -- ?) 1+ WITHIN ;

\ %CHANCE structure replaces IF for random events
\  50 %CHANCE:    PRINT." Something is moving in the bushes"
\      OTHERWISE  PRINT." It's all quiet here."
\  ;CHANCE

: %CHANCE:  ( n -- ? ) S" 100 RND > IF" EVALUATE ; IMMEDIATE
: OTHERWISE            POSTPONE ELSE ; IMMEDIATE
: ;CHANCE              POSTPONE THEN ; IMMEDIATE

\ syntax sugar
: ENDIF     POSTPONE THEN ; IMMEDIATE
: CHOICE:  :NONAME ;

\ read #input into a variable and test for limits
: VALID-INPUT ( variable  lo  hi  -- n )
          BEGIN
             3RD DUP #INPUT
             @ 3RD 3RD BETWEEN  \ fetch from variable, check limits
          UNTIL
          2DROP @ ;  \  drop limits, fetch variable value

HEX
: TOUPPER  ( c -- c') 5F AND ;

DECIMAL
: Y/N?    ( -- ?) PRINT." Y/N?"  KEY TOUPPER [CHAR] Y = ;

: .R      ( n width -- )  \ print n right justified
          >R DUP ABS 0 <# #S ROT SIGN #> R> OVER - SPACES  TYPE ;

: DEBIT     ( n variable -- ) DUP >R @ SWAP NEGATE + 0 MAX  R> ! ;
: CREDIT    ( n variable -- ) +! ;

\ set screen color with black letters
HEX
: CYAN   ( -- ) 17 7 VWTR ;
: GREEN  ( -- ) 13 7 VWTR ;
: YELLOW ( -- ) 1B 7 VWTR ;

DECIMAL
: ROLL-DICE  ( -- n ) 12 RANDOM 1+ ;  \ Random # 1..12

\ random delay with dot printing
: ...  ( n -- ) 9 RANDOM CELL+  0 ?DO  [CHAR] . EMIT  250 MS   LOOP ;


\ ==============================================
\ **********************************************
\ ==============================================
\ O R E G O N   C O D E   S T A R T S   H E R E

DECIMAL
\ game data
 700 CONSTANT BUDGET
1847 CONSTANT YEAR
 100 CONSTANT DESTINATION ( how far we have to travel)

VARIABLE TEMP
VARIABLE ACCURACY
VARIABLE TOTAL

\ status variables for the traveller
VARIABLE HEALTH
VARIABLE OXEN  ( HEALTH)
VARIABLE OXEN#  ( normally 2)
VARIABLE FOOD
VARIABLE QUALITY
VARIABLE AMMO
VARIABLE CLOTHES
VARIABLE MISC
VARIABLE CASH
VARIABLE WOUNDED

VARIABLE ACTION
VARIABLE MILEAGE
VARIABLE DAY
VARIABLE MONTH

: NEWGAME
     HEALTH OFF
     OXEN OFF
     OXEN# OFF
     FOOD OFF
     AMMO OFF
     CLOTHES OFF
     MISC OFF
     CASH OFF
     WOUNDED OFF
     MILEAGE OFF
;

0 ENUM SUN
  ENUM MON
  ENUM TUE
  ENUM WED
  ENUM THU
  ENUM FRI
  ENUM SAT
DROP

1 ENUM JAN
  ENUM FEB
  ENUM MAR
  ENUM APR
  ENUM MAY
  ENUM JUN
  ENUM JUL
  ENUM AUG
  ENUM SEP
  ENUM OCT
  ENUM NOV
  ENUM DEC
DROP

: DEBIT-TOTAL   ( n -- ) TOTAL DEBIT ;

: ?DAY    TRUE ABORT" Bad day#"  ;
: ?MONTH  TRUE ABORT" Bad Month#" ;

\ days print themselves
: .MON     ." Monday" ;      : .TUE    ." Tuesday" ;
: .WED     ." Wednesday" ;   : .THU    ." Thursday" ;
: .FRI     ." Friday" ;      : .SAT    ." Saturday" ;
: .SUN     ." Sunday" ;

\ a table of execution addresses of days
CASE: DAYS  ( 1..7 -- )
      | .SUN | .MON | .TUE | .WED
      | .THU | .FRI | .SAT
      | ?DAY
;CASE

: .DAY     DAY @ DUP 6 MOD DAYS ." , day "  . ;

\ Months print themselves
: MTH1    ." January" ;      : MTH7    ." July" ;
: MTH2    ." February" ;     : MTH8    ." August" ;
: MTH3    ." March" ;        : MTH9    ." September" ;
: MTH4    ." April"  ;       : MTH10   ." October" ;
: MTH5    ." May" ;          : MTH11   ." November" ;
: MTH6    ." June" ;         : MTH12   ." December" ;

CASE: MONTHS ( 1..12 -- )
     | ?MONTH
     | MTH1 | MTH2  | MTH3  | MTH4
     | MTH5 | MTH6  | MTH7  | MTH8
     | MTH9 | MTH10 | MTH11 | MTH12
     | ?MONTH
;CASE

: .MONTH  ( -- )  MONTH @  MONTHS ;

: .DATE  ( -- )   .DAY ." , "  .MONTH SPACE DAY @ 2 .R  ." , "  YEAR . ;

\ DOLLAR value formatted printing
: >$<    ( -- n ) [CHAR] $ HOLD ;
: >.<    ( -- n ) [CHAR] . HOLD ;
: '00'    [CHAR] 0 DUP HOLD HOLD ;
: DOLLARS ( n -- ) DUP ABS 0  <# '00' >.< #S >$< ROT SIGN #> TYPE SPACE ;

: .BALANCE    PRINT." YOU HAVE "  TOTAL @ DOLLARS ." left";

: GET_ACCURACY ( -- )
          PRINT."  How well can you shoot?"
          PRINT."  (1) BEST"
          PRINT."  (2) GOOD"
          PRINT."  (3) FAIR"
          PRINT."  (4) Not sure..."
          PRINT."  (5) BAD"
          PRINT."  (1..5) : "
          ACCURACY  1 5 VALID-INPUT 25 * ACCURACY !  ;

: TEAM    ( -- )
          CR
          PRINT." How much do you want to spend"
          PRINT." on your team of oxen? ($200-$300)"
          OXEN 200 300 VALID-INPUT ;

: GETFOOD  ( -- ) PRINT."  ON FOOD "            FOOD  0 TOTAL @ VALID-INPUT ;
: GETAMMO  ( -- ) PRINT."  ON AMMUNITION "      AMMO  0 TOTAL @ VALID-INPUT ;
: CLOTHING ( -- ) PRINT."  ON CLOTHING "     CLOTHES  0 TOTAL @ VALID-INPUT ;
: GETMISC  ( -- ) PRINT."  ON MISC. SUPPLIES "  MISC  0 TOTAL @ VALID-INPUT ;

: .Y/N     ( ? --) IF ." Yes" ELSE ." No"  ENDIF ;

: .SUPPLIES
      CR
      PRINT."     -- Supplies Report --"
      CR    .DATE
      PRINT." FOOD          :   "  FOOD    @ DOLLARS
      PRINT." BULLETS       :   "  AMMO    @ DOLLARS
      PRINT." CLOTHING      :   "  CLOTHES @ DOLLARS
      PRINT." MISC. SUPPLIES:   "  MISC    @ DOLLARS
      PRINT." CASH          :   "  CASH    @ DOLLARS
      PRINT."        -- Status --"
      PRINT."  Health       :   "  HEALTH @  4 .R
      PRINT."  Wounded      :   "  WOUNDED @ .Y/N
      CR
;

: BUYSTUFF
          PRINT."  Let's get you set you for the trip:"
          TEAM     DEBIT-TOTAL .BALANCE
          GETFOOD  DEBIT-TOTAL .BALANCE
          GETAMMO  DEBIT-TOTAL .BALANCE
          CLOTHING DEBIT-TOTAL .BALANCE
          GETMISC  DEBIT-TOTAL .BALANCE
          TOTAL @ CASH !
;

: SETUP   CR
          PRINT."  Your budget for the trip is: " BUDGET DOLLARS
          BUDGET TOTAL !
          GET_ACCURACY
          BUYSTUFF
          100 HEALTH !
          WOUNDED OFF
          .SUPPLIES
;

\ =====================================================
\ End of game messages
: AGAIN?  CR CR ." Type RUN to play again" CR CYAN QUIT ;

: SORRY  PRINT."  ********************************"
         PRINT."  We are sorry. You didn't make it"
         PRINT."  to the great territory of Oregon."
         PRINT."  We will notify yer kinfolk."
         CR
         PRINT."  - Sincerely"
         CR
         PRINT."           The Oregon"
         PRINT."      -Chamber of Commerce-"
         HEALTH OFF
         AGAIN? ;

: CONGRATS
         PAGE
         PRINT." ************************"
         PRINT." President James K. Polk"
         PRINT." sends you his heartiest"
         PRINT." congratulations,"
         CR
         PRINT." He wishes you a prosperous life"
         PRINT." at your new home."
         CR
         PRINT." Press a key to end" KEY DROP
         AGAIN? ;

: ?DEAD
         HEALTH @ 0=
         IF  ...
            CR PRINT." Unfortunately you died on"  1000 MS
            CR .DATE
            CR
            SORRY
        ENDIF ;

: SEE-DOCTOR
         CR  ...
         PRINT." The doc wants " 30 RANDOM 5 +  DUP DOLLARS
         PRINT." to patch you up."
         DUP CASH @ >
         IF
            PRINT." You cain't afford it partner!"
            20 RANDOM 5 + HEALTH DEBIT
            DROP
         ELSE
            CASH DEBIT
            PRINT." You got enough money."
            PRINT." He's good with the needle & thread"
            WOUNDED OFF
            10 HEALTH CREDIT
             5 MISC CREDIT
         ENDIF
         ?DEAD
;

\ ====================================================
\ random sickness selector
CHOICE:  ." Pneumonia"      30 HEALTH DEBIT ;
CHOICE:  ." Typhoid fever"  23 HEALTH DEBIT ;
CHOICE:  ." Swine Flu"      10 HEALTH DEBIT ;
CHOICE:  ." Consumption"    20 HEALTH DEBIT ;
CHOICE:  ." Scurvy"         15 HEALTH DEBIT ;
CHOICE:  ." Infection"      20 HEALTH DEBIT ;
CHOICE:  ." smallpox"       40 HEALTH DEBIT ;
CASE: DISEASES  7 CHOICES,  ;CASE

: SICKNESS     7 RANDOM DISEASES ;


\ =====================================================
\ BAD luck
: STARVED
         PRINT."  You ran out of food and"
         PRINT."  starved to death"
         HEALTH OFF
         SORRY ;

: SNAKEBITE
         PRINT." You die of snakebite since"
         PRINT." you have no medicine"
         HEALTH OFF
         SORRY ;

: MASSACRE
          PRINT." You were attacked and"
          PRINT." massacred by criminals"
          HEALTH OFF
          SORRY ;

: FROZE
          PRINT." Weather took a turn partner."
          PRINT." It went down to 30 below."
          PRINT." You and the family froze solid"
          HEALTH OFF
          SORRY
;

: NOMEDICINE
          CR
          PRINT."  You ran out of medical supplies"
          PRINT."  and died of "
          WOUNDED @
          IF   ."  your injuries"
          ELSE   ... SICKNESS
          ENDIF
          HEALTH OFF
          SORRY
;

: BANDITS
          PRINT."  Bandits Attacked!" HONK CR
          30 %CHANCE:
             PRINT."  You ran out of bullets--"
             PRINT."  They got lots of yer cash"
             50 RANDOM CASH DEBIT
             AMMO OFF
          ;CHANCE

           20 %CHANCE:
               PRINT." and... they took one of your oxen"
               1 OXEN# DEBIT
          ;CHANCE

          10 %CHANCE:
              WOUNDED ON
          ;CHANCE
;

: VERYSICK
          PRINT." Partner you is looking sickly."
          PRINT." The DOC says you got the " SICKNESS
          PRINT." STOP FOR MEDICAL ATTENTION"
          5 RANDOM DAYS CREDIT
          SEE-DOCTOR
          CR
          50 %CHANCE:
               PRINT." Hey you pulled through!"
               10 HEALTH CREDIT
          OTHERWISE
              18 %CHANCE:
                   PRINT." I got some bad news partner" ...
                   PRINT." You didn't make it. :-("
                   HEALTH OFF
                   ?DEAD
              ;CHANCE

              PRINT." You didn't make a full recovery"
              PRINT." but ya ain't dead yet!"
              2 HEALTH CREDIT
         ;CHANCE
 ;

 \ =========================================
 CHOICE:  ." wheel" ;
 CHOICE:  ." axle" ;
 CHOICE:  ." yoke" ;
 CHOICE:  ." whipple-tree" ;
 CHOICE:  ." seat" ;
 CASE: PARTS  5 CHOICES,   ;CASE

: PART    5 RANDOM PARTS  ;

: BUSTED-WAGON
          PRINT." Yer wagon gots a busted " PART
          PRINT." It's gonna take some time to fix 'er up!"
          ...
          PRINT." That'll cost ya "
          5 RANDOM 1+ DUP DOLLARS
          CASH DEBIT
          5 RANDOM MISC DEBIT
 ;

: SWAMPED
      CR
      PRINT." Wagon gets swamped fording a"
      PRINT." river. You lost some food"
      20 RANDOM 10 + FOOD DEBIT
      ...
      33 %CHANCE:
         PRINT." and some clothes"
         20 RANDOM  5 + CLOTHES DEBIT
      ;CHANCE
;

: FOG
     PRINT." Lost your way in a heavy fog"
     ...
     PRINT." You lost " 4 RANDOM 1+ DUP DAY CREDIT
     DUP .   ." days."
     2* FOOD DEBIT
;

: FIRE
     PRINT." There was a fire in your"
     PRINT." wagon. Food and supplies"
     PRINT." are damaged!"
     20 RANDOM 10 + FOOD DEBIT
     10 RANDOM 2 +  MISC DEBIT
;

: RAIN
  PRINT." Heavy rain" ...
  PRINT." Time & supplies were lost." ...
   3 RANDOM 1+  DAY CREDIT
   7 RANDOM    MISC DEBIT
  12 RANDOM 1+ FOOD DEBIT
;

: BAD-WATER
  PRINT." Bad water, You lost time"
  PRINT." looking for a clean spring."
  ...
  3 RANDOM 1+ DAY CREDIT
;
