\ string case statement

NEEDS DIM  FROM DSK1.STRINGS
NEEDS CASE FROM DSK1.CASE

: $OF    ( -- )
   POSTPONE OVER   POSTPONE =$  POSTPONE IF POSTPONE DROP ; IMMEDIATE

: TEST   ( $ -- )
         CASE
            " APPLE" $OF  ." Granny Smith"  ENDOF
            " PEAR"  $OF  ." Barlett"       ENDOF
            " GRAPE" $OF  ." Concord"       ENDOF
                          ." Unknown fruit"
         ENDCASE  ;
         
         

