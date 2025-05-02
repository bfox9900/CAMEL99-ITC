CR .( TI-99 EA3 object file LINKER, Dec 21 2021 B Fox)
\ Dec 2021 improved linking speed by 33%
\ Apr 24 2025, rebuild with new -trailing. Does not need 0 MAX 
 
NEEDS .S        FROM DSK1.TOOLS
NEEDS PLOT      FROM DSK1.GRAPHICS2B

NEEDS +TO       FROM DSK1.VALUES
NEEDS -TRAILING FROM DSK1.TRAILING \ rebuilt with new -trailing
NEEDS ELAPSE    FROM DSK1.ELAPSE
NEEDS 3RD       FROM DSK1.3RD4TH
NEEDS MARKER    FROM DSK1.MARKER
NEEDS DIR       FROM DSK1.DIR
 
MARKER /LINKER  \ skip LINKER

NEEDS WORDLIST FROM DSK1.WORDLISTS
ONLY FORTH DEFINITIONS
 
HERE
VOCABULARY DEFS
 
 
ONLY FORTH DEFINITIONS
DECIMAL
0 VALUE #1  \ a file handle
 
VARIABLE RecCheckSum  \ recorded for future
VARIABLE PROGSIZE
VARIABLE TAG \ for debugging

\ string buffers 
CREATE PROGNAME  10 ALLOT
CREATE LABEL$ 6 ALLOT 
 
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
    ['] DEFS  >BODY OFF \ skip all DEFS words
    ORGDP @ DP ! 
;    

\ string utilities
: CHOP   ( addr len n --  addr' len' addr2 len2 )
    S" 3RD OVER 2>R  1- /STRING  2R>"  EVALUATE ; IMMEDIATE

DECIMAL 
: PARSE# ( addr len -- n )
    BASE @ >R 
    5 CHOP 1 /STRING HEX NUMBER? ABORT" Bad number in object file"
    R> BASE ! ;

: PARSE-DEF  ( addr len -- addr' len' label len)
    7 CHOP  1 /STRING -TRAILING ;

: DODEF ( addr len n -- ) \ compile DEF as a Forth constant
    >R  PARSE-DEF HEADER, COMPILE DOCON  R> , ;

: MODULE-ID  ( addr len -- addr len)
    PARSE#  PROGSIZE !
    8 /STRING ; \ 8 bytes of module name are ignored
 
: .TOOLVER  ( addr len -- addr 0)
    1 /STRING \ skip the tag byte 
    40 CHOP  CR TYPE  DROP 0 ;
 
: ?TAG    
   CR ." Unsupported TAG -> " TAG @ DUP EMIT ." (" . ." )" ABORT ;
 
: RELOCATE ( addr -- addr') BASE-MEM + ;
 
: ERR-REPORT 
    ONLY FORTH ALSO DEFS DEFINITIONS 
    CR ." >>REF  " LABEL$ COUNT TYPE ."  not found"
    CR
    CR ." Line#  = " LINES ? 
    CR ." Memory = " HEAP U. 
;

: ?REF   0= IF ERR-REPORT ABORT THEN ;

: FIND-LABEL ( $addr -- xt)
    ONLY DEFS FIND  ?REF    \ search only the defs vocabulary
    ONLY FORTH ALSO DEFS ;  \ restore normal searching

HEX  
: ?ADDR ( u -- u)  
    DUP $2000 3F00 WITHIN 0= ABORT" Address out of range: >2000..>3F00" ;

\ Since Assembler DEFs are stored as Forth constants
\ we can find them and 'execute' them to return their memory address
: DEF-ADDR ( -- u)
   PARSE-DEF LABEL$ PLACE    \ read the DEF text 
   LABEL$ FIND-LABEL         \ search in DEFS vocabulary 
   EXECUTE                   \ DEF is constant. Execute to get no. 
;

\ * Resolve an External Reference *
: TAG-3   PARSE# RELOCATE >R DEF-ADDR R> ! ;
: TAG-4   PARSE# >R DEF-ADDR R> ! ;

: TAG-6   PARSE# ?ADDR DODEF ;   \ absolute addr label 
: TAG-9   PARSE# ?ADDR H ! ;     \ AORG 

\ See E/A manual page 309 for meanings of object file tags

: ParseObject ( add len -- )
    BEGIN
        DUP ( len<>0)
    WHILE
        OVER C@ DUP TAG ! 
        CASE
          [CHAR] B OF  PARSE# HEAP,          ENDOF
          [CHAR] A OF  PARSE# RELOCATE H !   ENDOF
          [CHAR] C OF  PARSE# RELOCATE HEAP, ENDOF
          [CHAR] 5 OF  PARSE# RELOCATE DODEF ENDOF
 
          [CHAR] 3 OF  TAG-3                 ENDOF
 
          [CHAR] 4 OF  TAG-4                 ENDOF
 
          [CHAR] 6 OF  TAG-6                 ENDOF
 
          [CHAR] 9 OF  TAG-9                 ENDOF

          [CHAR] F OF  DROP 0                ENDOF \ End of record 
          [CHAR] 0 OF  MODULE-ID             ENDOF
          [CHAR] : OF  .TOOLVER              ENDOF
          [CHAR] 7 OF  PARSE# RecCheckSum !  ENDOF
          [CHAR] 8 OF  4 /STRING             ENDOF
 
          [CHAR] D OF  [CHAR] D ?TAG         ENDOF
          [CHAR] E OF  [CHAR] E ?TAG         ENDOF
          [CHAR] 1 OF  PARSE# TO ORIGIN      ENDOF
          [CHAR] 2 OF  0 TO ORIGIN           ENDOF \ ??
           \ TRUE ABORT" Can't parse this file" 
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
        2 FILEOP 0=                 \ file read operation
    WHILE
        PAD DUP FGET ( addr n)      \ read line to temp mem buffer
        ParseObject                 \ interpret line of object code
        LINES 1+!                   \ count the line
    REPEAT
    PSZ ^PAB +!                     \ skip PAB from pab stack
    2R> >IN !  SOURCE-ID !          \ restore >IN, SOURCE-ID
;
 
: ?PATH ( addr len -- addr len)
       2DUP [CHAR] . SCAN NIP 0= ABORT" Path expected" ;
 
: .AVAIL  ( addr -- ) $2000 HEAP OVER - -  . ." bytes remaining" ;
 
: .SIZE ( n --) ." Object size :" PROGSIZE @ U. ;

: LINK ( <PATH> )
       ONLY FORTH ALSO DEFS DEFINITIONS 

       PARSE-NAME ?PATH EA3LOAD
       .ELAPSED
       CR LINES ?  ." lines of object code"
       CR .SIZE 
       CR .AVAIL
       CR 
       CR ." DEFs in Memory:"
       ALSO DEFS WORDS PREVIOUS  \ show the defintions in the file 
       DECIMAL
       HEAP TO BASE-MEM  \ needed for relocating next object files
;

\ Allows you to start code from the Forth command line 
HEX
CODE RUN  ( def --)  0454 ,  NEXT, ENDCODE  \ B  *TOS  
CODE BLWP ( def --)  0414 ,  NEXT, ENDCODE  \ BLWP *TOS 
 
CODE CALL ( def --) \ call a BL sub-routine and return
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
  PAGE ." Camel99 Linker III  Apr 24 2025"
  CR
  CR ." Usage: "
  CR ." NEW  clear HEAP mem. & DEFS words"
  CR ." LINK DSK?.FILENAME   load object"
  CR ." Commands:"
  CR ." <def> RUN     branch to def"
  CR ." <def> CALL    BL to def"
  CR ." <def> BLWP    BLWP to def"
  CR
  CR ." Declare DEFs as Forth code: "
  CR ." <def> EXTERN:   <name>  branches to DEF"
  CR ." <def> EXT-SUB:  <name> BL to DEF"
  CR ." <def> EXT-PROG: <name> BLWP to DEF"
  CR
;
 
 
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
    ." Ready"
    ABORT ; 

LOCK 
INCLUDE DSK1.SAVESYS
' GO SAVESYS DSK6.LINKEXE 
 
  