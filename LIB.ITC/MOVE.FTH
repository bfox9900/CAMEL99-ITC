\ 6.1.1900 MOVE     LIBRARY FILE FOR CAMEL99
\ CORE

: MOVE    ( src dst n -- )
          >R  2DUP SWAP DUP R@ +  \ -- src dst dst src src+n
          WITHIN
          IF    R> CMOVE>         \ src <= dst < src+n
          ELSE  R> CMOVE  
          THEN ;  
