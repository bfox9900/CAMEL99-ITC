\ Multi-line comments like 'C'

NEEDS S= FROM DSK1.COMPARE 

:  /*  ( -- )
       BEGIN
            BL PARSE-WORD DROP S" */" S=
       0= UNTIL ; IMMEDIATE

/* TEST THIS COMMENT
   WITH 2 LINES       */
