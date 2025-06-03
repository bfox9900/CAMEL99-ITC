\ GLOSSARY GENERATOR  Updated to use current libraries  7Jul2022  Brian Fox

\ This demo uses some advanced features of CAMEL99 forth
\ 1. Create a very fast "table" array in low RAM
\ 2. Vectored execution of the comparison operator
\ 3. Combsort routine which runs about 10X faster than Bubble sort
\ 4. Measuring elapsed time using screen timeout timer value
\ 5. Text macros to improve speed of time critical routines
\ 6. Sorts an array of pointers. The actual strings do not move

\ usage:  ASCENDING SORTWORDS  -or-  DESCENDING SORTWORDS

NEEDS .ID        FROM DSK1.TOOLS
NEEDS TO         FROM DSK1.VALUES
NEEDS IS         FROM DSK1.DEFER
NEEDS ELAPSE     FROM DSK1.ELAPSE
NEEDS WRITE-LINE FROM DSK1.ANSFILES
NEEDS COMPARE    FROM DSK1.COMPARE
NEEDS TABLE2:    FROM DSK1.TABLES

HEX
2000 TABLE2: ]DATA  ( n -- [n]data ) \ low RAM array

VARIABLE ITEMS
\ load the name field address (NFA) of all words, into ^DATA
: LOAD.NAMES ( -- addr cells )
            0 ]DATA 2000 0 FILL
             CR ." Loading names... "
             LATEST @             ( -- nfa )
             0 >R                 \ put a loop index on return stack
             BEGIN
                DUP R@ ]DATA !    ( -- nfa )
                R> 1+ >R          \ increment loop counter
                NFA>LFA @         \ goto link field, fetch next NFA
                DUP 0=            \ is it zero?
             UNTIL
             0 ]DATA  R> DUP ITEMS ! DUP .  ." words"
;

\ compare strings uses S=
: COMPARE$ ( $1 $2 -- flag)  COUNT ROT COUNT COMPARE ;
: >$       ( $1 $2 -- flag)  COMPARE$ 0> ;  \ $1 > $2
: <$       ( $1 $2 -- flag)  COMPARE$ 0< ;  \ $1 < $2


DEFER PRECEDE   \ this will be the string comparison operator
: ASCENDING  ( -- )  ['] <$ IS PRECEDE ;
: DESCENDING ( -- )  ['] >$ IS PRECEDE ;

 ASCENDING   \ default sort direction


HEX
\ gratuitous variables for clarity
0 VALUE  GAP
VARIABLE SORTED

DECIMAL
\ divide by 1.35 using Forth's scaling operator
\ found this ratio to be the fastest
: 1.35/  ( n -- n' ) 100 135 */ ;

: XCHG  ( addr1 addr2 -- ) 2DUP @ SWAP @  ROT ! SWAP ! ;

: COMBSORT ( addr n -- )
    DUP>R  TO GAP                    \ save n on Rstack and in GAP
    BEGIN
      GAP 1.35/  TO GAP              \ re-compute the gap
      SORTED ON
      R@ ( -- n) GAP -  0           \ n-gap is loop limit
      DO ( -- addr )
         DUP I CELLS +  DUP GAP CELLS +  ( -- addr1 addr2 )
         OVER @ OVER @ PRECEDE       \ compare the contents of cells, which are strings
         IF
            XCHG                     \ Exchange the data in the cells
            SORTED OFF               \ flag we are not sorted
         ELSE
           2DROP
         THEN
      LOOP
      SORTED @  GAP 0=  AND          \ test for complete
   UNTIL
   R> 2DROP
;

DECIMAL
: SORTWORDS ( -- ) LOAD.NAMES  CR ." Sorting "  COMBSORT ;

\ display the words in sorted order
: .WORDS   ( -- )
            CR
            ITEMS @ 0
            DO
               I ]DATA @ .ID SPACE
               ?BREAK
               KEY? IF KEY DROP THEN
            LOOP ;

HEX
: ID$     ( NFAaddr -- caddr len) COUNT 1F AND  ;

: +PLACE  ( adr n adr -- )   2DUP 2>R  COUNT +  SWAP MOVE 2R> C+! ;

DECIMAL

CREATE OUT$  82 ALLOT

0 VALUE #1

: PADDED ( addr$  n -- )  SWAP C!  ;
: BLANK    BL FILL ;

\ write the words in sorted order
: WRITE-WORDS   ( -- )
            CR
            ITEMS @ 0
            DO
               OUT$ 80 BLANK
               I ]DATA @ ID$ OUT$ PLACE
                OUT$ 20 PADDED
                S" ( -- )"  OUT$ +PLACE
                OUT$ COUNT  #1 WRITE-LINE ?FILERR
               ?BREAK
            LOOP ;

DECIMAL
: GLOSSARY ( path$ len -- )
            DV80 W/O OPEN-FILE ?FILERR TO #1
            SORTWORDS
            CR ." Writing file..."
            WRITE-WORDS
            #1 CLOSE-FILE ?FILERR
            0 TO ^DATA
            CR ." Complete"
;
