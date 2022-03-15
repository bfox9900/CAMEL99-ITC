\ Code in SAMS memory based on concept in TurboForth by Mark Wills
\ Ported to Camel99 Forth  Oct 13, 2021, Re-write Oct 2021

\ Changes from original:
\ Remove bank stack.  Used return stack for bank# storage
\ Removed BANKS word. Changed to preset DP array
\ CMAP is a fast sub-routine for mapping SAMS pages F0..FF
\ CMAP Remembers the last bank that was paged in variable LASTBNK
\ Changed to compile a far "colon" definition to reduce dictionary overhead

\ Oct 13, 2021  Remove GOTO in FAR exit. Not needed.
\               Compile FARSEMIS on the SAMS side, not in RAM Dictionary
\               Saves 2 bytes in dictionary and in 2 bytes SAMS definition

\ Dec 16, 2021  Compiles with LOWTOOLS for CODE words, then remove tools
\               Compile time SAMS memory overflow test added

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
INCLUDE DSK1.SAMSINI
INCLUDE DSK1.TOOLS

HEX 2000 TRANSIENT
INCLUDE DSK1.ASM9900


HERE
HEX
F0 CONSTANT _1STBANK
FF CONSTANT _MAXBANK

\ SAMS memory management for code
HEX              E000 CONSTANT CSEG      \ code seg in CPU RAM
4000 CSEG 0B RSHIFT + CONSTANT CREG      \ compute CSEG SAMS register
CSEG 0C RSHIFT        CONSTANT PASSTHRU  \ default page for CSEG

VARIABLE  SAVHERE   \ temp holder for RAM Dictionary pointer
VARIABLE  BANK#     \ active SAMS bank# for compiling
VARIABLE  LASTBNK   \ last bank# passed to MAPPER

DECIMAL
CREATE []DP  \ DP for 0 .. 15 pages of SAMS
CSEG , CSEG , CSEG , CSEG  ,
CSEG , CSEG , CSEG , CSEG  ,
CSEG , CSEG , CSEG , CSEG  ,
CSEG , CSEG , CSEG , CSEG  ,


 PERMANENT
HEX
CODE ]DP ( bank# -- addr )
     TOS _1STBANK NEGATE  AI,  \ remove first bank offset to index []DP
     TOS TOS ADD,
     TOS []DP AI,
     NEXT,
ENDCODE

HEX
CREATE MAPPER ( R1: 0 .. 16 )  \ smart MAPPER
      R1 LASTBNK @@ CMP,  \ already mapped?
      NE IF,
         R1 LASTBNK @@ MOV,  \ update the last bank used
         R1 SWPB,          \ swap bytes
         R12 1E00 LI,      \ DO CMAP
         0 SBO,            \ turn on the card
         R1 CREG @@ MOV,   \ restore bank# from return stack
         0 SBZ,            \ turn off card
      ENDIF,
      RT,

CODE CMAP  ( bank# --) \ Forth word to map SAMS pages
      TOS R1 MOV,
      MAPPER @@ BL,
      TOS POP,
      NEXT,
      ENDCODE

CREATE FARCOL   \ run time executor for SAMS colon words.
     IP RPUSH,
     W IP MOV,
     RP DECT,
     LASTBNK @@ *RP MOV,  \ Rpush the active bank
     *IP+ R1 MOV,         \ fetch bank# from DATA FIELD -> R1, inc IP
     MAPPER @@ BL,        \ & switch to SAMS page for this word
     *IP IP MOV,          \ get SAMS DP & set new IP
     NEXT,

CODE FAREXIT             \ exit for SAMS word
     R1 RPOP,            \ get bank# save by FARCOL
     MAPPER @@ BL,       \ map it in
     IP RPOP,            \ Regular FORTH EXIT
     NEXT,
ENDCODE


: FAR: ( -- ) \ special colon for words in FAR memory
     !CSP
     HEADER             \ compile Forth header with name
     FARCOL ,           \ compile the new executor as CFA
     BANK# @
      DUP ,             \ compile bank# as the DATA field
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
      HERE                \ remember SAMS dictionary position
      DUP BANK# @ ]DP !   \ update HERE for this bank, keep the copy
      SAVHERE @ DP !      \ restore dp to CPU RAM
    ( HERE) [ CSEG 1FFF + ] LITERAL > ABORT" SAMS overflow"
; IMMEDIATE

DECIMAL
: CODEPAGE ( bank# -- )  \ 0..15 are valid args
      DUP 256 240 WITHIN ABORT" 240..256"
      BANK# !
;

HERE SWAP -
DECIMAL CR . .( bytes)  \ free 11,566

PASSTHRU CMAP  \ init the Forth memory bank# as LASTBNK
HEX
F0 CODEPAGE

\ \\\\\\\\\\\ don't need assembler now ////////////
                  ERADICATE
