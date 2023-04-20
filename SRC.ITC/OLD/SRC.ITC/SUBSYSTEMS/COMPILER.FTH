\ I N T E R P R E T E R  /  C O M P I L E R

TARGET-COMPILING
: <INTERP>  ( i*x c-addr u -- j*x )
         'SOURCE 2!  >IN OFF
          BEGIN
              BL WORD DUP C@ ( -- addr len)
          WHILE
              FIND ?DUP
              IF ( it's a word)
                   1+ STATE @ 0= OR
                   IF   EXECUTE
                   ELSE COMPILE,
                   THEN
              ELSE ( it's a number)
                   COUNT NUMBER? ?ERR
                   t[COMPILE] LITERAL
              THEN
              DEPTH 0< TS" Short stack" ?ABORT
          REPEAT
          DROP ;
