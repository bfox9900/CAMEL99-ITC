\ jit-optimizer.fth  for jit CODE jAN 2024

\
\ After messing around with trying to detect code patterns
\ at compile time, I realized it is simpler to do a 2nd scan.
\ We search for the bad patterns in the code and
\ remove/replace the strings as required.
\
NEEDS DUMP FROM DSK1.TOOLS
INCLUDE DSK1.SEARCH

: LEN ( addr -- c) C@ ; \ for clarity only

HEX
CREATE DROP/DUP$  C136 , 0646 , C584 ,
CREATE DUP/DROP   0646 , C584 , C136 ,

CREATE <NEXT>  NEXT,


: "DROP/DUP" ( -- addr len) DROP/DUP$ 6 ;
: "DUP/DROP"  DUP/DROP  6 ;
: "NEXT"      <NEXT> 2 ;

\ remove bytes from the data pair (addr len)
\ returning the rest of the string
: REMOVE ( addr len bytes -- addr' len' )
    >R
    OVER SWAP        ( -- srcaddr srcaddr len )
    R> /STRING       ( -- srcaddr dest len' )
    >R SWAP R>       ( -- dest src len' )
    MOVE
;

VARIABLE #DUPS
VARIABLE #BYTESWAPS

: CODELENGTH  ( CODEaddr -- addr len ? )
    DUP 200  "NEXT" SEARCH NIP
    >R
    OVER -
    R>

;

: TOSOPT ( addr size -- )
    #DUPS OFF
    BEGIN
        "DUP/DROP" SEARCH ( addr len ?)
    IF
    WHILE
        2DUP 3 CELLS DUP>R REMOVE    \ remove the code
        R> NEGATE H +!             \ update Target data pointer
        #DUPS 1+!
    REPEAT
   THEN
    2DROP
;

' DO-PRIME >BODY  CODELENGTH
