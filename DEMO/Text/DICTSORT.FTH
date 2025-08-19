\ sort dictionary words experiment  Update for V2.68 Jul 2021 Brian Fox

\ This demo uses some advanced features of CAMEL99 forth
\ 1. Dynamically allocating memory in the HEAP ( MALLOC )
\ 2. Vectored execution of the comparison operator
\ 3. Combsort routine which runs about 10X faster than Bubble sort
\ 4. Measuring elapsed time using screen timeout timer value
\ 5. Text macros to improve speed of time critical routines
\ 6. Sorts an array of pointers. The actual strings do not move

\ usage:  ASCENDING SORTWORDS  -or-  DESCENDING SORTWORDS

INCLUDE DSK1.TOOLS
INCLUDE DSK1.VALUES
INCLUDE DSK1.DEFER
INCLUDE DSK1.ELAPSE
INCLUDE DSK1.MALLOC
INCLUDE DSK1.COMPARE

HEX
\ variables uses by COMBSORT
VARIABLE SFLAG
VARIABLE ITEMS
0 VALUE GAP

0 VALUE ^DATA   \ a data array pointer

: ]DATA    ( n -- [n]data ) CELLS ^DATA + ; \ index into ^DATA

\ load the name field address (NFA) of all words, into ^DATA
: LOAD.NAMES ( -- addr n )
             CR ." Loading names... "
             ITEMS OFF            \ reset ITEMS variable
             LATEST @             ( -- nfa )
             0 >R                 \ put a loop index on return stack
             BEGIN
                DUP R@ ]DATA !    ( -- nfa )
                R> 1+ >R          \ increment loop counter
                NFA>LFA @         \ goto link field, fetch next NFA
                DUP 0=            \ is it zero?
             UNTIL
             R> DUP .  ." words"
             ITEMS !  ;           \ store # items for sort to use

\ compare strings uses S=
: COMPARE$ ( $1 $2 -- flag)  1+ SWAP COUNT S= ;
: >$       ( $1 $2 -- flag)  COMPARE$ 0> ;  \ $1 > $2
: <$       ( $1 $2 -- flag)  COMPARE$ 0< ;  \ $1 < $2


DEFER PRECEDE   \ this will be the string comparison operator
: ASCENDING  ( -- )  ['] >$ IS PRECEDE ;
: DESCENDING ( -- )  ['] <$ IS PRECEDE ;

ASCENDING   \ default sort direction

: /1.3  ( n -- n/1.35 ) \ 100/135 is fastest GAP  ratio for this sort
        S" 100 135 */ 1 MAX " EVALUATE ;  IMMEDIATE

: XCHG  ( 'data[1] 'data[2] $1 $2 -- )
        S" SWAP ROT !  SWAP ! "  EVALUATE ; IMMEDIATE

\ display the words in sorted order
: .WORDS   ( -- )
            CR
            ITEMS @ 0
            DO
               I ]DATA @ .ID SPACE
               ?BREAK
            LOOP ;
HEX
: SORTWORDS ( -- )
    200 CELLS MALLOC  TO ^DATA     \ allocate space for 512 words
    LOAD.NAMES
    CR ." Sorting "
    ITEMS @ TO GAP                   \ init combort gap
    BEGIN
       GAP  /1.3  TO GAP             \ compute new gap width
       SFLAG ON                      \ sort flag set to TRUE
       ITEMS @  GAP -  0             \ setup loop
       DO
           I  GAP + ]DATA  I ]DATA   ( -- data[gap] data[i]  )
           OVER @ OVER @             ( -- data[gap] data[i] nfa1 nfa2)
           2DUP                      ( -- data[gap] data[i] nfa1 nfa2 nfa1 nfa2)
           PRECEDE IF                \ compare string at nfa1,nfa2
               XCHG                  \ xchg if wrong order
               SFLAG OFF             \ we are not done yet
           ELSE
               2DROP 2DROP           \ no exchange so collapse the stack info
           THEN
       LOOP
       [CHAR] . EMIT                 \ show progress on screen
       SFLAG @  GAP 1 = AND          \ test for completion
    UNTIL
    DROP 
    .WORDS                           \ print the sorted array
    200 CELLS MFREE                  \ release memory
    0 TO ^DATA                       \ clear the data pointer
    CR  ;
