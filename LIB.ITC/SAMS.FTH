CR .( SAMS CARD support Faster primitives.  Jan 2026 Brian Fox )
CR .( 64K segments !L C!L @L C@L )

\ 1 "windiw" only.  Set to >3000 by PMEM (paged memory)
\ This version is over 3X faster than the version in SAMSFTH.Fth

\ NEEDS .S FROM DSK1.TOOLS
\ NEEDS MOV. FROM DSK1.ASM9900
NEEDS SAMSINI FROM DSK1.SAMSINI

HERE
HEX
     VARIABLE BANK#      \ current mapped bank
     VARIABLE SEG        \ holds current 64K segment

3000 CONSTANT PMEM       \ VIRT>REAL memory block location
\ compute SAMS register based on PMEM address
PMEM 0B RSHIFT 4000 + CONSTANT SREG

\ safely set the 64K segment that you want to use
: SEGMENT ( 1..F -- )
       DUP 01 10 WITHIN 0= ABORT" SAMS segment err"
       SEG ! ;  \ don't allow segment 0

1 SEGMENT

HEX
CREATE _REAL  ( virtaddr -- real_address ) \ native sub-routine
!CSP
\ Lee Stewart's code to replace >1000 UM/MOD. 2.3% faster
     C020 , SEG ,   \ SEG @@ R0 MOV,    \ segment# to R0
     0A40 ,         \ R0 4 SLA,         \ page# segment starts
     C144 ,         \ R4 R5 MOV,        \ address to R5
     0245 , 0FFF ,  \ R5  0FFF ANDI,    \ page offset
     09C4 ,         \ R4 0C SRL,        \ page of current segment
     A100 ,         \ R0 R4 ADD,        \ bank#
     8804 , BANK# , \ R4 BANK# @@ CMP,    \ page in RAM?
     1309 ,         \ NE IF,
     C804 , BANK# , \    R4 BANK# @@ MOV, \ No. update BANK#
     06C4 ,         \    R4 SWPB,
     020C , 1E00 ,  \    R12 1E00 LI,      \ select SAMS
     1D00 ,         \    0 SBO,            \ card on
     C804 , SREG ,  \    R4 SREG @@ MOV,   \ map the page
     1E00 ,         \    0 SBZ,            \ card off
                    \ ENDIF,
     0204 , PMEM ,  \ R4 PMEM LI,         \ page_mem->tos
     A105 ,         \ R5  R4 ADD,         \ add computed offset to page
     045B ,         \ *R11 B,             \ Return via R11
?CSP  ( test for garage on the stack )

: CALL,     06A0 ,   ,  ;  \ machine forth helper

CODE VIRT>REAL ( virtual -- real ) _REAL CALL,  NEXT, ENDCODE

\ VIRT>REAL memory fetch and store from SAMS segment. Macros 2x faster
HEX
CODE !L ( n virtual -- )
 06A0 , _REAL , \ _REAL  @@ BL,
 C536 , \   *SP+ *TOS MOV,
 C136 , \   TOS POP,
 NEXT,
ENDCODE

CODE C!L   ( c virtual -- )
 06A0 , _REAL , \ _REAL  @@ BL,
 D526 , 0001 ,  \ 1 (SP) *TOS MOVB,
 05C6 ,         \  SP  INCT,
 C136 ,         \  TOS POP,
 NEXT,
ENDCODE

CODE @L ( virtural -- n)
    06A0 , _REAL ,  \ _REAL  @@ BL,
    C114 ,          \ *TOS TOS MOV,
    NEXT,
ENDCODE

CODE C@L ( virtual -- c)
    06A0 , _REAL , \ _REAL  @@ BL,
    D114 ,         \ *TOS TOS MOVB,
    0984 ,         \  TOS 8   SRL,
    NEXT,
ENDCODE

CR HERE SWAP - DECIMAL . .( bytes)


SAMS-OFF SAMSINI SAMS-ON
\ segment '0' is the default TI-99 memory.
\ We leave that alone and use segment 1 ie: the 2nd 64K chunk
1 SEGMENT

CR .( SAMS card activated)
CR .( Window = ) PMEM HEX U.
CR .( Segment = ) SEG @  DECIMAL U.
CR
