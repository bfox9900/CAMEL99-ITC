\ Lee Stewart's mod of Lucien2's code for the sevens problem

\ Speedup mods for CAMEL99 Forth
\ 1. Used VALUES
\ 2. VTYPE for all short strings
\ 3. Used UM/MOD , native division
\ 4. >DIGIT for digit conversion
\ 5. Redefined PAD as static memory

\ ** Tested use of 7* code word. Reduces total times by 1 second

NEEDS ELAPSE FROM DSK1.ELAPSE
NEEDS VALUE  FROM DSK1.VALUES
NEEDS MALLOC FROM DSK1.MALLOC
NEEDS VTYPE  FROM DSK1.VTYPE
NEEDS MARKER FROM DSK1.MARKER

MARKER /SEVENS

DECIMAL
\ ------------------------------------
180 CONSTANT SIZE
CREATE A1   SIZE ALLOT
CREATE PAD  SIZE ALLOT

0 VALUE LENGTH    \ current number of digits in result

HEX  \ Using 7* reduces time of "RUN" & "FASTRUN" by ~1 second
CODE 7*   C044 , 0A34 , 6101 , NEXT, ENDCODE

DECIMAL
: A1*7->A1 ( -- ) \ perform 7 * last result
   0              \ initialize carried digit on stack
   1 +TO LENGTH   \ assume we will increase length by 1 digit
   A1 LENGTH BOUNDS
   DO
      I C@         \ get cur digit as next higher digit
      7 *          \ cur digit * 7
      +            \ add carried digit from stack
      0 10 UM/MOD  \ make result ud..unsigned divide by 10
      SWAP I C!    \ store rem as cur digit..carry on stack
   LOOP
   DROP            \ clean up stack
 \ eliminate leading 0
   A1 LENGTH 1-  + C@ 0=    \ highest digit = 0?
   IF
      -1 +TO LENGTH  \ correct digit count
   THEN  ;

: A1$ ( -- addr len)
   PAD DUP              \ PAD & COPY for string storage
   A1 1- DUP LENGTH +
   DO
      I C@ >DIGIT    \ fetch integer,convert to ASCII
      OVER C!        \ store ASCII digit in PAD
      1+             \ next PAD location
   -1 +LOOP
    DROP             \ clean up stack
   ( PAD) LENGTH ;

: A1$.TYPE ( -- )  \ type A1 backwards
   [ A1 1- ] LITERAL
   LENGTH OVER +
   DO
      I C@ >DIGIT (EMIT)
   -1 +LOOP ;


: 7COUNTER ( -- ? )  \ Brian Fox's technique
   0                 \ initialize counter
   A1 LENGTH BOUNDS  \ DO A1 to A1 + length
   DO
      1+             \ increment counter
      I C@ 7 = AND   \ test char, AND with counter.
      DUP 6 =
      IF            \ more than '77777'?
         LEAVE      \ yup..we're done
      THEN
   LOOP
;

DECIMAL
: .POWER ( n -- ) S" SEVEN TO THE POWER OF " VTYPE DECIMAL .  S" IS" VTYPE ;

: RUN      \ V2.58 1:26 , v2.59 with 8 line scrolling, 1:02
           \ v2.62c 1:03.7
   PAGE
   A1 SIZE 0 FILL
   7 A1 C!
   1 TO LENGTH
   2                 \ starting power
   BEGIN
      A1*7->A1
      DUP            \ dup power for display
      CR .POWER
      1+             \ increment power
      CR A1$.TYPE
      CR
      7COUNTER 6 =
   UNTIL
   DROP
;

DECIMAL
: NOSCROLL
   PAGE
   A1 SIZE 0 FILL
   7 A1 C!
   1 TO LENGTH
   2                 \ starting power
   BEGIN
      A1*7->A1
      DUP            \ dup power for display
      0 0 AT-XY .POWER
      1+             \ increment power
\     CR CR A1$ TYPE    \ 39:08
     CR CR A1$ VTYPE    \ 24:50
     7COUNTER  6 =
   UNTIL
   0 7 AT-XY
;

DECIMAL
: FASTRUN         ( 16.1 seconds)
   PAGE ." Working..."
   A1  SIZE 0 FILL
   PAD SIZE 0 FILL
   7 A1 C!
   1 TO LENGTH
   2                 \ starting power
   BEGIN
     7COUNTER 5 <
   WHILE
      A1*7->A1
      1+             \ increment power
   REPEAT
   1- CR .POWER
   CR A1$ VTYPE
   0 7 AT-XY
;

DECIMAL

CR .( TYPE: ELAPSE RUN, ELAPSE NOSCROLL or ELAPSE FASTRUN ) CR
