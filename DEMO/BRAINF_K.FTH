\ brainfuk.fth in ANS Forth based on work by Mark Wills
\ Thanks to Willsy on Atariage.com who wrote this in TurboForth
\  A M A Z I N G  !!!!!!!!!!!
\ Slightly Forthfied 2026 BFox
HEX
CREATE MEMORY   2000 ALLOT
VARIABLE BFP   \ the Brain F__k pointer

: RESET ( -- ) MEMORY DUP 2000 0 FILL  BFP ! ;
: THERE ( -- addr) BFP @ ;
: PEEK  ( -- ) THERE C@ ;
: POKE  ( -- ) THERE C! ;
: >     ( -- )  1 BFP +! ;               \ increment the BFP
: <     ( -- ) -1 BFP +! ;               \ decrement the BFP
: +     ( -- ) PEEK 1+ POKE ;           \ increment the byte at the BFP
: -     ( -- ) PEEK 1- POKE ;           \ decrement the byte at the BFP
: .     ( -- ) PEEK EMIT ;              \ output the byte at the BFP
: ,     ( -- ) KEY 7F AND POKE ;        \ TI-99 keys need a mask

\ jump forward past the matching ] if the byte at the BFP is zero
: [     ( -- ) POSTPONE BEGIN  POSTPONE PEEK  POSTPONE WHILE ; IMMEDIATE

\ jump backward to the matching [ unless the byte at the BFP is zero
: ]     ( -- ) POSTPONE REPEAT ; IMMEDIATE

: RUN ( hello world in BrainF__k )
    RESET
    + + + + + + + + [ > + + + + [ > + + > + + + > + + + > + < < < < - ] > +
    > + > - > > + [ < ] < - ] > > . > - - - . + + + + + + + . . + + + . > >
    . < - . < . + + + . - - - - - - . - - - - - - - - . > > + . > + + . ;

DECIMAL
