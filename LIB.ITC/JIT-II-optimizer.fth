\ jit-optimizer.fth  for jit CODE jAN 2024

\
\ After messing around with trying to detect code patterns
\ at compile time, I realized it is simpler to do a 2nd scan.
\ We search for the bad patterns in the code and
\ remove/replace the strings as required.
\
NEEDS DUMP FROM DSK1.TOOLS
NEEDS SEARCH FROM DSK1.SEARCH

: SCANW (  adr len u -- adr' len')
        >R     \ remember u
        BEGIN
          DUP
        WHILE ( len<>0)
          OVER @ R@ <>
        WHILE ( R@ <> u)
          2 /STRING        \ advance to next cell address
        REPEAT
        THEN
        R> DROP   \ 32 bytes
;

HEX
\ create the problem instructions as byte-counted binary strings
CREATE DROP/DUP$  06 C,  C1 C, 36 C, 06 C, 46 C, C5 C, 84 C, 0 C,  ALIGN

: "DROP/DUP" ( -- addr len) DROP/DUP$ COUNT ;
: "NEXT"                   NEXT$ COUNT ;

: CODE-LENGTH ( xt -- addr' len )
  >BODY DUP 200  'NEXT' SCANW DROP  OVER -  ;

\ remove bytes from the data pair (addr len)
\ returning the rest of the string
: REMOVE ( addr len bytes -- addr' len' )
    >R
    OVER SWAP        ( -- srcaddr srcaddr len )
    R> /STRING       ( -- srcaddr dest len' )
    >R SWAP R>       ( -- dest src len' )
    CMOVE
;

: REMOVE1   CODE-LENGTH "DROP/DUP" SEARCH  3 CELLS REMOVE ;

VARIABLE #DUPS
VARIABLE #BYTESWAPS

: COUNT-POP/PUSH
    #DUPS OFF
    CODE-LENGTH
    BEGIN
        "DROP/DUP" SEARCH ( addr len ?)
    WHILE
        3 CELLS /STRING
        #DUPS 1+!
    REPEAT
    2DROP
    CR #DUPS @ .  ." pop/push problems"
;



: STACK-OPT ( XT -- )
    #DUPS OFF
    CODE-LENGTH
    BEGIN
        "DROP/DUP" SEARCH ( addr len ?)
    WHILE
        3 CELLS REMOVE    \ remove the code
        #DUPS 1+!
    REPEAT
    2DROP
    CR #DUPS @ DUP . ." POP/PUSH ops remove"
    CR CELLS . ." bytes removes"
;
