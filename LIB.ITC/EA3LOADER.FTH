.( EA3 object file loader...) \ based on ideas from TurboForth

NEEDS +TO  FROM DSK1.VALUES
NEEDS CASE FROM DSK1.CASE
NEED -TRAILING FROM DSK1.TRAILING

MARKER /LOADER

0 VALUE #1  \ a file handle

\ heap memory management
: HEAP! ( addr -- ) H ! ;  \ set heap pointer
: HEAP   ( -- addr) H @ ;  \ current heap pointer
: HALLOT ( n -- )  H +! ;  \ move heap pointer
: HEAP,  ( n -- )  H ! 2 HALLOT ; \ compile n into heap

\ string utilities
: CHOP   ( addr len n --  addr' len' addr len )
          >R                  \ Rpush n
          2DUP DROP R@        \ dup $, do left$
          2SWAP               \ put original $ on top
          R> /STRING          \ cut remainder string
          2SWAP               \ put chopped string (output) on top
;

: /TAG     ( addr len -- addr' len') 1 /STRING ; \ cut tag off string
: READ-NUM ( addr len -- n ) 4 CHOP NUMBER? ABORT" Bad number" ;

\ tag interpreters
VARIABLE PROGLENGTH
CREATE PROGNAME 10 ALLOT

: PROG-ID  ( addr len -- addr len)
         /TAG
         READ-NUM PROGLENGTH !
         8 CHOP  PROGNAME PLACE

: DO-CODE  ( addr len -- addr' len')  /TAG    ;
: DO-ADDR  ( addr len -- addr' len')  /TAG  4 CHOP CONVERT#  H! ;
: DO-LAST  ( addr len -- addr 0)
            /TAG  40 CHOP -TRAILING CR TYPE  DROP 0 ;

: DO-DEF ( addr len -- )
        CONVERT#  >R  ( R: -- addr)
        6 CHOP -TRAILING  ( -- addr len ) \ name of DEF
        HEADER  COMPILE DOCON  R> ,       \ make a constant in Forth
;

: ParseLine ( add len -- )
      BEGIN
        DUP
      WHILE
        OVER C@
        CASE ( loader tag must be interpreted)
\                                      data   Field1 Field2
\                                     ------  ------ ------
          [CHAR] 0 OF PROG-ID        ENDOF  \ length,text
          [CHAR] 1 OF ENTRY-POINT    ENDOF  \ number
          [CHAR] 2 OF RELOCATE       ENDOF  \ number,text
          [CHAR] 3 OF CHAIN-RELOC    ENDOF  \ number,text
          [CHAR] 4 OF CHAIN-AORG     ENDOF  \ number,text
          [CHAR] 5 OF EXTERN-ADDR    ENDOF  \ number,text
          [CHAR] 6 OF DO-DEF         ENDOF  \ number
          [CHAR] 7 OF DO-CHECKSUM    ENDOF  \ number
          [CHAR] 8 OF IGNORE         ENDOF  \ number
          [CHAR] 9 OF ABSOLUTE-ADDR  ENDOF  \ set address
          [CHAR] A OF RELOC-ADDR     ENDOF  \ number
          [CHAR] B OF ABSOLUTE-VALUE ENDOF  \ place code in memory
          [CHAR] C OF RELOC-ADDR     ENDOF  \ number
          [CHAR] F OF END-RECORD     ENDOF  \ text to throw away
          [CHAR] : OF DO-LAST        ENDOF  \ Text of Assembler version
        ENDCASE
        1 /STRING
     REPEAT ;

: ?PATH    ( addr len -- )   [CHAR] . SCAN NIP 0= ABORT" Path expected" ;

: EA3LOAD ( "DSKx.FILE" -- )
      2000 H !
      ?PATH DV80  R/O OPEN-FILE ?FILERR  TO #1
      BEGIN
         #1 EOF
      0= WHILE
         PAD DUP #1 READ-LINE ( pad len ? ior) ?FILERR  DROP
       ( pad len ) ParseLine
      REPEAT
      #1 CLOSE-FILE
      2DROP
;

.( Usage: S" DSKx.FILENAME" EA3LOAD)
