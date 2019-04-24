\ vectored I/O Version 2.1.F or higher
HEX
 48 USER 'EMIT            \ vector for char. output routine
 4A USER 'CR              \ vector for carriage return
 4C USER 'KEY             \ vector for wait-for-key
 4E USER 'KEY?            \ vector for key pressed test
 50 USER 'TYPE            \ vector for block output
 52 USER 'PAGE            \ vector for screen clear


\ Set vectors to use TI-99 I/O words
: CONSOLE
   ['] EMIT 'EMIT !
   ['] CR   'CR !
   ['] KEY  'KEY !
   ['] KEY? 'KEY? !
   ['] TYPE 'TYPE !
   ['] PAGE 'PAGE !
   SOURCE-ID OFF      \ default I/O device is 0
;

CONSOLE   \ init the vectors now

: PERFORM ( addr -- ) @ EXECUTE ;

\ re-define FORTH I/O words to use vectors
: EMIT    ( -- )  'EMIT PERFORM ;
: CR      ( -- )  'CR   PERFORM ;
: KEY     ( -- )  'KEY  PERFORM ;
: KEY?    ( -- )  'KEY? PERFORM ;
: TYPE    ( -- )  'TYPE PERFORM ;
: PAGE    ( -- )  'PAGE PERFORM ;

