CR .( TI-99 EA3 object file LINKER, Dec 21 2021 B Fox)
\ Dec 2021 improved linking speed by 33%

NEEDS WORDLIST FROM DSK1.WORDLISTS
ONLY FORTH DEFINITIONS

\ NEEDS .S        FROM DSK1.TOOLS
NEEDS +TO       FROM DSK1.VALUES
NEEDS CASE      FROM DSK1.CASE
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS ELAPSE    FROM DSK1.ELAPSE
NEEDS 3RD       FROM DSK1.3RD4TH
NEEDS MARKER    FROM DSK1.MARKER

HERE
VOCABULARY DEFS

MARKER /LINKER  \ remove LINKER

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
           0 >R  ( word counter on Rstack)
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
: HEAP   ( -- addr) H @ ;  \ current heap pointer
: HALLOT ( n -- )  H +! ;  \ move heap pointer
: HEAP,  ( n -- )  HEAP ! 2 HALLOT ; \ compile n into heap

HEX
: NEW.
          $2000 H !
          HEAP $2000 FF FILL  \ erase low ram
          HEAP TO BASE-MEM
          ['] DEFS  >BODY OFF  ;  \ remove all DEFS words

\ string utilities
: CHOP   ( addr len n --  addr' len' addr2 len2 )
      S" 3RD OVER 2>R  1- /STRING  2R>"  EVALUATE ; IMMEDIATE

: /TAG     ( addr len -- addr' len') \ cut tag character
      S" 1 /STRING" EVALUATE  ;  IMMEDIATE

: ?#ERROR    ABORT" Bad number" ;

: PARSE# ( addr len -- n )
        /TAG  4 CHOP NUMBER? ?#ERROR ;

: GETLABEL  ( addr len -- addr' len' label len)
        /TAG  6 CHOP  -TRAILING ;

: DODEF ( addr len n -- )
        >R         ( -- addr' len') ( r: -- ref_addr)
        GETLABEL ( addr' len'  label len)
        HEADER,  COMPILE DOCON  R> ,  \ make a Forth Constant
;

VARIABLE PROGLENGTH
CREATE PROGNAME  10 ALLOT

: PROG-ID  ( addr len -- addr len)
          PARSE# PROGLENGTH !
          8 CHOP  PROGNAME PLACE ;

: .TOOLVER  ( addr len -- addr 0)
          /TAG  40 CHOP -TRAILING CR TYPE  DROP 0 ;

: ?TAG    CR ." Unknown TAG -> "  EMIT ABORT ;

: RELOCATE ( addr -- addr')  BASE-MEM + ;

\ See E/A manual page 309 for meanings of object file tags.
: ParseObject ( add len -- )
      BEGIN
        DUP ( len<>0)
      WHILE
        OVER C@ ( tag)
        CASE
          [CHAR] B OF  PARSE# HEAP,          ENDOF
          [CHAR] A OF  PARSE# RELOCATE H !   ENDOF
          [CHAR] C OF  PARSE# RELOCATE HEAP, ENDOF
          [CHAR] 5 OF  PARSE# RELOCATE DODEF ENDOF

          [CHAR] 3 OF  PARSE# RELOCATE ( ref)
                       GETLABEL EVALUATE ( ref def)
                       SWAP ( def ref) !    ENDOF

          [CHAR] 0 OF  PROG-ID              ENDOF

          [CHAR] 4 OF  PARSE# ( ref)
                       GETLABEL EVALUATE ( ref def)
                       SWAP  ( def ref) !   ENDOF

          [CHAR] 6 OF  PARSE# DODEF         ENDOF

          [CHAR] 9 OF  PARSE# H !           ENDOF
          [CHAR] F OF  DROP 0               ENDOF \ remove remaining content
          [CHAR] : OF  .TOOLVER             ENDOF
          [CHAR] 7 OF  4 /STRING            ENDOF \ checksum (not used)
          [CHAR] 8 OF  4 /STRING            ENDOF \ ignore checksum

          [CHAR] D OF  [CHAR] D ?TAG        ENDOF
          [CHAR] E OF  [CHAR] E ?TAG        ENDOF
          [CHAR] 1 OF  [CHAR] 1 ?TAG        ENDOF
          [CHAR] 2 OF  [CHAR] 2 ?TAG        ENDOF
            ( DEFAULT: DROP the character)
        ENDCASE
        1 /STRING 0 MAX  \ advance to next char
     REPEAT
     2DROP ;

DECIMAL
: EA3LOAD ( caddr len -- )
           CR ." Linking " 2DUP TYPE
           SOURCE-ID @ >IN @ 2>R           \ save source-ID, input pointer
           PSZ NEGATE ^PAB +!              \ make new PAB, on pab stack
           ( $ len ) 80 04 FOPEN ?FILERR   \ OPEN as DISPLAY FIXED 80 INPUT
           SOURCE-ID 1+!                   \ incr. source ID (1st file is 1)
           LINES OFF                       \ reset the line counter
           BEGIN
             2 FILEOP 0=                   \ file read operation
           WHILE
             HERE 200 + DUP FGET ( addr n) \ read line to temp mem buffer
             ParseObject                   \ interpret line of object code
             LINES 1+!                     \ count the line
           REPEAT
           PSZ ^PAB +!                     \ remove PAB from pab stack
           2R> >IN !  SOURCE-ID !          \ restore >IN, SOURCE-ID
;

: ?PATH ( addr len -- addr len)
       2DUP [CHAR] . SCAN NIP 0= ABORT" Path expected" ;

: LINK ( <PATH> )
       TICKER OFF
       BASE @ >R
       HEX
       ONLY FORTH ALSO DEFS DEFINITIONS
       PARSE-NAME ?PATH EA3LOAD
       R> BASE !

       HEAP TO BASE-MEM
       CR DEFS WORDS
       .ELAPSED ;

\ Linkage to Forth
HEX
CODE RUN  ( def --)  0454 ,  C136 , NEXT, ENDCODE  \ B  *TOS    DROP
CODE CALL ( def --)  0694 ,  C136 , NEXT, ENDCODE  \ BL *TOS    DROP
CODE BLWP ( def --)  0414 ,  C136 , NEXT, ENDCODE  \ BLWP *TOS  DROP

: EXTERN:   ( def --)  CODE  0460 , ( addr) ,  NEXT,  ;   \ B @def
: EXT-SUB:  ( def --)  CODE  06A0 , ( addr)  ,  NEXT,  ;  \ BL @def
: EXT-PROG: ( def --)  CODE  0420 , ( vector) ,  NEXT,  ; \ BLWP @def

ONLY FORTH DEFINITIONS ALSO DEFS

PAGE .( Camel99 Linker  Dec 2021)
CR
CR .( Usage: )
CR .( NEW.  clear low ram for code)
CR .( LINK DSK?.FILENAME   load object)
CR .( Commands:)
CR .( <def> RUN     branch to def)
CR .( <def> CALL    BL to def)
CR .( <def> BLWP    blwp to def)
CR
CR .( Declare DEFs as Forth code: )
CR .( <def> EXTERN: <name>  branches to DEF)
CR .( <def> EXT-SUB: <name> BL to DEF)
CR .( <def> EXT-PROG: <name> BLWP to DEF)
CR .( <def> EXT-DATA: <name> def ->Forth constant)
CR
NEW.
CR .( Low RAM initialized)
CR HERE SWAP - DECIMAL . .( bytes)
