\ close all open files. Not always needed but here it is

NEEDS CLOSE-FILE   FROM DSK1.ANSFILES

: CLOSE-ALL  ( -- ior )
         0                       \ place holder for error codes
         #FILES @ 1+  1
         DO
           I ]FID @
           IF  I CLOSE-FILE OR   \ or the errors together
           THEN
         LOOP ;
