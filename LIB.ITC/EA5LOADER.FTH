.( EA3 object file loader...) \ based on ideas from TurboForth

NEEDS +TO  FROM DSK1.VALUES
NEEDS CASE FROM DSK1.CASE

\ heap memory management 
: HALLOT ( n -- )  H +! ;
: H!   ( addr -- ) H ! ;
: H,   ( n -- )  H ! 2 HALLOT ;

: CHOP   ( addr len n --  addr' len' addr len )
          >R                  \ Rpush n
          2DUP DROP R@        \ dup $, do left$
          2SWAP               \ put original $ on top
          R> /STRING          \ cut remainder string
          2SWAP               \ put partial string on top
;

: CONVERT# ( addr len -- n )  NUMBER? ABORT" Bad number" ;
: DO-CODE  ( addr len -- addr' len')  1 /STRING   4 CHOP CONVERT#  H, ;
: DO-ADDR  ( addr len -- addr' len')  1 /STRING   4 CHOP CONVERT#  H! ;

: DoDef ( addr len -- )
        CONVERT#  >R  ( R: -- addr)
        6 CHOP -TRAILING  ( -- addr len ) \ name of DEF
        HEADER  COMPILE DOCON  R> ,       \ make a constant in Forth
;

: ParseOBJ ( add len -- )
      BEGIN
        DUP
      WHILE
        OVER C@
        CASE
          [CHAR] 9 OF DO-ADDR     ENDOF
          [CHAR] B OF DO-DCODE    ENDOF
          [CHAR] 7 OF DROP 0      ENDOF
          [CHAR] 6 OF DoDef       ENDOF
          [CHAR] : OF DROP 0      ENDOF
        ENDCASE
        1 /STRING
     REPEAT ;

: ?PATH    ( addr len -- )   [CHAR] . SCAN NIP 0= ABORT" Path expected" ;

: EA3LOAD ( "DSKx.FILE" -- )
      2000 H !
      ?PATH DV80  R/O OPEN-FILE  ABORT" Can't open object file"
      >R
      BEGIN
         PAD DUP R> READ-LINE NIP
      WHILE
         ParseOBJ
      REPEAT
      R> CLOSE-FILE
      2DROP
;

.( Usage: S" DSKx.FILENAME" EA3LOAD)
