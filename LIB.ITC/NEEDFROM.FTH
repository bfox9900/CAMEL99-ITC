\ NEEDS/FROM  conditional compilation control  B Fox 2018

\ USE:  NEEDS HCHAR FROM DSK1.GRAFIX.F

: NEEDS  ( -- ?)  BL WORD FIND NIP  ;

: FROM   ( ? -- ) 
         BL PARSE-WORD ROT ( addr len ? --)
         0= IF  INCLUDED
         ELSE   2DROP
         THEN ; 
