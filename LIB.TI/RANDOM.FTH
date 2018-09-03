\ CAMEL99 psuedo random number generator (PRNG)
\ Taken from TI Forth, converted to machine code.

\ *TI-99 has a counter running when it starts at >83C0 (SEED)
\  The counter stops when you enter the Editor/Assembler menu
\  This gives you a random number in SEED every time you start.

\ With SEED=$1234, RNDW does not repeat for ~20,000 numbers

HEX
83C0 CONSTANT SEED   \ RAM where TI has a number incrementing in main menu

\ CODE SRC    ( n bits -- n')
\            C004 ,  \  TOS R0  MOV,
\            C136 ,  \ *SP+ TOS MOV,
\            0B04 ,  \  TOS R0  SRC,
\            NEXT,
\            ENDCODE

\ : RNDW   ( -- n) SEED @ 6FE5 * 7AB9 +  5 SRC DUP SEED ! ; \ 28 bytes + SRC

 CODE RNDW    ( -- n)
             0646 ,        \ TOS PUSH,
             C584 ,
             C0E0 , 83C0 , \ SEED @@ R3 MOV,
             0202 , 6FE5 , \ R2 6FE5  LI,
             38C2 ,        \ R2  R3   MPY,
             0224 , 7AB9 , \ TOS 7AB9 AI,
             0B54 ,        \ TOS 5 SRC,
             C804 , 83C0 , \ TOS SEED @@ MOV,
             NEXT,
             ENDCODE   \ 24 bytes

: RANDOMIZE ( n -- )   SEED ! ;
: RND       ( n -- n') RNDW ABS SWAP MOD ;

