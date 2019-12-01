\ magic eight ball Rosetta Code

INCLUDE DSK1.RANDOM
INCLUDE DSK1.FASTCASE

DECIMAL
\ : CASE:  ( -- -7)   CREATE   ;
\ : ;CASE   ( n -- )  DOES>  SWAP CELLS +  @ EXECUTE ;
\
: VECTORS  0  DO  COMPILE, LOOP ;

:NONAME   ." It is certain" ;
:NONAME   ." It is decidedly so" ;
:NONAME   ." Without a doubt" ;
:NONAME   ." Yes, definitely" ;
:NONAME   ." You may rely on it" ;
:NONAME   ." As I see it, yes." ;
:NONAME   ." Most likely" ;
:NONAME   ." Outlook good" ;
:NONAME   ." Signs point to yes." ;
:NONAME   ." Yes." ;
:NONAME   ." Reply hazy, try again" ;
:NONAME   ." Ask again later" ;
:NONAME   ." Better not tell you now" ;
:NONAME   ." Cannot predict now" ;
:NONAME   ." Concentrate and ask again" ;
:NONAME   ." Don't bet on it" ;
:NONAME   ." My reply is no"  ;
:NONAME   ." My sources say no" ;
:NONAME   ." Outlook not so good" ;
:NONAME   ." Very doubtful" ;
( VECTORS for the previous 20 definitions are sitting on the stack ...)

CASE: MAGIC8BALL  20 VECTORS  ;CASE  \ make the case table

: GO   PAGE
       CR ." Please enter your question or a blank line to quit."
       BEGIN CR ." ? :" PAD 80 ACCEPT 0>
       WHILE CR 19 RND MAGIC8BALL CR
       REPEAT ;


