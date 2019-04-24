\ ========================================================================
\ D I R E C T   M E M O R Y   O P E R A T I O N S
\ TMS9900 indirect addressing mode we can do things faster to variables
\ by transfering: memory->memory  verus  memory->stack->memory

\ * THESE ARE EXAMPLES. DO NOT LOAD THEM ALL UNLESS YOU NEED THEM ALL *

INCLUDE DSK1.TOOLS.F
INCLUDE DSK1.ASM9900.F

CR
CR .( ** MEMORY TO MEMORY OPERATIONS ** )
CR

: *R0    R0 ** ;
: *R1    R1 ** ;

CODE 1+!    ( addr -- )   \ forth: 1 X +!  6 bytes/use
             *TOS INC,    \ 38% faster  4 bytes/use
              TOS POP,
              NEXT,
              ENDCODE

CODE 1-!    ( addr -- )
             *TOS DEC,  \ 38% faster 4 bytes/use
              TOS POP,
              NEXT,
              ENDCODE
              
CODE @+!   ( addr addr2 -- ) \ Forth: X @ Y +!
            *SP+ R1 MOV,     \ only 9% speedup :-(
            *R1 *TOS ADD,
             TOS POP,
             NEXT,
             ENDCODE
             
CODE @-!   ( addr addr2 -- )  \ *addr2==*addr2-*addr
             *SP+  R1 MOV,    
             *R1 *TOS SUB,
              TOS POP,
              NEXT,
              ENDCODE

CODE INCT!    ( addr -- ) \ forth: 2 X +!  6 bytes/use
             *TOS  INCT,  \ 38% faster  4 bytes/use
              TOS POP,
              ENDCODE

CODE DECT!    ( addr -- ) \ forth: -2 X +!  6 bytes/use
             *TOS  DECT,  \ 38% faster  4 bytes/use
              TOS POP,
              ENDCODE

\ AND! is   X @ 00FF AND  X !  13 bytes/use
CODE AND!   ( u adr -- )
             *SP INV,        \ Usage: 00FF X AND!
             *SP+ *TOS SZC,  \ 60% faster 8 bytes/use
              TOS POP,
              NEXT,
              ENDCODE

CODE OR!    ( u adr -- )
             *SP+ *TOS SOC,  \ 60% faster 8 bytes/use
              TOS POP,
              NEXT,
              ENDCODE

CODE XOR!   ( u adr -- )
             *SP+ *TOS XOR,  \ 60% faster 8 bytes/use
              TOS POP,
              NEXT,
              ENDCODE

CODE INV!   ( adr -- )
             *TOS INV,
              TOS POP,
              NEXT,
              ENDCODE

CODE ABS!   ( adr -- )
             *TOS ABS,
              TOS POP,
              NEXT,
              ENDCODE

CODE NEG!  ( adr -- )
             *TOS NEG,
              TOS POP,
              NEXT,
              ENDCODE


\ : XCHG1     OVER @  OVER @  SWAP ROT !  SWAP ! ;  (18bytes)

\  X Y XCHG1  is 703uS
\  X Y XCHG   IS 256 uS   270% faster
CODE XCHG   ( adr1 adr2 -- ) \ exchange values of 2 variables
             *SP+  R0 MOV,    \ pop adr1 into R0             22
             *R0   W  MOV,    \ adr1 @  W  !                 18
             *TOS *R0 MOV,    \ mem2me m move  adr2 to adr1  22
              W  *TOS MOV,    \ move value adr1 to adr2      18
              TOS POP,        \                              22
              NEXT,           \ 10 bytes                     92 clocks
              ENDCODE
