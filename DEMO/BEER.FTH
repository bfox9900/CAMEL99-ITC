\ 99 bottles of beer.  Create a beer language and write the program

NEEDS CASE FROM DSK1.CASE

DECIMAL
: BOTTLES ( n -- )
        DUP
        CASE
         1 OF    ." One more bottle " DROP ENDOF
         0 OF    ." NO MORE bottles " DROP ENDOF
                 . ." bottles "    \ DEFAULT CASE
        ENDCASE ;

: ,   [CHAR] , EMIT  SPACE ( 100 MS) CR ;
: .   [CHAR] . EMIT  ( 300 MS)  CR CR CR ;

: HANGOVER    ." :-("  CR ;

: OF       ." of "   ;     : BEER     ." beer " ;
: ON       ." on "   ;     : THE      ." the "  ;
: WALL     ." wall" ;      : TAKE     ." take " ;
: ONE      ." one "  ;     : DOWN     ." down, " ;
: PASS     ." pass " ;     : IT       ." it "   ;
: AROUND   ." around" ;    

-1 CONSTANT -1

: POPONE    1 SWAP CR ;
: DRINK     POSTPONE DO ; IMMEDIATE
: ANOTHER   POSTPONE -1  POSTPONE +LOOP ; IMMEDIATE
: HOWMANY   S" I " EVALUATE ; IMMEDIATE
: ONELESS   S" I 1- " EVALUATE ; IMMEDIATE
: BINARY    2 BASE ! ; 

: BEERS ( n -- )
      POPONE
      DRINK
         HOWMANY BOTTLES OF BEER ON THE WALL ,
         HOWMANY BOTTLES OF BEER ,
         TAKE ONE DOWN PASS IT AROUND ,
         ONELESS BOTTLES OF BEER ON THE WALL .
      ANOTHER
      HANGOVER ;

CR .( Usage:  99 BEERS)

