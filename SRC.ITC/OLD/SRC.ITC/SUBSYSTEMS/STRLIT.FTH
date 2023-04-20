\ S T R I N G   L I T E R A L

true [IF]  \ MULTI-STRING version
: S"       ( cccc" -- )          \ compiling action
\ *G Non-standard: when interpreting S" puts the string at HERE+>IN
\ ** and returns the address.
           ( cccc" --- addr len) \ interpreting action *NON-STANDARD*
           T[CHAR] " PARSE
           STATE @
           IF  COMPILE (S")  S,

           ELSE  PAD >IN @ + DUP>R PLACE
                 R> COUNT
           THEN ; XIMMEDIATE
[ELSE]
 : S"       ( cccc" -- )  \ OLD VERSION
            T[CHAR] " PARSE
            STATE @
            IF  COMPILE (S")  S,
            ELSE PAD PLACE PAD COUNT
            THEN ; XIMMEDIATE
[THEN]

: ABORT"   ( i*x 0  -- i*x)    \ R: j*x -- j*x  x1=0
           ?COMP
           t[COMPILE] S"
            COMPILE ?ABORT ; XIMMEDIATE
