\ DOTQUOTE.FTH 

: ."      (  ccc" -- )
          t[COMPILE] S"                ( -- str len)
          STATE @
          IF   COMPILE TYPE
          ELSE TYPE
          THEN ; XIMMEDIATE

: .(     T[CHAR] ) PARSE TYPE ; XIMMEDIATE
