\ CARDUTIL.FTH lets you search for and examine cards in your system
NEEDS .S FROM DSK1.TOOLS
NEEDS COMPARE FROM DSK1.COMPARE 
NEEDS MARKER FROM DSK1.MARKER 

MARKER /CARDS

HEX
\ *set the CRU address in 'R12 before using these words*
CODE 0SBO  ( -- ) 1D00 ,  NEXT, ENDCODE
CODE 0SBZ  ( -- ) 1E00 ,  NEXT, ENDCODE

4000 CONSTANT 'ID  \ address of 'AA' byte
00AA CONSTANT 'AA' \ id byte for TI-99 cards

DECIMAL
  24 USER 'R12    \ address of R12 in any Camel99 Forth task

: ?CARD  ( c -- ) 'ID C@ <> ABORT" Bad card address" ;  \ test ID byte

: CARDON ( CRUaddr -- ) 'R12 ! 0SBO  ;

HEX
: ALLCARDS ( -- )
          0F00                   \ dummy CRU address
          BEGIN
            0100 +               \ next card address
            DUP CARDON
            'ID C@ 'AA' =        \ test if card present
            IF
               CR ." Card found at:>" DUP U.
            THEN
            0SBZ                 \ turn the card off
            DUP 2000 =           \ last address ?
          UNTIL
          DROP ;

: DSRLIST ( CARDaddr -- )
          CARDON 'AA' ?CARD      \ test ID byte
          CR ." DSR    Code Address
          CR ." -----  ------------
          'ID 08 +                \ fetch pointer to DSR list
          BEGIN
             @                   \ fetch list item
             DUP                 \ test it for zero (end of list)
          WHILE
             DUP 4 + COUNT       \ get the counted string as addr,len
             CR TYPE OUT @ ALIGNED OUT !
             DUP 4 + COUNT + ALIGNED CELL+ @ 4 SPACES U. \ Print name, code address
          REPEAT
          0SBZ
          DROP ;

: SUBLIST ( CARDaddr -- )
          CARDON 'AA' ?CARD      \ test ID byte
          'ID 0A +               \ fetch pointer to DSR list
          BEGIN
             @                   \ fetch list item
             DUP                 \ test it for zero (end of list)
          WHILE
             DUP 4 +             \ get address of the id field
             DUP C@ 1 =
             IF
                 @ . ." , "      \ it's a number
             ELSE
                 COUNT TYPE      \ convert to addr,len & type with comma
             THEN . ." , "
          REPEAT
          0SBZ
          DROP ;


: /CUT   ( caddr len char -- caddr len') >R 2DUP R> SCAN NIP - ;

CREATE DEV$ 8 ALLOT

: DSRFIND ( caddr len CARDaddr -- 0 | length)
          CARDON  'AA' ?CARD
          [CHAR] . /CUT DEV$ PLACE
          FALSE                \ false flag is default result
          'ID 8 +              \ rpush pointer to DSR list
          BEGIN
             @ DUP             \ fetch next list item
          WHILE
             DUP 4 +
             COUNT    \ test: 2DUP TYPE  SPACE
             DEV$ COUNT ROT MAX S=
             0= IF
                DROP DROP
                DEV$ C@        \ return length of device string
                EXIT
             THEN
          REPEAT
          DROP ;

