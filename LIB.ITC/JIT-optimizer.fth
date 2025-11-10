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
\ create the problem instructions as byte-counted binary strings
CREATE DROP/DUP$ ALIGN  06 C,  C1 C, 36 C, 06 C, 46 C, C5 C, 84 C,  0 C, ALIGN

: "DROP/DUP" ( -- addr len) DROP/DUP$ COUNT ;

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

: TOSOPT ( addr size -- )
    #DUPS OFF
    BEGIN
        "DROP/DUP" SEARCH ( addr len ?)
    IF
    WHILE
        2DUP 3 CELLS DUP>R REMOVE    \ remove the code
        R> NEGATE H +!             \ update Target data pointer
        #DUPS 1+!
    REPEAT
   THEN
    2DROP
;
