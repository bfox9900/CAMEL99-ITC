\ Code in SAMS memory based on concept in TurboForth by Mark Wills
\ Ported to Camel99 Forth  Oct 13, 2021, Last update Mar 2022

\ Features
\ CMAP Remembers the last bank that was paged in variable LASTBNK
\ FAR: is a fat version of "colon" that remember SAMS bank# & SAMS CFA
\ Compiles FARSEMIS on the SAMS side, not in RAM Dictionary
\ - Saves 2 bytes in dictionary and in 2 bytes SAMS definition
\ Compile time: SAMS memory overflow test ABORTs if you past 4k bytes

\ FAR word data structure:
\   CELL: link
\   BYTE: immediate field
\   BYTE: name length
\   BYTES: <text...>
\   CELL:  code field
\   CELL:  DATA field #1 , bank#
\   CELL:  DATA field #2 , SAMS code field address
\ 10 bytes + name length

NEEDS DUMP      FROM DSK1.TOOLS
NEEDS SAMSINI   FROM DSK1.SAMSINI  \ common code for SAMS card

HERE
HEX
F0 CONSTANT _1STBANK
FF CONSTANT _MAXBANK

\ SAMS memory management for code
HEX              3000 CONSTANT CSEG      \ CODE SEG in CPU RAM
4000 CSEG 0B RSHIFT + CONSTANT CREG      \ compute CSEG SAMS register
CSEG 0C RSHIFT        CONSTANT PASSTHRU  \ default page for CSEG

VARIABLE  SAVHERE   \ temp holder for RAM Dictionary pointer
VARIABLE  BANK#     \ active SAMS bank# for compiling

DECIMAL
CREATE []DP  \ DP for 0 .. 15 pages of SAMS
      CSEG , CSEG , CSEG , CSEG  ,
      CSEG , CSEG , CSEG , CSEG  ,
      CSEG , CSEG , CSEG , CSEG  ,
      CSEG , CSEG , CSEG , CSEG  ,

HEX
CODE ]DP ( bank# -- addr )
     TOS _1STBANK NEGATE  AI,  \ remove _1STBANK offset to index []DP
     TOS TOS ADD,              \ CELLS
     TOS []DP AI,
     NEXT,
ENDCODE

: SAMSHERE  BANK# @ ]DP @ ; \ end of SAMS dictionary

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

CODE CMAP  ( bank# --) \ Forth word to map SAMS pages
      TOS RPUSH,    \ need parameter on Rstack
      _CMAP @@ BL,  \ call it
      TOS POP,      \ refill TOS
      NEXT,
ENDCODE

\ run time executor for SAMS colon words.
CREATE FARCOL
     IP RPUSH,
     W IP MOV,            \ IP=PFA of this word
     BANK# @@ RPUSH,      \ Rpush the currently active SAMS bank
     *IP+ RPUSH,          \ fetch bank# in PFA & save on return stack
     _CMAP @@ BL,         \ call _CMAP (using RSTACK parameter)
     *IP IP MOV,          \ get SAMS DP & set new IP
     NEXT,

CODE FAREXIT             \ exit for SAMS word
     _CMAP @@ BL,        \ RSTACK has BANK#, map it in
      IP RPOP,           \ Regular FORTH EXITS
      NEXT,

ENDCODE
\ \\\\\\\\\\\\\\\\ finished with assembler //////////////////

: FAR: ( -- ) \ special colon for words in FAR memory
     !CSP
     HEADER             \ compile Forth header with name
     FARCOL ,           \ compile the new executor as CFA
     BANK# @ DUP ,      \ compile bank# as the DATA field
      DUP ]DP @ ,       \ compile this word's SAMS address ( ie: FAR XT)

     HERE SAVHERE !     \ save "normal here"

     DUP ( bank#) CMAP  \ map SAMS page for compiling
     ]DP @ DP !         \ set Forth DP to CSEG DP. Compiling goes here now
     HIDE
     ]                  \ turn on the compiler
;

: ;FAR ( -- ) \ end SAMS compilation. *NEW* compile time memory test
      POSTPONE FAREXIT    \ compiles at end of SAMS code
      POSTPONE [          \ turn compiler off
      REVEAL ?CSP
      HERE DUP BANK# @ ]DP !  \ update HERE for this bank, keep a copy
      SAVHERE @ DP !          \ restore DP to CPU RAM
    ( HERE) [ CSEG 1FFF + ] LITERAL > ABORT" SAMS bank full"
; IMMEDIATE

DECIMAL
: CODEPAGE ( bank# -- )  \ 240 .. 256 are valid
      DUP 256 240 WITHIN ABORT" 240..256"
      DUP BANK# !
;

HERE SWAP -
DECIMAL CR . .( bytes)  \ free 11,566

PASSTHRU CMAP  \ init the Forth memory bank#
HEX
_1STBANK CODEPAGE

FAR: HELLO   CR ." This should work"  ;FAR
