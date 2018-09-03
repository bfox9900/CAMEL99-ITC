\ CAMEL99 psuedo random number generator (PRNG)
\ Taken from TI Forth, converted to machine code.

\ *TI-99 has a counter running when it starts at >83C0 (SEED)
\  The counter stops when you enter the Editor/Assembler menu
\  This gives you a random number in SEED every time you start.

\ With SEED=$1234, RNDW does not repeat for ~20,000 numbers

HEX
83C0 CONSTANT SEED   \ TI incrementing number in main menu

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

