\ CAMEL99 psuedo random number generator (PRNG)
\ concept from Gforth, modified for our little CAMEL99 system

\ *TI-99 has a counter running when it starts at >83C0 (SEED)
\  The counter stops when you enter the Editor/Assembler menu
\  This gives you a random number in SEED every time you start.

\ This PRNG does not repeat for 2^16 numbers

HEX
83C0 CONSTANT SEED   \ RAM where TI has a number incrementing in main menu
1045 CONSTANT GEN#   \ 1/2 of the number from GForth. Seems to work well

: RNDW      ( -- n )   SEED @ GEN# UM* DROP 1+ DUP SEED ! ;
: RANDOMIZE ( n -- )   SEED ! ;
: RND       ( n -- n') RNDW ABS SWAP MOD ;

