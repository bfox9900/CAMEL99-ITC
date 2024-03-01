\ SAMSCODE.FTH                for Camel99 Forth  Brian Fox
\ Code in SAMS memory based on concept in TurboForth by Mark Wills
\ Ported to Camel99 Forth with changes Oct 13, 2021,

\ Concept:
\ FAR: word headers are in the normal Forth memory space 
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

NEEDS TRANSIENT FROM DSK1.TRANSIENT
NEEDS SAMSINI   FROM DSK1.SAMSINI  \ common code for SAMS card

TRANSIENT
NEEDS MOV,  FROM DSK1.ASM9900
NEEDS DUMP  FROM DSK1.TOOLS

PERMANENT

HERE
HEX
\ **[ CHANGE CSEG to your requirements ]**
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
CREATE R>CMAP ( -- ) ( R: page# -- )
      R0 RPOP,                                             
      R0 BANK# @@ MOV,  
      R0 SWPB,          
      R12 1E00 LI,    
      0 SBO,         
      R0 CREG @@ MOV,                  
      0 SBZ,             
      RT,

CODE CMAP  ( page# --) \ Forth word to map SAMS pages
      TOS RPUSH, 
      R>CMAP @@ BL,
      TOS POP, 
      NEXT,
ENDCODE

\ run time executor for SAMS colon words.
CREATE FARCOL
    IP RPUSH,      
    BANK# @@ RPUSH, 

\ read the extra data fields with W register 
   *W+ RPUSH,     
    R>CMAP @@ BL, 
   *W IP MOV,   
    NEXT,

CODE FAREXIT   
    R>CMAP @@ BL,     \ restore previous codepage
    IP RPOP,   
    NEXT,
ENDCODE


: FAR: ( -- ) 
    !CSP
    HEADER  FARCOL , 

\ compile code page and SAMSDP for FARCOL to use at runtime 
    CPAGE @ DUP ,   
    CMAP           
    SAMSDP @ DUP , 

    HERE SAVHERE ! 
              DP !  
    HIDE 
    ]   
;

HEX
: ?FULL ( addr --) 
    SAMSEND > 
    IF 
       CR ." >> Page " CPAGE @ DECIMAL . ." full"
      ABORT
    \  CPAGE 1+!  \ alternative action
    THEN ;

CODE GOTO ( addr -- )  C259 , ( *IP IP MOV,)  NEXT, ENDCODE

: ;FAR ( -- ) 
    POSTPONE FAREXIT 
    HERE DUP ?FULL SAMSDP !  
    SAVHERE @ DP !   
    REVEAL 
    ?CSP
    POSTPONE [
; IMMEDIATE

: CODEPAGE ( samspage -- ) \ select SAMS page for compiling
  DUP CODEPAGES 2@  1+ WITHIN 0= ABORT" Not a code page" 
  DUP CPAGE ! CMAP ; 

: >RAM   PASSTHRU CODEPAGE ; 

HEX
\ Initialize the SAMS memory that we want to use for CODE 
: CODEPAGES ( 1st last -- ) 
     2DUP CODEPAGES 2! 
     1+ SWAP 
     DO 
       I CODEPAGE
       I CMAP
    \   I . CSEG 1000 FF FILL \ for debugging
       CSEG SAMSDP !     \ INIT SAMSDP
    LOOP  
    CODEPAGES @ DUP CODEPAGE CMAP  \ return to RAM memory page
;

: RAM?  ( -- ?) BANK# @ PASSTHRU = ;

: ;   
     RAM?
     IF   POSTPONE ;  
     ELSE POSTPONE ;FAR
     THEN ; IMMEDIATE 

: :    RAM? IF :   ELSE FAR:  THEN ;

DETACH  ( remove the assembler)


HERE SWAP -
DECIMAL CR . .( bytes)

240 255 CODEPAGES \ 16 pages=64K of SAMS space 
>RAM 
