\ GLOSSARY GENERATOR

\ This demo uses some advanced features of CAMEL99 forth
\ 1. Dynamically allocating memory in the HEAP ( MALLOC )
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
NEEDS MORE       FROM DSK1.MORE

HEX
\ variables uses by COMBSORT
VARIABLE SFLAG
VARIABLE ITEMS
0 VALUE GAP

0 VALUE ^DATA   \ a data array pointer

: ]DATA    ( n -- ^data[n] ) CELLS ^DATA + ; \ index into ^DATA

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

\ compare strings uses S= (Camel Forth word)
: COMPARE$ ( $1 $2 -- flag)  1+ SWAP COUNT S= ;
: >$       ( $1 $2 -- flag)  COMPARE$ 0> ;  \ $1 > $2
: <$       ( $1 $2 -- flag)  COMPARE$ 0< ;  \ $1 < $2


DEFER PRECEDE   \ vectored string comparison operator
: ASCENDING  ( -- )  ['] <$ IS PRECEDE ;
: DESCENDING ( -- )  ['] >$ IS PRECEDE ;

ASCENDING   \ default sort direction

: /1.3  ( n -- n/1.35 ) \ 100/135 is fastest GAP  ratio for this sort
        S" 100 135 */ 1 MAX " EVALUATE ;  IMMEDIATE

: XCHG  ( 'data[1] 'data[2] $1 $2 -- )
        S" SWAP ROT !  SWAP ! "  EVALUATE ; IMMEDIATE

HEX
: SORTWORDS ( -- )
    ^DATA 0= ABORT" No buffer allocated" 
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
    CR  ;


\ display the words in sorted order
: .WORDS   ( -- )
            CR
            ITEMS @ 0
            DO
               I ]DATA @ .ID SPACE
               ?BREAK
            LOOP ;

: ID$     ( NFAaddr -- caddr len) COUNT 1F AND  ;

: +PLACE  ( adr n adr -- )   2DUP 2>R  COUNT +  SWAP MOVE 2R> C+! ;

DECIMAL

CREATE OUT$  82 ALLOT ;

0 VALUE #1

: PADDED ( addr$  n -- )  SWAP C!  ;
: BLANKS    BL FILL ;

\ write the words in sorted order
: WRITE-WORDS   ( -- )
            CR
            ITEMS @ 0
            DO
               OUT$ 80 BLANKS
               I ]DATA @ ID$ OUT$ PLACE
                OUT$ 20 PADDED
                S" ( -- )"  OUT$ +PLACE
                OUT$ COUNT  #1  WRITE-LINE ?FILERR
               ?BREAK
            LOOP ;

HEX
: GLOSSARY ( path$ len -- )
            TICKER OFF
            DV80 W/O OPEN-FILE ?FILERR TO #1
            1000 MALLOC TO ^DATA     \ allocate 4k space for the word names
            ASCENDING SORTWORDS
            CR ." Writing file..."
            WRITE-WORDS
            #1 CLOSE-FILE ?FILERR          
            1000 MFREE               \ release the mmeory (low ram)
            0 TO ^DATA
            CR ." Complete"
            .ELAPSED
;

PAGE
\ A little systems work in Forth
S" DSK3.GLOSS99" GLOSSARY

MORE DSK3.GLOSS99

