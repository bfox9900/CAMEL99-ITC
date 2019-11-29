\ -TRAILING  remove trailing blanks

: -TRAILING
       1-
       BEGIN
          2DUP + C@
       BL =
         WHILE
         1-
       REPEAT
       1+ ; 
