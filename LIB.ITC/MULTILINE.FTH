\ Multi-line comments like 'C'

NEEDS COMPARE FROM DSK1.COMPARE
NEEDS REFILL  FROM DSK1.REFILL

: /* ( -- )
 \    PARSE-NAME 2DROP  \ swallow the first word
     BEGIN
       REFILL
     WHILE
        BEGIN
           PARSE-NAME
           DUP
         WHILE ( len > 0)
           2DUP S" */" COMPARE
         WHILE ( compare <> 0)
         2DROP
         REPEAT
         THEN
     REPEAT
; IMMEDIATE

/* ******************************
    THIS COMMENT WILL BE IGNORED
   ****************************** */
