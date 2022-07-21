\ Code in SAMS memory based on concept in TurboForth by Mark Wills
\ Ported to Camel99 Forth  Oct 13, 2021, Last update Mar 2022

\ Features
\ CMAP Remembers the last bank that was paged in variable LASTBNK
\ FAR: is a fat version of "colon" that remember SAMS bank# & SAMS CFA
\ Compiles FARSEMIS on the SAMS side, not in RAM Dictionary
\ - Saves 2 bytes in dictionary and in 2 bytes SAMS definition
\ Compile time SAMS memory overflow test ABORTs if you past 4k bytes

\ FAR word data structure:
\   CELL: link
\   BYTE: immediate field
\   BYTE: name length
\   BYTES: <text...>
\   CELL:  code field
\   CELL:  DATA field #1 , bank#
\   CELL:  DATA field #2 , SAMS code field address
\ 10 bytes + name length

INCLUDE DSK1.TRANSIENT
INCLUDE DSK1.SAMSINI  \ common code for SAMS card

TRANSIENT INCLUDE DSK1.ASM9900

PERMANENT
HERE
HEX
F0 CONSTANT _1STBANK
FF CONSTANT _MAXBANK

\ SAMS memory management for code
HEX              E000 CONSTANT CSEG      \ CODE SEG in CPU RAM
4000 CSEG 0B RSHIFT + CONSTANT CREG      \ compute CSEG SAMS register
CSEG 0C RSHIFT        CONSTANT PASSTHRU  \ default page for CSEG

VARIABLE  SAVHERE   \ temp holder for RAM Dictionary pointer
VARIABLE  BANK#     \ active SAMS bank# for compiling
VARIABLE  LASTBNK   \ last bank# passed to _CMAP

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

HEX
CREATE _CMAP ( R1: 0..255 ) \ **SUB-ROUTINE** NOT FORTH
      R1 LASTBNK @@ CMP,    \ already mapped?
      NE IF,
         R1 LASTBNK @@ MOV, \ update the last bank used
         R1 SWPB,           \ swap bytes
         R12 1E00 LI,       \ DO CMAP
         0 SBO,             \ turn on the card
         R1 CREG @@ MOV,    \ restore bank# from return stack
         0 SBZ,             \ turn off card
      ENDIF,
      RT,

CODE CMAP  ( bank# --) \ Forth word to map SAMS pages
      TOS R1 MOV,
     _CMAP @@ BL,
      TOS POP,
      NEXT,
      ENDCODE

CREATE FARCOL   \ run time executor for SAMS colon words.
     IP RPUSH,
     W IP MOV,
     RP DECT,
     LASTBNK @@ *RP MOV,  \ Rpush the active bank
     *IP+ R1 MOV,         \ fetch bank# from DATA FIELD -> R1, inc IP
     _CMAP @@ BL,         \ & switch to SAMS page for this word
     *IP IP MOV,          \ get SAMS DP & set new IP
     NEXT,

CODE FAREXIT             \ exit for SAMS word
     R1 RPOP,            \ get bank# save by FARCOL
     _CMAP @@ BL,        \ map it in
      IP RPOP,           \ Regular FORTH EXITS
      NEXT,
ENDCODE
\ \\\\\\\\\\\\\\\\ finished with assembler //////////////////
                         DETACH

: FAR: ( -- ) \ special colon for words in FAR memory
     !CSP
     HEADER             \ compile Forth header with name
     FARCOL ,           \ compile the new executor as CFA
     BANK# @ DUP ,      \ compile bank# as the DATA field
      DUP ]DP @ ,       \ compile this word's SAMS address ( ie: FAR XT)

     HERE SAVHERE !     \ save "normal here"

     DUP ]DP @ DP !     \ set dp to CSEG. Compiling goes here now
     ( bank#) CMAP      \ map SAMS for compiling
     HIDE
     ]                  \ turn on the compiler
;

: ;FAR ( -- ) \ end SAMS compilation. *NEW* compile time memory test
      POSTPONE FAREXIT    \ compiles at end of SAMS code
      POSTPONE [          \ turn compiler off
      REVEAL ?CSP
      HERE DUP BANK# @ ]DP !  \ update HERE for this bank, keep the copy
      SAVHERE @ DP !          \ restore DP to CPU RAM
    ( HERE) [ CSEG 1FFF + ] LITERAL > ABORT" SAMS overflow"
; IMMEDIATE

DECIMAL
: CODEPAGE ( bank# -- )  \ 240 .. 256 are valid
      DUP 256 240 WITHIN ABORT" 240..256"
      BANK# !
;

HERE SWAP -
DECIMAL CR . .( bytes)  \ free 11,566

PASSTHRU CMAP  \ init the Forth memory bank# as LASTBNK
HEX
F0 CODEPAGE
