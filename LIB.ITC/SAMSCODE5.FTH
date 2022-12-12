\ SAMSCODE.FTH                for Camel99 Forth  Brian Fox
\ Code in SAMS memory based on concept in TurboForth by Mark Wills
\ Ported to Camel99 Forth with changes Oct 13, 2021,

\ Concept:
\ FAR: word headers are in the normal Forth memory space so all SAMS words
\ can be found.
\ FAR: word data structure has two extra fields
\ <link> < HEADER> <imm> <len NAME..> <FARCOL> <BANK#> <IP>

\ FAR: compiles a "fat" header that remember SAMS BANK# and SAMS IP

\ ;FAR  compiles FARSEMIS in SAMS memory, not in RAM Dictionary to save space.

\ Compile time check: ;FAR tests for SAMS memory
\ Smart MAP. Remembers the last SAMS page that was mapped. (BANK#)
\ Only performs a MAP if it's a new SAMS page

\ Update Nov 2022: removed array of SAMS DP variables.
\ - Each SAMS page uses last memory cell to hold its own DP.
\ - Can now compile code to any SAMS page.
\ - You must use ( n) CODEPAGE FIRSTUSE the first time you use a page

NEEDS MOV,      FROM DSK1.ASM9900
NEEDS SAMSINI   FROM DSK1.SAMSINI  \ common code for SAMS card

HERE

\ **************[ CHANGE CSEG to your requirements ]******************

HEX              3000 CONSTANT CSEG      \ CODE window in CPU RAM

\ ********************************************************************

\ Derived SAMS memory addresses for code
          CSEG 0FFE + CONSTANT SAMSDP    \ variable at end of SAMS page
4000 CSEG 0B RSHIFT + CONSTANT CREG      \ compute CSEG SAMS register
     CSEG 0C RSHIFT   CONSTANT PASSTHRU  \ default page for CSEG

VARIABLE  SAVHERE   \ temp holder for RAM Dictionary pointer
VARIABLE  BANK#     \ last SAMS bank# selected
VARIABLE  CPAGE     \ active code page used for compiling


HEX
\ **LEAF SUB-ROUTINE**
CREATE _CMAP ( -- ) ( R: page# -- )
      R0 RPOP,              \ POP parameter from Rstack
      R0 BANK# @@ CMP,      \ already mapped?
      NE IF,
         R0 BANK# @@ MOV,   \ update the last bank used
         R0 SWPB,           \ swap bytes
         R12 1E00 LI,       \ set SAMS card CRU address
         0 SBO,             \ turn on the card
         R0 CREG @@ MOV,    \ map it
         0 SBZ,             \ turn off card
      ENDIF,
      RT,

CODE CMAP  ( page# --) \ Forth word to map SAMS pages
      TOS RPUSH,    \ need parameter on Rstack
      _CMAP @@ BL,  \ call it
      TOS POP,      \ refill TOS
      NEXT,
ENDCODE

\ run time executor for SAMS colon words.
CODE FARCOL
     *IP  RPUSH,          \ RPUSH Cpage arg from PFA
     *IP+ RPUSH,          \ 2nd copy for _cmap, ADVANCE IP
     _CMAP @@ BL,         \ call _CMAP (uses RSTACK parameter)
     *IP+ IP MOV,         \ fetch SAMS DP & set new IP, *ADVANCE IP*
     NEXT,
ENDCODE

CODE FAREXIT             \ exit for SAMS word
     _CMAP @@ BL,        \ RSTACK has old BANK#, map it in
      IP RPOP,           \ Regular FORTH EXIT
      NEXT,
ENDCODE

\ kernel BRANCH is weird
CODE BRANCH  ( addr -- )  *IP IP MOV,  NEXT, ENDCODE

\ \\\\\\\\\\\\\\\\ code words end  //////////////////

: FAR: ( -- ) \ special colon for words in FAR memory
    \ runtime stuff
     :
     \ FAR header      Data1     Data2
     POSTPONE FARCOL  CPAGE @ , SAMSDP @ ,

   \ compile time stuff
     HERE SAVHERE !     \ save "normal here"
     CPAGE @ CMAP
     SAMSDP @ DP !     \ set Forth DP to SAMSDP. Compiling to SAMS now
     HIDE
     ]                  \ turn on the compiler
;

: ;FAR ( -- ) \ end SAMS compilation. *NEW* compile time memory test
      POSTPONE FAREXIT    \ compiles at end of SAMS code
      POSTPONE [          \ turn compiler off
      REVEAL ?CSP
      HERE DUP SAMSDP !   \ update HERE for this bank, keep a copy
      SAVHERE @ DP !      \ restore DP to CPU RAM
      CSEG 0FF0 + > ABORT" SAMS bank full"
; IMMEDIATE

HEX
: CODEPAGE ( bank# -- )  CPAGE ! ; \ select SAMS page for compiling

: FIRSTUSE
      CPAGE @ CMAP
      CSEG 1000 FF FILL \ fill is for debugging
      CSEG SAMSDP !     \ set the local CSEG DP variable to start of CSEG
;

\ redefine ; and :
: H:  : ;
: ;H  POSTPONE ;  ; IMMEDIATE

H: ;    CPAGE @ 0< IF POSTPONE ;H  ELSE POSTPONE ;FAR  THEN ;H IMMEDIATE
H: :    CPAGE @ 0< IF H:  ELSE FAR:  THEN ;H

HERE SWAP -
DECIMAL CR . .( bytes)

PASSTHRU CMAP  \ init the bank# variable to default memory page

DECIMAL
16 CODEPAGE FIRSTUSE
: HELLO   CR ." Hello SAMS World!"  ;

INCLUDE DSK1.DEFER

17 CODEPAGE FIRSTUSE
: NESTED1  ." nesting 1" ;

18 CODEPAGE FIRSTUSE
: NESTED2  NESTED1  ."  2 "  ;

19 CODEPAGE FIRSTUSE
: NESTED3  NESTED2  ."  3 "  ;
: TEST  CR  NESTED1 CR NESTED2 CR NESTED3  ;
