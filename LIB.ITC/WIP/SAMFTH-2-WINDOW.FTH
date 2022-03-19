\ SAMS CARD support for CAMEL99 Forth in Forth May 2020  B Fox
\ 64K segmented memory fetch and store using 2 SAMS windows

NEEDS ELAPSE FROM DSK1.ELAPSE
NEEDS BLOCK FROM DSK1.SBLOCKS

 VARIABLE SEG
\ safely set the 64K segment that you want to use
HEX
: SEGMENT ( 1..F -- ) \ don't allow segment 0
         DUP 01 10 WITHIN 0= ABORT" SAMS segment err"
         SEG ! ;
 1 SEGMENT

HEX
\ : PAGED  ( virtual-addr -- real-addr)
\         SEG @ 1000 UM/MOD ( -- offset bank#) BLOCK + ;

CODE >SMEM ( addr -- offset bank#)
      TOS  R0 MOV,
      R0 0FFF ANDI,   \ mask upper 4 bits
           R0 PUSH,   \ push offset to memory stack
     TOS F000 ANDI,
    SEG @@ R0 MOV,
         R0 4 SLA,
      TOS  0C SRL,    \ divide by 4096
      R0  TOS ADD,
              NEXT,
ENDCODE                  \ 222 cycles
: PAGED  >SMEM BLOCK + ;  \ 18% FASTER than using UM/MOD 

HEX
: WRITER  FFFF 0 DO   I  I PAGED !  2 +LOOP ;
: FILLER  FFFF 0 DO   I PAGED 1000 A FILL    1000 +LOOP ;
