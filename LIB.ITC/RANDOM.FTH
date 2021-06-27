\ GForth Random number method, modified for CAMEL Forth BJF Sept 5 2018
HEX
\ 6FE5 CONSTANT PRIME#
 83C0 CONSTANT SEED   \ TI incrementing number in main menu,
\ SEEDS stops spinning when Forth starts
\ : RNDW  ( -- n ) 6FE5 SEED @  *  1+ DUP SEED ! ; \ 16 bytes
CODE RNDW    ( -- n)    \ Code version if you need speed
              TOS PUSH,
              SEED @@ R3 MOV,
              R2 6FE5 LI,
              R2 R3 MPY,
              TOS INC,
              TOS SEED @@ MOV,
              NEXT,
              ENDCODE   \ 24 bytes

: RND   ( n -- 0..n-1 ) RNDW UM* NIP ;

\ byte from the timer and screen saver timer, combine as new SEED
: RANDOMIZE  ( -- )  8379 C@  83D7 C@ FUSE SEED ! ;

\ USE:  1235 SEED !  to make repeatable random numbers
