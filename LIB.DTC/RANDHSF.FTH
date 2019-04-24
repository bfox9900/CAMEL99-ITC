\ random number generator adapted from HS/Forth
\ Jim Kalihan 1990 (R.I.P.)

HEX
VARIABLE A
VARIABLE B
VARIABLE MX

: SEEDS   ( -- )   1 A !   7 B !  03FF MX ! ;

: RANDOM  ( -- n)
        A @ B @ +  MX @ OVER U<
        IF  MX @ 1+ -   THEN
        2* MX @ OVER U<
        IF   MX @ -   THEN  
        B @  A !   DUP B ! ;

: RANDOMIZE  ( seed1 seed2 #bits -- )
           2 MAX 0F MIN
           1 SWAP LSHIFT 1-  MX !
           MX @ MOD A !
           MX @ MOD B !
           5 0
           DO
              RANDOM DROP
           LOOP ; 

\ returns a random number between 0 .. n-1
: RND  ( n -- n )  RANDOM SWAP MOD ;
