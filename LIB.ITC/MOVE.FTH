\ 6.1.1900 MOVE     LIBRARY FILE FOR CAMEL99
: MOVE    ( src dst n -- )
          >R  2DUP SWAP DUP R@ +  \ -- src dst dst src src+n
          WITHIN IF R> CMOVE>  ELSE  R> CMOVE   THEN ;
