\ expansion card utils

: DSRLIST ( addr -- )
          BEGIN
            DUP @
          WHILE
             DUP 4 + COUNT TYPE ." , "
             @
          REPEAT
          DROP ;

: CARDSCAN ( start end -- adr | 0 )  \ usage: HEX 1000 2000 CARDSCAN
           SWAP
           0 -ROT    \ false flag under the args.
           ?DO
              I ENABLE
              'ID C@ AA =             \ test if present
              IF  DROP I  LEAVE       \ found one. leave
              THEN 0SBZ              \ Turn card off
          100 +LOOP ;
