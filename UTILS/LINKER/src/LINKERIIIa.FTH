CR .( TI-99 EA3 object file LINKER, Dec 21 2021 B Fox)
\ Dec 2021 improved linking speed by 33%
\ NOV 2024 replaced Eaker case with :case BREAK; 
\          Speed up is only 3% 

 
NEEDS WORDLIST FROM DSK1.WORDLISTS
ONLY FORTH DEFINITIONS

: :CASE  ( n --) POSTPONE OVER=  POSTPONE IF  POSTPONE DROP ; IMMEDIATE
: BREAK; ( -- )  POSTPONE EXIT  POSTPONE THEN ; IMMEDIATE
 
NEEDS .S        FROM DSK1.TOOLS
NEEDS +TO       FROM DSK1.VALUES
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS ELAPSE    FROM DSK1.ELAPSE
NEEDS 3RD       FROM DSK1.3RD4TH
\ NEEDS LIFO:     FROM DSK1.STACKS
NEEDS MARKER    FROM DSK1.MARKER
NEEDS DIR       FROM DSK1.DIR
 
MARKER /LINKER  \ remove LINKER
 
HERE
VOCABULARY DEFS
ONLY FORTH ALSO DEFS DEFINITIONS 

: *END* ;  \ first word in DEFS wordlist 

ONLY FORTH DEFINITIONS 

DECIMAL
0 VALUE #1  \ a file handle
 
HEX
 2000 CONSTANT $2000
 
$2000 VALUE BASE-MEM  \ where we load OBJECT files
A000  VALUE ORIGIN    \ Where the code will be loaded by AORG
 
: ?BREAK  ( -- ) ?TERMINAL ABORT" *BREAK*" ;
: SPACEBAR ( -- ) KEY? BL = IF  KEY DROP  THEN ;
 
 
DECIMAL
.( ..)

\ heap memory management
: HEAP   ( -- addr) H @ ;  \ current heap pointer
: HALLOT ( n -- )  H +! ;  \ move heap pointer
: HEAP,  ( n -- )  HEAP ! 2 HALLOT ; \ compile n into heap
 
