
: PARSE-STRING \ ( a u -- a' u' ap up )
\ parse space-delimited string within given string (a u)
  BEGIN OVER C@ BL > 0= OVER AND
  WHILE 1-
    SWAP 1+ SWAP
  REPEAT
  OVER >R

  BEGIN OVER C@ BL > OVER AND
  WHILE 1-
    SWAP 1+ SWAP
  REPEAT
  OVER R@ - R> SWAP ;

: STRING-EXTRACT \ ( a u -- )
  BEGIN DUP WHILE
      PARSE-STRING CR TYPE
  REPEAT
  2DROP ;
