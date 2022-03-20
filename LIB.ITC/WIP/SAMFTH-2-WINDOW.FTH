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
\ : PAGED  ( virtual-addr -- real-addr)
\         SEG @ 1000 UM/MOD ( -- offset bank#) BLOCK + ;

\ 18% FASTER than using UM/MOD
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

: PAGED ( virtual_address -- real_address ) >VIRT BLOCK + ;

HEX
: WRITER    FFFF 0 DO   I  I PAGED !  2 +LOOP ; \ write 32K words to memory

: 64KFILL   FFFF 0 DO   I PAGED 1000 A FILL    1000 +LOOP ;

: SAMSFILL ( addr1 size byte -- )
            -ROT
            BOUNDS
            ?DO
                DUP I PAGED C!
            LOOP ;

: SAMSMOVE ( addr1 addr2 size --)
            BOUNDS
            DO
                DUP PAGED I PAGED !
            2 +LOOP
            DROP ;

: SAMSCMOVE ( addr1 addr2 size --)
            BOUNDS
            DO
                DUP PAGED I PAGED C!
            LOOP
            DROP ;