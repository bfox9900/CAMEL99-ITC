\ expansion card utils

: DSRLIST ( addr -- )
          BEGIN
            DUP @
          WHILE
             DUP >DSR$ COUNT TYPE ." , "
             @
          REPEAT
          DROP ;

: CARDSCAN ( start end -- adr | 0 )  \ usage: HEX 1000 2000 CARDSCAN
           SWAP
           0 -ROT    \ false flag under the args.
           ?DO
              I CRU!  0 SBO           \ turn card on
              'ID C@ AA =             \ test if present
              IF  DROP I  LEAVE       \ found one. leave
              THEN 0 SBZ              \ Turn card off
          100 +LOOP ;
