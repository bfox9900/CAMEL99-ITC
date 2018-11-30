\ vectored I/O for RS232 control

\ name the user variables in the table for this purpose
HEX
 2E USER 'EMIT   \ vector for char. output routine
 30 USER 'CR     \ vector for carriage return
 32 USER 'KEY    \ vector for wait-for-key
 34 USER 'KEY?   \ vector for key pressed test
 36 USER 'TYPE   \ vector for block output
 38 USER 'PAGE   \ vector for screen clear

\ Set TI-99 Console drivers
: CONSOLE
   ['] EMIT 'EMIT !
   ['] CR   'CR !
   ['] KEY  'KEY !
   ['] KEY? 'KEY? !
   ['] TYPE 'TYPE !
   ['] PAGE 'PAGE !
;

CONSOLE   \ init the vectors

: PERFORM ( addr -- ) @ EXECUTE ;

\ re-define I/O words to use vectors
: EMIT    ( -- )  'EMIT PERFORM ;
: CR      ( -- )  'CR PERFORM ;
: KEY     ( -- )  'KEY PERFORM ;
: KEY?    ( -- )  'KEY? PERFORM ;
: TYPE    ( -- )  'TYPE PERFORM ;


