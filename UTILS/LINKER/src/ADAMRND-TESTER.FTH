


LINK DSK6.ADMANRND,O   \ LINK the object code file into RAM 

GRSEED BLWP DROP   \ blwp to GRSEED and drop the returned value 

\ define a Forth word to call RANDOM 
\  limit it with the DIV instruction and an argument n 
\ "um/mod" means unsigned mixed divide and MOD 
: ARND  ( n )  RANDOM BLWP 0 ROT UM/MOD DROP  ;


\ assign the code ARND to the DEFER word called RND#
: USEADAM ['] ARND IS RND# ;

DECIMAL 
\ : TEST#S  0 ?DO   CR 256 RND# .  192 RND# .  ?TERMINAL ABORT" HALT"  LOOP ;
