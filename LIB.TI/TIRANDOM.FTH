\ CAMEL99 psuedo random number generator (PRNG)
\ TI Forth method using circular shift, converted to machine code.

\ With SEED=$1234, RNDW does not repeat for ~20,000 numbers

HEX
83C0 CONSTANT RND#  \ TI incrementing number in main menu

 CODE RNDW    ( -- n)
             0646 , C584 , \ TOS PUSH,
             C0E0 , RND# , \ SEED @@ R3 MOV,
             0202 , 6FE5 , \ R2 6FE5  LI,
             38C2 ,        \ R2  R3   MPY,
             0224 , 7AB9 , \ TOS 7AB9 AI,
             0B54 ,        \ TOS 5 SRC,
             C804 , RND# , \ TOS SEED @@ MOV,
             NEXT,
             ENDCODE   \ 24 bytes

: RND    ( n -- n') RNDW ABS SWAP MOD ;
: SEED   ( n -- )  RND# ! ;
: RANDOMIZE  ( -- )  8379 C@  83D7 C@ FUSE SEED ;

1235 SEED
