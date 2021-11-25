\ BLOCK  as a method to manage SAMS pages    Jan 15 2021 Brian Fox

\ NEEDS .S   FROM DSK1.TOOLS
\  NEEDS MOV, FROM DSK1.ASM9900

MARKER REMOVE

HERE

DECIMAL
 24 USER 'R12  \ address of R12 in any Forth workspace

HEX
: SAMSCARD  ( -- ) 1E00 'R12 ! ;   \ select sams card
\ using machine code so we don't need the CRU library
HEX
\ *set the CRU address in 'R12 before using these words*
  CODE 0SBO  ( -- ) 1D00 ,  NEXT, ENDCODE
  CODE 0SBZ  ( -- ) 1E00 ,  NEXT, ENDCODE
  CODE 1SBO  ( -- ) 1D01 ,  NEXT, ENDCODE
  CODE 1SBZ  ( -- ) 1E01 ,  NEXT, ENDCODE

: SAMS-ON   ( -- ) SAMSCARD 1SBO ;  \ enable mapper
: SAMS-OFF  ( -- ) SAMSCARD 1SBZ ;  \ disable mapper

\ * SAMSINI sets card to "pass-through" condition. REAL hardware only
: SAMSINI
       SAMSCARD          \ select SAMS card
       0SBO              \ turn card on
       0                 \ register value stays on stack
       4000 20           \ register address, # SAMS regs
       BOUNDS ( -- 4100 4000)
       DO
           DUP I !       \ I is reg. address
           I @ OVER <> ABORT" SAMSINI err"
           0101 +        \ next value 0101 for 1MB card, 0100 Classic99
       2 +LOOP
       0SBZ              \ turn off card
       DROP
;

\ ==========================================
\ BLOCK is the entire SAMS manager
HEX
VARIABLE USE
CREATE BLK#S       0 ,    0 ,      \ SAMS page in the buffer
CREATE WINDOWS  2000 , 3000 ,      \ windows in Low CPU RAM

CODE BLOCK ( bank -- buffer)
 0200 , BLK#S ,
 8110 ,
 1603 ,
    0204 , 2000 ,
    045A ,
 05C0 ,
 8110 ,
 1603 ,
     0204 , 3000 ,
     045A ,
 0208 , 0001 ,
 2A20 , USE ,
 C808 , USE ,
 A208 ,
 CA04 , BLK#S ,
 C068 , WINDOWS ,
 09B1 ,
 0221 , 4000 ,
 020C , 1E00 ,
 1D00 ,
 06C4 ,
 C444 ,
 1E00 ,
 C128 , WINDOWS ,
 NEXT,
 ENDCODE

 VARIABLE SEG
\ safely set the 64K segment that you want to use
 : SEGMENT ( 1..F -- ) \ don't allow segment 0
         DUP 01 10 WITHIN 0= ABORT" SAMS segment err"
         SEG ! ;
 1 SEGMENT

 HEX
 : PAGED  ( virtual-addr -- real-addr)
         SEG @ 1000 UM/MOD ( -- offset bank#) BLOCK + ;

HERE SWAP - DECIMAL  CR .  .( bytes)
