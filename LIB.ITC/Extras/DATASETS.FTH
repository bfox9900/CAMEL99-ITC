\ logo style data lists and FOREACH                  Sep 2022 Brian Fox

INCLUDE DSK1.TOOLS
HERE
INCLUDE DSK1.COMPARE

DECIMAL
\  ** EXPERIMENTAL DATA STRUCTURE:  COUNTED DATA ARRAYS IN DICTIONARY **
2 CELLS CONSTANT 2CELLS
: 2CELLS+  2CELLS + ;

\ end a set. Return the address of the data and length in bytes
: ]]   ( here -- addr len )
  DUP
  HERE OVER - 2CELLS -  DUP>R  OVER 2!
  2CELLS+
  R>
  EXIT   \ EXIT forces evaluation to stop at ]]
;

: PARSE-DATA ( addr -- addr' len)
         BEGIN
           BL PARSE-WORD
           2DUP S" ]]" COMPARE WHILE ( <>"]]")
            DUP WHILE ( len<>0)
           EVALUATE  ,  \ evaluate can handle named data also
         REPEAT
         THEN
         2DROP ;

\ create a data-set with 2 cell header
: [[ ( -- )  HERE  0 , 0 ,  PARSE-DATA ]] ;

\ name a data set. Return the data address and length in bytes
: SET: ( addr len -- )
  CREATE
  ,  ,
  DOES> 2@  ;

VARIABLE ACTION
: ALTER ( addr size xt-- ) \ changes DATA set itself
  ACTION !  BOUNDS DO  I ( addr) ACTION PERFORM  2 +LOOP ;

: FOREACH ( addr size xt-- )
  ACTION !  BOUNDS DO  I @ ( data) ACTION PERFORM  2 +LOOP ;

: MAP ( <word> ) \ state smart so it can be used in definitions
   '           ( look up the word )
   STATE @ IF  ( compiling action)
     POSTPONE LITERAL
     POSTPONE FOREACH
     EXIT
   THEN ( interpreting action )
   FOREACH ; IMMEDIATE

\ literal is state smart so these can be used in definitions
: SIZEOF ( -- n)  '  >BODY  @      POSTPONE LITERAL ; IMMEDIATE
: #ITEMS ( -- N)  '  >BODY  @  2/  POSTPONE LITERAL ; IMMEDIATE
HERE SWAP - DECIMAL .

\ DATA SETS test code ...

\ DECIMAL
\ [[ 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 ]] SET: EVENS
\ [[ 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 ]] SET: ODDS

\ EVENS ' .  FOREACH
\ ODDS  ' .  FOREACH

\ ODDS 2DUP ' 1+! ALTER  MAP .
\ ODDS 2DUP ' 1-! ALTER  MAP .

\: TEST   EVENS ['] . FOREACH  ;  \ Compiling test
\ TEST
