\ GForth Random number method, modified for CAMEL Forth BJF Sept 5 2018

HEX 83C0 CONSTANT RND#  \ TI incrementing number in main menu

DECIMAL 28649 ( 6FE5) CONSTANT PRIME#  ( PRIME number)

: SEED      ( n -- )        RND# ! ;
: RNDW      ( -- n )        PRIME#  RND# @  UM* DROP 1+ DUP SEED ;
: RND       ( n -- 0..n-1 ) RNDW UM* NIP ;

HEX
: RANDOMIZE  ( -- )  8379 C@  83D7 C@ FUSE SEED ;

 1235 SEED  ( COMMENT OUT IF YOU WANT RND# FROM MAIN MENU)

