\ GForth Random number method, modified for CAMEL Forth BJF Sept 5 2018

HEX 
\  83C0 CONSTANT RND#    \ TI incrementing number in main menu
\ 6FE5 CONSTANT PRIME#
: SEED      ( n -- )        83C0 ! ;
: RNDW      ( -- n )        6FE5 83C0 @  *  1+ DUP SEED ;
: RND       ( n -- 0..n-1 ) RNDW UM* NIP ;

\ byte from the timer and screen saver timer, combine as new SEED
: RANDOMIZE  ( -- )  8379 C@  83D7 C@ FUSE SEED ;

\ 1235 SEED  ( comment out if you want rnd# from main menu)