HEX
: NEW
    $2000 H !
    HEAP $2000 FF FILL  \ erase low ram
    HEAP TO BASE-MEM
    ['] DEFS >BODY OFF 
    ORGDP @ DP ! 
;    

\ string utilities
: CHOP   ( addr len n --  addr' len' addr2 len2 )
    3RD OVER 2>R  1- /STRING  2R> ;
 
: ?#ERROR  IF CR SOURCE TYPE CR  ABORT" Bad number" THEN ;
 
: PARSE# ( addr len -- n )
    1 /STRING    \ remove tag character
\  BUG fix: Remove trailing spaces before NUMBER? 
    4 CHOP -TRAILING NUMBER? ?#ERROR ; 
 
: GETLABEL  ( addr len -- addr' len' label len)
    1 /STRING   6 CHOP  -TRAILING 0 MAX ;
 
: DODEF ( addr len n -- )
    >R         ( -- addr' len') ( r: -- ref_addr)
    GETLABEL ( addr' len' label len)
    HEADER,  COMPILE DOCON  R> ,  \ make a Forth Constant
;
 
VARIABLE PROGLENGTH
CREATE PROGNAME  10 ALLOT
 
: PROG-ID  ( addr len -- addr len)
    PARSE# PROGLENGTH !
    8 CHOP  PROGNAME PLACE ;
 
: .TOOLVER  ( addr len -- addr 0)
   1 /STRING  40 CHOP -TRAILING CR TYPE  DROP 0 ;
 
: ?TAG    CR ." Unsupported TAG -> "  EMIT ABORT ;
 
: RELOCATE ( addr -- addr')  BASE-MEM + ;
 
: ?REF
    0= IF
       CR
       CR ." ? External REF not loaded"
       CR ." >>> " PAD COUNT TYPE
       ABORT
    THEN ;
 
: FIND-LABEL ( $addr -- xt)
    ONLY DEFS FIND  ?REF    \ search only the defs vocabulary
    ONLY FORTH ALSO DEFS ;  \ restore normal searching

\ Since Assembler Labels are stored as Forth constants
\ we can find them and 'execute' them to return their memory address
\ CREATE LBLBUFF 10 ALLOT 
: LABEL-EVAL ( -- n)
   GETLABEL EXECUTE  \ run the word generate address
;
 
: TAG-INTERPRET ( c )
          [CHAR] B :CASE  PARSE# HEAP,          BREAK;
          [CHAR] A :CASE  PARSE# RELOCATE H !   BREAK;
          [CHAR] C :CASE  PARSE# RELOCATE HEAP, BREAK;
          [CHAR] 5 :CASE  PARSE# RELOCATE DODEF BREAK;
 
          [CHAR] 3 :CASE  PARSE# RELOCATE 
                          LABEL-EVAL SWAP !     BREAK;
 
 
          [CHAR] 4 :CASE  PARSE# 
                       LABEL-EVAL SWAP !        BREAK;
 
          [CHAR] 6 :CASE  PARSE# DODEF          BREAK;
 
          [CHAR] 9 :CASE  PARSE# H !            BREAK;

          [CHAR] F :CASE  DROP 0                BREAK; \ CHECKSUM ignored
          [CHAR] 0 :CASE  PROG-ID               BREAK;
          [CHAR] : :CASE  .TOOLVER              BREAK;
          [CHAR] 7 :CASE  4 /STRING             BREAK;
          [CHAR] 8 :CASE  4 /STRING             BREAK;
 
          [CHAR] D :CASE  [CHAR] D ?TAG         BREAK;
          [CHAR] E :CASE  [CHAR] E ?TAG         BREAK;
          [CHAR] 1 :CASE  PARSE# TO ORIGIN      BREAK;
          [CHAR] 2 :CASE  0 TO ORIGIN           BREAK; \ ??
                         ( DEFAULT:)  DROP 
; 

\ See E/A manual page 309 for meanings of object file tags.
: ParseObject ( add len -- )
    BEGIN
        DUP ( len<>0)
    WHILE
        OVER C@ TAG-INTERPRET
        1 /STRING 0 MAX  \ advance to next char
    REPEAT
    2DROP ;
 
DECIMAL
CREATE LNBUFF 127 ALLOT 
: OPEN-DV80 
    PSZ NEGATE ^PAB +!              \ make new PAB, on pab stack
    80 04 FOPEN ?FILERR             \ OPEN as DISPLAY FIXED 80 INPUT
    SOURCE-ID 1+!                   \ incr. source ID (1st file is 1)
    LINES OFF                       \ reset the line counter
;

: EA3LOAD ( caddr len -- )
    CR ." Linking " 2DUP TYPE
    SOURCE-ID @ >IN @ 2>R           \ save source-ID, input pointer
    ( $ len ) OPEN-DV80 
    BEGIN
        2 FILEOP 0=                   \ file read operation
    WHILE
        PAD 200 + DUP FGET ( addr n) \ read line to temp mem buffer
        ParseObject                  \ interpret line of object code
        LINES 1+!                    \ count the line
    REPEAT
    PSZ ^PAB +!                     \ remove PAB from pab stack
    2R> >IN !  SOURCE-ID !          \ restore >IN, SOURCE-ID
;
 
: ?PATH ( addr len -- addr len)
       2DUP [CHAR] . SCAN NIP 0= ABORT" Path expected" ;
 
: .BYTES  ( addr -- ) HEAP $2000 -  . ." bytes used" ;
 
: LINK ( <PATH> )
       TICKER OFF
       BASE @ >R
       HEX
       PARSE-NAME ?PATH  EA3LOAD
       CR DEFS WORDS
       CR LINES ?  ." lines of object code"
       CR DECIMAL .BYTES
       .ELAPSED
 
       HEAP TO BASE-MEM     \ BASE-MEM moved to current end of Heap
       R> BASE !
;
 
\ Linkage to Forth
HEX
CODE RUN  ( def --)  0454 ,  C136 , NEXT, ENDCODE  \ B  *TOS    DROP
CODE BLWP ( def --)  0414 ,  C136 , NEXT, ENDCODE  \ BLWP *TOS  DROP
 
CODE CALL ( def --)
    0647 ,   \ R11 RPUSH,
    C5CB ,
    0694 ,   \ BL *TOS
    C2F7 ,   \ R11 RPOP,
    C136 ,   \ DROP
    NEXT,
ENDCODE
 
: EXTERN:   ( def --) CODE  0460 , ( addr) ,  NEXT,  ;   \ B @def
: EXT-SUB:  ( def --) CODE  06A0 , ( addr)  ,  NEXT,  ;  \ BL @def
: EXT-PROG: ( def --) CODE  0420 , ( vector) ,  NEXT,  ; \ BLWP @def
 
ONLY FORTH DEFINITIONS 
: HELP
  PAGE ." Camel99 Linker IV  Apr 24 2025"
  CR
  CR ." Usage: "
  CR ." NEW  clears HEAP mem. & DEFS words"
  CR ." LINK DSK?.FILENAME   load object"
  CR ." Commands:"
  CR ." <def> RUN     branch to def"
  CR ." <def> CALL    BL to def"
  CR ." <def> BLWP    blwp to def"
  CR
  CR ." Declare DEFs as Forth code: "
  CR ." <def> EXTERN: <name>  branches to DEF"
  CR ." <def> EXT-SUB: <name> BL to DEF"
  CR ." <def> EXT-PROG: <name> BLWP to DEF"
  CR ." <def> EXT-DATA: <name> returns addr. to Forth"
  CR
;
 
\ HELP

\ NEW
CR ." Linker is RESET"
 
CR HERE SWAP - DECIMAL . .( bytes)

ONLY FORTH DEFINITIONS  
HEX 
: GO   
    WARM
    INIT-WORDLISTS 
    ONLY FORTH ALSO DEFS DEFINITIONS 
    E4 7 VWTR 
    NEW 
    HELP 
    CR ORDER 
    
    ABORT ; 

LOCK 
INCLUDE DSK1.SAVESYS
' GO SAVESYS DSK6.LINKEXE 
 
 