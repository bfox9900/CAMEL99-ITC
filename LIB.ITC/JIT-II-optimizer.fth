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
\ create the problem instruction machine code
CREATE DUP$  C136 , 0646 , C584 ,

: DROP/DUP ( -- addr n)  DUP$  6 ;

: CODE-BLOCK ( xt -- addr len ) >BODY DUP   100  'NEXT' SCANW DROP  OVER -  ;

: COMPUTE-LENGTH ( adr len bytes)
    >R  2DUP R> /STRING
    ROT DROP
    ROT SWAP
;

\ remove bytes from the data pair (addr len)
\ returning the rest of the string
: REMOVE ( addr len bytes -- addr' len' )
     CMOVE
;


VARIABLE #DUPS
VARIABLE #BYTESWAPS

: TOSOPT ( addr size -- )
    #DUPS OFF
    BEGIN
        DROP/DUP SEARCH ( addr len ?)
    WHILE
        3 CELLS REMOVE    \ remove the code
        #DUPS 1+!
    REPEAT
    2DROP
;
