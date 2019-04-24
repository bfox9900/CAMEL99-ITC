\ ticker.fth  using ISR system counter

\ max delay is about  FF * 1/60 = 4.25 seconds
HEX
8378 CONSTANT t     \ address of the tick counter

: TICK  ( n -- )
          t @
          BEGIN
             PAUSE
             DUP  t @
          <> UNTIL
          DROP ;
          

: JIFFS  0 ?DO TICK LOOP ;

\ : TICKS  ( n -- )
\          t @ +  FF AND
\          BEGIN
\             PAUSE
\             DUP  t @
\          = UNTIL
\          DROP ;

\ MS resolution limited to 1/60 second and minimum is 1/60 sec.
: MS  ( n -- )  4 RSHIFT  1 MAX JIFFS ;  \ MS/16 = JIFFS

DECIMAL
: 1SEC  ( n -- )
          t @
          BEGIN

               t @ 60 + OVER - ABS
          0= UNTIL
          DROP ;