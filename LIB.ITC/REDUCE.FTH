\ REDUCE for cell data
\ changed size to be in bytes
INCLUDE DSK1.TOOLS

DECIMAL
VARIABLE REDUCER
: REDUCE ( inital addr size xt-- n)
         OVER 0= ABORT" REDUCE: size cannot be 0"
         REDUCER @ >R  \ allow this to be re-entrant
         REDUCER !
         BOUNDS
         DO
           I @  REDUCER PERFORM
         2 +LOOP
         R> REDUCER !
;

CREATE MYDATA  0 , 1 , 2 , 3 , 4 ,

: MyAdd ( n n -- n)
        CR OVER . ." + " DUP .  +  DUP ." = "  .  ;

\ demo code
 0 MYDATA 5  ' MyAdd REDUCE CR .

 0 MYDATA 5 ' + REDUCE CR .

: SUM ( addr len ) 0 -ROT  ['] + REDUCE ;
: AVERAGE ( addr len ) DUP>R SUM  R> / ;

: /CELL  ( addr len -- addr' len')
: FIRST  ( addr len )  OVER @
