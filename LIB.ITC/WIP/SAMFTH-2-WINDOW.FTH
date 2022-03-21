\ SAMS CARD support for CAMEL99 Forth in Forth Mar 19 2022  Brian Fox
\ 64K segmented memory fetch and store using 2 SAMS windows
\ Two windows in RAM allows SAMS2SAMS

NEEDS MOV,   FROM DSK1.ASM9900
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
\ : >VIRT  ( virtual-addr -- real-addr)
\         SEG @ 1000 UM/MOD ( -- offset bank#) BLOCK + ;

\ 18% FASTER than using Forth and UM/MOD
CODE >VIRT ( addr -- offset bank#)  \ 222 cycles!
      TOS  R0 MOV,
      R0 0FFF ANDI,   \ mask upper 4 bits
           R0 PUSH,   \ push offset to memory stack
     TOS F000 ANDI,
    SEG @@ R0 MOV,
         R0 4 SLA,
      TOS  0C SRL,    \ divide by 4096
      R0  TOS ADD,
              NEXT,
ENDCODE

: >SAMS ( virtual_address -- real_address ) >VIRT BLOCK + ;

: @L    ( addr -- )  S" >SAMS @"  EVALUATE ; IMMEDIATE
: !L    ( addr -- )  S" >SAMS !"  EVALUATE ; IMMEDIATE
: C@L   ( addr -- )  S" >SAMS C@" EVALUATE ; IMMEDIATE
: C!L   ( addr -- )  S" >SAMS C@" EVALUATE ; IMMEDIATE

: SAMSFILL  ( addr size byte -- ) -ROT BOUNDS ?DO   DUP I C!L    LOOP ;
: SAMSFILLW ( addr size byte -- ) -ROT BOUNDS ?DO   DUP I !L    2 +LOOP ;

: SAMSMOVE ( addr1 addr2 size --)
  BOUNDS DO   DUP >SAMS I !L   2 +LOOP DROP ;

: SAMSCMOVE ( addr1 addr2 size --)
  BOUNDS DO   DUP >SAMS I C!L   LOOP DROP ;

: SAMSBLOCKFILL ( blk1 blk2 byte --)
  -ROT ?DO   DUP I BLOCK 1000 ROT FILL  LOOP DROP ; 
