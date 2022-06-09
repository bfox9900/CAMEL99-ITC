\ ========================================================================
\ D I R E C T   M E M O R Y   O P E R A T I O N S
\ TMS9900 indirect addressing mode we can do things faster to variables
\ by transfering: memory->memory  verus  memory->stack->memory
\ or by doing a function on the memory itself rather than via TOS register.

\ * THESE ARE EXAMPLES. DO NOT LOAD THEM ALL UNLESS YOU NEED THEM ALL *

NEEDS DUMP  FROM DSK1.TOOLS
NEEDS MOV, FROM DSK1.ASM9900

CR
CR .( ** MEMORY TO MEMORY OPERATIONS ** )
CR

: /CODE    NEXT, ENDCODE  ;

: *R0    R0 ** ;
: *R1    R1 ** ;

\ forth: 1 X +!  6 bytes/use. 38% faster  4 bytes/use
CODE 1+!    ( addr -- ) *TOS INC,  TOS POP,  /CODE

CODE 1-!    ( addr -- ) *TOS DEC,  TOS POP,  /CODE
              \ 38% faster 4 bytes/use

CODE 2*!   ( addr )  *TOS 1 SLA,  /CODE
CODE 2/!   ( addr )  *TOS 1 SRA,  /CODE

CODE 4*!   ( addr )  *TOS 2 SLA,  /CODE
CODE 4/!   ( addr )  *TOS 2 SRA,  /CODE

CODE 8*!   ( addr )  *TOS 3 SLA,  /CODE
CODE 8/!   ( addr )  *TOS 3 SRA,  /CODE

CODE @+!   ( addr addr2 -- ) \ Forth: X @ Y +!  only 9% speedup :-(
            *SP+ R1 MOV,  *R1 *TOS ADD, TOS POP,  /CODE


CODE @-!   ( addr addr2 -- )  \ *addr2==*addr2-*addr
             *SP+  R1 MOV,  *R1 *TOS SUB, TOS POP, /CODE

\ forth: 2 X +!  6 bytes. CODE 38% faster 4 bytes
CODE INCT!    ( addr -- ) *TOS  INCT, TOS POP, /CODE
CODE DECT!    ( addr -- ) *TOS  DECT, TOS POP, /CODE

\ AND! is   X @ 00FF AND  X !  13 bytes/use  Usage: 00FF X AND!
\ 60% faster 8 bytes
CODE AND!   ( u adr -- ) *SP INV,      *SP+ *TOS SZC, TOS POP, /CODE
CODE OR!    ( u adr -- ) *SP+ *TOS SOC                TOS POP, /CODE
CODE XOR!   ( u adr -- ) *SP+ *TOS XOR,               TOS POP, /CODE
CODE INV!   ( adr -- )  *TOS INV,                     TOS POP, /CODE
CODE ABS!   ( adr -- )  *TOS ABS,                     TOS POP, /CODE
CODE NEG!  ( adr -- )   *TOS NEG,                     TOS POP, /CODE


CODE :=    *SP+ R0 MOV,  R0 ** TOS ** MOV,            TOS POP, /CODE

\ : XCHG1     OVER @  OVER @  SWAP ROT !  SWAP ! ;  (18bytes)

\  X Y XCHG1  is 703uS
\  X Y XCHG   IS 256 uS   270% faster
CODE XCHG   ( adr1 adr2 -- ) \ exchange values of 2 variables
             *SP+  R0 MOV,    \ pop adr1 into R0             22
             *R0   W  MOV,    \ adr1 @  W  !                 18
             *TOS *R0 MOV,    \ mem2me m move  adr2 to adr1  22
              W  *TOS MOV,    \ move value adr1 to adr2      18
              TOS POP,        \                              22
              /CODE           \ 10 bytes                     92 clocks
