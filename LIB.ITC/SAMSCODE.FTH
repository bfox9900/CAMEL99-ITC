\ SAMSCODE.FTH                for Camel99 Forth  Brian Fox
\ Code in SAMS memory based on concept in TurboForth by Mark Wills
\ Ported to Camel99 Forth with changes Oct 13, 2021,

\ HISTORY
\ Update Nov 2022: removed array of SAMS DP variables.
\ Feb 2024: Pass codepage via Rstack to CMAP, cleanup & testing 


NEEDS TRANSIENT FROM DSK1.TRANSIENT
TRANSIENT
NEEDS MOV,  FROM  DSK1.ASM9900

PERMANENT
NEEDS DUMP      FROM DSK1.TOOLS
NEEDS SAMSINI   FROM DSK1.SAMSINI  \ common code for SAMS card

HERE
HEX
\ **************[ CHANGE CSEG to your requirements ]******************

HEX              3000 CONSTANT CSEG      \ CODE window in CPU RAM

\ SAMS memory addresses for code
          CSEG 0FFE + CONSTANT SAMSDP    \ variable at end of SAMS page
          CSEG 0F00 + CONSTANT SAMSEND   \ leave room for scroll buffer      
4000 CSEG 0B RSHIFT + CONSTANT CREG      \ compute CSEG SAMS register
     CSEG 0C RSHIFT   CONSTANT PASSTHRU  \ default RAM page

VARIABLE SAVHERE   \ temp holder for RAM Dictionary pointer
VARIABLE BANK#     \ last SAMS bank# selected
VARIABLE CPAGE     \ active code page used for compiling
CREATE CODEPAGES 0 , 0 ,   \ valid CODEPAGES 

HEX
\ **LEAF SUB-ROUTINE**
CREATE R>CMAP ( -- ) ( R: page# -- )
      R0 RPOP,
      R0 BANK# @@ MOV,   \ update the last bank used
      R0 SWPB,           \ swap bytes
      R12 1E00 LI,       \ set SAMS card CRU address
      0 SBO,             \ turn on the card
      R0 CREG @@ MOV,    \ map it
      0 SBZ,             \ turn off card
      RT,

CODE CMAP  ( page# --) \ Forth word to map SAMS pages
      TOS RPUSH,    \ need parameter on Rstack
      R>CMAP @@ BL,  \ call it
      TOS POP,      \ refill TOS
      NEXT,
ENDCODE

\ run time executor for SAMS colon words.
CREATE FARCOL
     IP RPUSH,
     W IP MOV,            \ IP = DATA cell of this word
     BANK# @@ RPUSH,      \ Save active code page
     *IP+ RPUSH,          \ get codepage to rstack, autoinc IP 
      R>CMAP @@ BL,       \ call R>CMAP (uses RSTACK parameter)
     *IP+ IP MOV,         \ get SAMSDP & set as IP, autoinc IP  
     NEXT,

CODE FAREXIT             \ exit for SAMS word
     R>CMAP @@ BL,       \ restore old codepage & map it in
     IP RPOP,            \ Regular FORTH EXIT
     NEXT,
ENDCODE

\ \\\\\\\\\\\\\\\\ code words end  //////////////////

\ change dictionary pointer to SAMS memory
: SAMSDP! ( addr -- ) 
     HERE SAVHERE !     \ save FORTH here
     ( samsdp) DP !     \ set Forth DP to SAMSDP
;

: FAR: ( -- ) \ special colon for words in FAR memory
     !CSP
     HEADER             \ compile Forth header with name
\ RUNTIME ACTION 
     FARCOL ,           \ compile the new executor as CFA

\ compile code page and SAMSDP for FARCOL to use at runtime 
     CPAGE @ DUP ,      \ compile codepage as the DATA field
     CMAP               \ map in the SAMS page to compile code
     SAMSDP @ DUP ,     \ compile SAMSDP 
     SAMSDP!            \ and switch dictionary to SAMSDP     
     HIDE 
     ]                  \ turn on the compiler
;

: ;FAR ( -- ) \ end SAMS compilation. *NEW* compile time memory test
     POSTPONE FAREXIT    \ compiles at end of SAMS code
     POSTPONE [          \ turn compiler off
     REVEAL ?CSP
     HERE DUP SAMSDP !   \ update HERE for this bank, keep a copy
     SAVHERE @ DP !      \ restore DP to CPU RAM
     SAMSEND > 
     IF 
       CR ." >> Page " CPAGE @ DECIMAL . ." full"
       ABORT 
     THEN 
; IMMEDIATE

: CODEPAGE ( bank# -- ) \ select SAMS page for compiling
  DUP CODEPAGES 2@  1+ WITHIN 0= ABORT" Not a code page" 
  CPAGE ! ; 

HEX
\ Initialize the SAMS memory that we want to use for CODE 
: CODEPAGES ( 1st last -- ) 
     2DUP CODEPAGES 2! 
     1+ SWAP 
     DO 
       I CODEPAGE
       I CMAP
     \  I . CSEG 1000 FF FILL \ for debugging ONLY 
       CSEG SAMSDP !     \ INIT the local CSEG DP variable to start of CSEG    
    LOOP  
    CODEPAGES @ DUP CODEPAGE CMAP  \ return to RAM memory page
;

: >SAMS  CPAGE @ CMAP ;
: >RAM   PASSTHRU CMAP ; 

>RAM 
: ;   
     BANK# @ PASSTHRU = 
     IF POSTPONE ;  
     ELSE POSTPONE ;FAR 
     THEN ; IMMEDIATE 

: :  BANK# @ PASSTHRU = IF :   ELSE  FAR:  THEN ;


                            DETACH 
HERE SWAP -
DECIMAL CR . .( bytes)

240 255 CODEPAGES 
