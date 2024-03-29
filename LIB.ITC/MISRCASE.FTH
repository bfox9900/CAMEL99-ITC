\ Miser's Case
\ http://dxforth.mirrors.minimaltype.com/miser.html#CONTINUE
\ A general purpose Forth case statement.
\
\ Revision  2014-03-08
\ Edited for Camel99 Forth   Mar 30 2021 Fox

HERE
0 CONSTANT COND  IMMEDIATE

: THENS   BEGIN  ?DUP WHILE  POSTPONE THEN  REPEAT ; IMMEDIATE

\ Camel Forth, Swiftforth
: WHEN      POSTPONE ELSE  >R  POSTPONE THENS  R>  POSTPONE DROP ; IMMEDIATE
: CONTINUE  >R  POSTPONE THENS  POSTPONE COND  R> ; IMMEDIATE
: EQUAL   POSTPONE OVER  POSTPONE <>  POSTPONE IF ; IMMEDIATE

\ : (RANGE)    2 PICK -ROT OVER - -ROT - U< ;
: (RANGE)  1+ WITHIN ;
: RANGE   POSTPONE (RANGE)  POSTPONE IF ; IMMEDIATE
: OF      POSTPONE OVER  POSTPONE =  POSTPONE IF  POSTPONE DROP ; IMMEDIATE

\ Forth-94 compatibility words
: CASE     POSTPONE COND ; IMMEDIATE
: ENDOF    POSTPONE ELSE ; IMMEDIATE
: ENDCASE  POSTPONE DROP  POSTPONE THENS ; IMMEDIATE

HERE SWAP -  DECIMAL . .( bytes)
