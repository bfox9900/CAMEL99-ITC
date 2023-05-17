\ DO LOOP BUG TEST


: TEST1   10 0  DO  LOOP ;

CREATE X  1 , 2 , 3 , 4 , 0 , 0 ,

: TEST2  10 0 DO  I . LOOP ;

: TEST3   10 0 DO
          CR
          10 0 DO
                  I .
                  I 6 > IF LEAVE THEN 
             LOOP
          LOOP ;
