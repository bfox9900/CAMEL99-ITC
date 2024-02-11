\ SAMSCODE.FTH                for Camel99 Forth  Brian Fox
\ Code in SAMS memory based on concept in TurboForth by Mark Wills
\ Ported to Camel99 Forth with changes Oct 13, 2021,

\ Concept:
\ FAR: word headers are in the normal Forth memory space so all SAMS words
\ can be found.
\ FAR: word data structure has two extra fields
\ <link> < HEADER> <imm> <len NAME..> <FARCOL> <BANK#> <IP>

\ FAR: compiles a "fat" header that contains SAMS BANK# and SAMS IP
\  <LINK> 
\  <PRECENDCE> 
\  <NAME> 
\  <CODEPAGE> \ extra field
\  <SAMSPFA>  \ extra field 


\ ;FAR compiles FAREXIT in SAMS memory, not in RAM to save space.

\ Compile time check: ;FAR tests end of SAMS memory

\ HISTORY
\ Update Nov 2022: removed array of SAMS DP variables.
\ - Each SAMS page uses last memory cell to hold its own DP.
\ - Can now compile code to any SAMS page.
\ - You must use <1st> <last> CODEPAGES to initialize SAMS code pages 
\ Feb 2024: Pass codepage via Rstack to CMAP, FARCOL 1 less instruction 

\ NEEDS DUMP  FROM DSK1.TOOLS
NEEDS TRANSIENT FROM DSK1.TRANSIENT
NEEDS SAMSINI   FROM DSK1.SAMSINI  \ common code for SAMS card

TRANSIENT
NEEDS MOV,  FROM DSK1.ASM9900

PERMANENT

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
      TOS RPUSH,     \ need parameter on Rstack
      TOS POP,       \ refill TOS
      R>CMAP @@ BL,  \ call it
      NEXT,
ENDCODE

\ run time executor for SAMS colon words.
CREATE FARCOL
    IP RPUSH,           \ save current IP 
    BANK# @@ RPUSH,     \ save active code page

\ read the extra data fields with W register 
   *W+ RPUSH,          \ fetch codepage >R, autoinc W 
    R>CMAP @@ BL,      \ call R>CMAP (uses RSTACK parameter)
   *W IP MOV,          \ fetch SAMSDP & set as IP
    NEXT,

CODE FAREXIT            \ exit for SAMS word
    R>CMAP @@ BL,       \ restore previous codepage & map it in
    IP RPOP,            \ do normal Forth EXIT 
    NEXT,
ENDCODE

: FAR: ( -- ) \ special colon for words in FAR memory
    !CSP
    HEADER  FARCOL ,  \ compile the new executor as CFA

\ compile code page and SAMSDP for FARCOL to use at runtime 
    CPAGE @ DUP ,      \ compile codepage as the DATA field
    CMAP               \ map in the SAMS page to compile code
    SAMSDP @ DUP ,     \ compile SAMSDP & return a copy 

    HERE SAVHERE !     \ save FORTH here
              DP !     \ set Forth DP to SAMSDP
    HIDE 
    ]                  \ turn on the compiler
;

HEX
: ?FULL ( addr --) 
    SAMSEND > 
    IF 
       CR ." >> Page " CPAGE @ DECIMAL . ." full"
     \  ABORT 
       CPAGE 1+!  
    THEN ;

CODE GOTO ( addr -- )  C259 , ( *IP IP MOV,)  NEXT, ENDCODE

: ;FAR ( -- ) \ end SAMS compilation. *NEW* compile time memory test
    POSTPONE FAREXIT            \ restore previous page and exit 
 \   POSTPONE GOTO  SAVHERE @ ,  \ get Forth IP back home  *CRITICAL?? 
    
    HERE DUP ?FULL SAMSDP !     \ update HERE for this bank, keep a copy
    SAVHERE @ DP !              \ restore DP to CPU RAM
    REVEAL 
    ?CSP
    POSTPONE [
; IMMEDIATE

: CODEPAGE ( samspage -- ) \ select SAMS page for compiling
  DUP CODEPAGES 2@  1+ WITHIN 0= ABORT" Not a code page" 
  DUP CPAGE ! CMAP ; 

HEX
\ Initialize the SAMS memory that we want to use for CODE 
\ ** USE THIS COMMAND ONLY ONCE OR MACHINE WILL CRASH ** 
: CODEPAGES ( 1st last -- ) 
     2DUP CODEPAGES 2! 
     1+ SWAP 
     DO 
       I CODEPAGE
       I CMAP
\       I . CSEG 1000 FF FILL \ for debugging ONLY 
       CSEG SAMSDP !     \ INIT the local CSEG DP variable to start of CSEG    
    LOOP  
    CODEPAGES @ DUP CODEPAGE CMAP  \ return to RAM memory page
;

: RAM?  ( -- ?) BANK# @ PASSTHRU = ;
: >SAMS  CPAGE @  CMAP ;
: >RAM   PASSTHRU CMAP ; 

>RAM 
: ;   
     RAM?
     IF   POSTPONE ;  
     ELSE POSTPONE ;FAR
     THEN ; IMMEDIATE 

: :    RAM? IF :   ELSE FAR:  THEN ;

\ DETACH  ( remove the assembler)

HERE SWAP -
DECIMAL CR . .( bytes)

240 255 CODEPAGES \ 16 pages=64K of SAMS space 
>RAM 
