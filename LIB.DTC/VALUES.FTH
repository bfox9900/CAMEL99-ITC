\ VALUEs for CAMEL99
\ see: DEFER99.FTH  DEFER! and (TO) are the same code
\      so you could replace one for the other and save space

\ Usage:  0 VALUE W
\        99 TO W

: VALUE   CONSTANT ;   CR .( VALUE  )

: (TO)    ( n <text> -- ) >BODY ! ; 

: TO      ( n -- )
           STATE @
           IF   POSTPONE [']  POSTPONE (TO) \ compiling action
           ELSE '  (TO)                     \ interpret action
           THEN ; IMMEDIATE  .( TO )

\ un-comment these if you need them
\ : (+TO)   ( n <text> -- ) >BODY +! ;

\ : +TO      ( n -- )
\           STATE @
\           IF   POSTPONE [']  POSTPONE (+TO) \ compiling action
\           ELSE '  (+TO)                     \ interpret action
\           THEN ; IMMEDIATE

