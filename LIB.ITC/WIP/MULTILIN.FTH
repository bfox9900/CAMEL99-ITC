\ Multi-line comments

NEEDS S= FROM DSK1.COMPARE

: ((  ( -- )
       BEGIN
          PARSE-NAME ( addr len )
      DUP WHILE
            S" ))" COMPARE
       0= UNTIL
       THEN ; 

(( TEST THIS COMMENT
    WITH 2 LINES    ))
