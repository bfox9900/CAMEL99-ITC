\ Multi-line comments like 'C'

NEEDS COMPARE FROM DSK1.COMPARE
\ NEEDS REFILL  FROM DSK1.REFILL

: /* ( -- )
     BEGIN
       BEGIN
         PARSE-NAME \  BL WORD COUNT \ 2DUP TYPE
         DUP
       WHILE
         2DUP S" */" COMPARE
       WHILE
         2DROP
       REPEAT
       THEN
       2DROP
       REFILL 0=
    UNTIL
; IMMEDIATE

/* TEST THIS COMMENT

   WITH 2 LINES


   HOW About here?  */
