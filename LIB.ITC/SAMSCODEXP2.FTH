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

NEEDS DUMP      FROM DSK1.TOOLS
NEEDS TRANSIENT FROM DSK1.TRANSIENT
NEEDS SAMSINI   FROM DSK1.SAMSINI  \ common code for SAMS card

TRANSIENT
NEEDS MOV,  FROM  DSK1.ASM9900

PERMANENT

HERE
HEX
\ **************[ CHANGE CSEG to your requirements ]******************

HEX              3000 CONSTANT CSEG      \ CODE window in CPU RAM

\ ********************************************************************

\ Derived SAMS memory addresses for code
          CSEG 0FFE + CONSTANT SAMSDP    \ variable at end of SAMS page
4000 CSEG 0B RSHIFT + CONSTANT CREG      \ compute CSEG SAMS register
     CSEG 0C RSHIFT   CONSTANT PASSTHRU  \ default page for CSEG

VARIABLE  SAVHERE   \ temp holder for RAM Dictionary pointer
VARIABLE  PREVPAGE  \ last SAMS bank# selected
VARIABLE  CPAGE     \ active code page used for compiling


HEX
\ **LEAF SUB-ROUTINE**
CREATE _CMAP ( -- ) ( R: page# -- )
      R0 RPOP,              \ POP parameter from Rstack
\      R0 PREVPAGE @@ CMP,      \ already mapped?
\      NE IF,
\         R0 PREVPAGE @@ MOV,   \ update the last bank used
         R0 SWPB,           \ swap bytes
         R12 1E00 LI,       \ set SAMS card CRU address
         0 SBO,             \ turn on the card
         R0 CREG @@ MOV,    \ map it
         0 SBZ,             \ turn off card
\      ENDIF,
      RT,

CODE CMAP  ( page# --) \ Forth word to map SAMS pages
      TOS RPUSH,    \ need parameter on Rstack
      _CMAP @@ BL,  \ call it
      TOS POP,      \ refill TOS
      NEXT,
ENDCODE

\ run time executor for SAMS colon words.
CREATE FARCOL
     IP RPUSH,            \ save the existing IP
     W IP MOV,            \ Set IP to PFA of this word
     CPAGE @@ RPUSH,      \ Rpush the currently active SAMS bank
     *IP+ RPUSH,          \ RPUSH PFA, *ADVANCE IP*
     _CMAP @@ BL,         \ call _CMAP (uses RSTACK parameter)
     *IP+ IP MOV,          \ "GOTO"  SAMS DP parameter
     NEXT,

CODE FAREXIT             \ exit for SAMS word
      R1 STWP,           \ need access USER variable DP.
12 R1 () SAMSDP @@ MOV,  \ DP @ SAMSDP !
     _CMAP @@ BL,        \ RSTACK has old BANK#, map it in
      IP RPOP,           \ Regular FORTH EXIT
      NEXT,
ENDCODE

\ \\\\\\\\\\\\\\\\ code words end  //////////////////

: FAR: ( -- ) \ special colon for words in FAR memory
     !CSP
     HEADER             \ compile Forth header with name
     FARCOL ,           \ compile the new executor as CFA

     CPAGE @ DUP ,      \ compile codepage as the DATA field
     CMAP               \ pull in the SAMS page
     SAMSDP @ DUP ,     \ SAMSDP is this word's IP address

     HERE SAVHERE !     \ save "normal here"
     ( samsdp) DP !     \ set Forth DP to SAMSDP. Compiling to SAMS now
     HIDE
     ]                  \ turn on the compiler
;

: ;FAR ( -- ) \ end SAMS compilation. *NEW* compile time memory test
      POSTPONE FAREXIT    \ compiles at end of SAMS code
      POSTPONE [          \ turn compiler off
      REVEAL ?CSP
      SAVHERE @ DP !      \ restore DP to CPU RAM
      SAMSDP @ CSEG 0FF0 + > ABORT" SAMS bank full"
; IMMEDIATE

HEX
: CODEPAGE ( bank# -- ) CPAGE ! ; \ select SAMS page for compiling

: FIRSTUSE
      CPAGE @ CMAP
      CSEG 1000 FF FILL \ fill is for debugging
      CSEG SAMSDP !     \ set the local CSEG DP variable to start of CSEG
;
                       DETACH \ remove assembler 
HERE SWAP -
DECIMAL CR . .( bytes)

PASSTHRU CMAP  \ init the bank# variable to default memory page

DECIMAL
240 CODEPAGE FIRSTUSE
HERE
FAR: HELLO   CR ." Hello SAMS World!" CR CR  ;FAR
HERE SWAP - .

241 CODEPAGE FIRSTUSE
FAR: NESTED1  CR ." 1 " ;FAR

242 CODEPAGE FIRSTUSE
FAR: NESTED2   NESTED1 ." 2 " ;FAR

243 CODEPAGE FIRSTUSE
FAR: NESTED3  NESTED2  ." 3 "  HELLO ;FAR

244 CODEPAGE FIRSTUSE
FAR: GO   HELLO  NESTED3  ;FAR

241 CODEPAGE
FAR: BIGONE   GO  ;FAR
