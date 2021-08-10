CR .( EA3 object file loader Aug 10 2021 Fox)

NEEDS WORDLIST FROM DSK1.WORDLISTS

VOCABULARY DEFS

ONLY FORTH DEFINITIONS
\ NEEDS .S        FROM DSK1.TOOLS
NEEDS +TO       FROM DSK1.VALUES
NEEDS CASE      FROM DSK1.CASE
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS READ-FILE FROM DSK1.ANSFILES
NEEDS S=        FROM DSK1.COMPARE
NEEDS ELAPSE    FROM DSK1.ELAPSE

ONLY FORTH DEFINITIONS
DECIMAL
0 VALUE #1  \ a file handle

HEX
 2000 CONSTANT $2000
$2000 VALUE BASE-MEM  \ where we load OBJECT files

: ?BREAK  ( -- ) ?TERMINAL ABORT" *BREAK*" ;
: SPACEBAR ( -- ) KEY? BL = IF  KEY DROP  THEN ;

\ add words so we don't need to include tools
HEX
: .ID     ( NFAaddr --) COUNT 1F AND TYPE ;
DECIMAL
.( ..)
: WORDS   ( -- )
           0 >R        ( word counter on stack)
           CONTEXT @ DUP CR .WID CR
           @
           BEGIN DUP
           WHILE
              ?BREAK  SPACEBAR
              DUP ( -- nfa) .ID SPACE
              R> 1+ >R
              NFA>LFA @
           REPEAT
           DROP
           CR R>
           BASE @ >R
           DECIMAL . SPACE ." words"
           R> BASE ! ;

\ heap memory management
: HEAP! ( addr -- ) H ! ;  \ set heap pointer
: HEAP   ( -- addr) H @ ;  \ current heap pointer

HEX
: HALLOT ( n -- )  H +! ;  \ move heap pointer
: HEAP,  ( n -- )  HEAP ! 2 HALLOT ; \ compile n into heap

HEX
: NEW.
          $2000 HEAP!
          HEAP $2000 FF FILL  \ erase low ram
          HEAP TO BASE-MEM
          ['] DEFS  >BODY OFF  ;         \ remove all DEFS words

\ string utilities
: CHOP   ( addr len n --  addr' len' addr2 len2 )
          >R                  \ Rpush n
          OVER R@             \ dup $, do left$
          2SWAP               \ put original $ on top
          R> 1- /STRING       \ cut remainder string, leave tag at front
          2SWAP               \ put chopped string (output) on top
;

: /TAG     ( addr len -- addr' len') 1 /STRING ; \ cut tag character

: PARSE# ( addr len -- n )
        BASE @ >R
        HEX  /TAG  4 CHOP NUMBER? ABORT" Bad number"
        R> BASE ! ;

: GETLABEL  ( addr len -- addr' len' label len)
        /TAG 6 CHOP  -TRAILING ;

: DODEF ( addr len n -- )
        >R         ( -- addr' len') ( r: -- ref_addr)
        GETLABEL ( addr' len'  label len)
        DEFS DEFINITIONS
        HEADER,  COMPILE DOCON  R>   ,  \ make a Forth Constant
        FORTH DEFINITIONS ;

VARIABLE PROGLENGTH
CREATE PROGNAME  10 ALLOT

: PROG-ID  ( addr len -- addr len)
          PARSE# PROGLENGTH !
          8 CHOP  PROGNAME PLACE ;

: .TOOLVER  ( addr len -- addr 0)
          /TAG  40 CHOP -TRAILING CR TYPE  DROP 0 ;

: ?TAG    CR ." Unknown TAG -> "  EMIT ABORT ;

\ See E/A manual page 309 for meanings of object file tags.
: ParseLine ( add len -- )
      BEGIN
        DUP ( len<>0)
      WHILE
        OVER C@ ( tag)
        CASE
          [CHAR] 0 OF  PROG-ID        ENDOF

          [CHAR] 1 OF  [CHAR] 1 ?TAG  ENDOF
          [CHAR] 2 OF  [CHAR] 2 ?TAG  ENDOF

          [CHAR] 3 OF  PARSE# BASE-MEM + ( ref-address) >R
                       GETLABEL DEFS EVALUATE ( def-address)
                       R> !           ENDOF

          [CHAR] 4 OF  PARSE# ( ref-address) >R
                       GETLABEL DEFS EVALUATE ( def-address)
                       R> !           ENDOF

          [CHAR] 5 OF  PARSE# BASE-MEM + DODEF  ENDOF
          [CHAR] 6 OF  PARSE# DODEF   ENDOF

          [CHAR] 7 OF  PARSE# DROP    ENDOF
          [CHAR] 8 OF  PARSE# DROP    ENDOF

          [CHAR] 9 OF  PARSE# HEAP!   ENDOF
          [CHAR] A OF  PARSE# BASE-MEM + HEAP!  ENDOF

          [CHAR] B OF  PARSE# HEAP,   ENDOF
          [CHAR] C OF  PARSE# BASE-MEM + HEAP,  ENDOF

          [CHAR] D OF  [CHAR] D ?TAG  ENDOF
          [CHAR] E OF  [CHAR] E ?TAG  ENDOF

          [CHAR] F OF  DROP 0         ENDOF \ end of record
          [CHAR] : OF  .TOOLVER       ENDOF
        ENDCASE
        1 /STRING 0 MAX  \ advance to next char
     REPEAT
     2DROP ;  \ remove what's left of the input string

: ?PATH ( addr len -- addr len)
       2DUP [CHAR] . SCAN NIP 0= ABORT" Path expected" ;

DECIMAL
: .DEFS      ALSO DEFS  WORDS  PREVIOUS ;
: DIS/FIX    DISPLAY SEQUENTIAL 80 FIXED ; \ TI ASM object file format

: EA3LOAD ( "DSKx.FILE" -- )
      ?PATH DIS/FIX  R/O OPEN-FILE ?FILERR  TO #1
      TICKER OFF
      BEGIN
         #1 EOF
      0= WHILE
         PAD DUP 80 #1 READ-LINE ( pad len ? ior) NIP ?FILERR
       ( pad len ) ParseLine
      REPEAT
      #1 CLOSE-FILE ?FILERR
      .ELAPSED
;

: OLOAD ( <PATH> )
       ONLY FORTH ALSO DEFS
       PARSE-NAME  EA3LOAD
       HEAP TO BASE-MEM
       CR .DEFS ;

CR CR .( Usage: NEW.  OLOAD DSK?.FILENAME )
