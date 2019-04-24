\ camel99 ITC version locals implementation per Forth 2012

\ locals will be 2 CELL structures work like variables
\ meaning they include runtime code to place their address on the stack

DECIMAL
VARIABLE LCP                       \ locals data stack pointer
VARIABLE LASTL                     \ last local in wordlist

CREATE LC0    10 CELLS ALLOT       \ locals data stack space for 8 locals+1 cell

CREATE LOCALS 256 ALLOT            \ local wordlist space

\ heap # compilers
: HEAP ( -- addr) H @ ; 
: H,   ( n -- )  2 MALLOC !  ;
: HC,  ( c -- )  1 MALLOC C! ;

: (LFIND)
         LASTL @ (FIND)

\ uses the CAMEL Forth header/linked list so local names can be searched by (FIND)
: (LOCAL)  ( adr len -- )           \ create a named local variable in the heap
            LASTL @ ,               \ record the LASTL NFA as the LINK in this new word
            0 HC,                   \ create the immediate field  1 BYTE
            HEAP LASTL !            \ update the LATEST variable to this new definition's NFA
            CHAR+ S,                \ compile the string label
            
            0 LPUSH

: LOCAL ( "NAME" -- )  BL WORD COUNT (LOCAL) ;

: {HELPER ( -- FINAL-OFFSET )
    >IN @
    BL WORD COUNT
    2DUP S" --" COMPARE 0= 
    IF
	2DROP [CHAR] } PARSE 2DROP TRUE
    ELSE
	S" }" COMPARE 0=
    THEN
    IF
	DROP >IN @
    ELSE
	RECURSE
	SWAP >IN ! LOCAL
    THEN ;

: { ( -- )
    {HELPER >IN ! 0 0 (LOCAL) ; IMMEDIATE

\ : TEST-SWAP { A B -- B A } ." XXX"
\     B A ;

\ 1 2 test-swap . . .s cr
: INIT-LOCALS 
             LC0 LCP !
             LOCALS