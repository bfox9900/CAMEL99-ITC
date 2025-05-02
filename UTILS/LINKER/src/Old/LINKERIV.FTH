CR .( TI-99 EA3 object file LINKER, Dec 21 2021 B Fox)
\ Dec 2021 improved linking speed by 33%
\ NOV 2024 replaced Eaker case with Vector table
\          faster than Eaker case but slower than EXIT THEN 

INCLUDE DSK1.TOOLS

NEEDS WORDLIST FROM DSK1.WORDLISTS
ONLY FORTH DEFINITIONS


\ NEEDS .S        FROM DSK1.TOOLS
NEEDS +TO       FROM DSK1.VALUES
NEEDS CASE      FROM DSK1.CASE
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS ELAPSE    FROM DSK1.ELAPSE
NEEDS 3RD       FROM DSK1.3RD4TH
\ NEEDS LIFO:     FROM DSK1.STACKS
NEEDS MARKER    FROM DSK1.MARKER
 
MARKER /LINKER  \ remove LINKER
 
HERE
VOCABULARY DEFS
 
 
ONLY FORTH DEFINITIONS
DECIMAL
0 VALUE #1  \ a file handle
 
HEX
 2000 CONSTANT $2000
 
$2000 VALUE BASE-MEM  \ where we load OBJECT files
A000  VALUE ORIGIN    \ Where the code will be loaded by AORG
 
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
: NEW
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
    /TAG  6 CHOP  -TRAILING 0 MAX ;
 
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
    /TAG  40 CHOP -TRAILING CR TYPE  DROP 0 ;
 
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
: LABEL-EVAL ( -- n)
   GETLABEL HERE PLACE      \ store label at HERE as counted string
   HERE FIND-LABEL EXECUTE  \ run the word generate address
;
 
: TAG-0    PROG-ID ;
: TAG-1    PARSE# TO ORIGIN ;
: TAG-2    0 TO ORIGIN ;
: TAG-3    PARSE# RELOCATE  LABEL-EVAL SWAP ! ;
: TAG-4    PARSE# LABEL-EVAL SWAP ! ;
: TAG-5    PARSE# RELOCATE DODEF ;
: TAG-6    PARSE# DODEF  ;
: TAG-7    4 /STRING  ;
: TAG-8    4 /STRING  ;
: TAG-9    PARSE# H !  ;
: TAG-:    .TOOLVER  ; 
: TAG-A    PARSE# RELOCATE H ! ;
: TAG-B    PARSE# HEAP, ;
: TAG-C    PARSE# RELOCATE HEAP, ;
: TAG-D    [CHAR] D ?TAG ;
: TAG-E    [CHAR] E ?TAG ;
: TAG-F    DROP 0 ;

: NOOP ;

: CASE:  ( -- <name> ) CREATE  ;
: ;CASE   ( n -- )  DOES> SWAP CELLS + PERFORM ;

CASE: TAG-TABLE ( c --)
  ( turn on compiler)
  ]
    TAG-0  TAG-1  TAG-2  TAG-3    
    TAG-4  TAG-5  TAG-6  TAG-7 
    TAG-8  TAG-9  TAG-:  NOOP   ( 59)
    NOOP   NOOP   NOOP   NOOP   ( 63)
    NOOP   TAG-A  TAG-B  TAG-C  ( 67)
    TAG-D  TAG-E  TAG-F         ( 71)
  [ 
( turn off compiler)
;CASE 

\ See E/A manual page 309 for meanings of object file tags.
: ParseObject ( add len -- )
    BEGIN
        DUP ( len<>0)
    WHILE
        OVER C@  [CHAR] 0 -  TAG-TABLE
        1 /STRING 0 MAX  \ advance to next char
        0 SKIP 
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
 
: .BYTES  ( addr -- ) HEAP SWAP -  . ." bytes of code" ;
 
: LINK ( <PATH> )
       TICKER OFF
       BASE @ >R
       HEX
       ONLY FORTH ALSO DEFS DEFINITIONS
 
       HEAP
       PARSE-NAME ?PATH  EA3LOAD
       CR DEFS WORDS
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
 
ONLY FORTH DEFINITIONS ALSO DEFS
: HELP
  PAGE ." Camel99 Linker IV  Nov12 2024"
  CR
  CR ." Usage: "
  CR ." NEW  clear HEAP mem. & DEFS words"
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
 
HELP
NEW
CR ." Linker is RESET"
 
CR HERE SWAP - DECIMAL . .( bytes)
 
 
 