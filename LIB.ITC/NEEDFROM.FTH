\ NEEDS/FROM  conditional compilation control  B Fox 2018
\ USE:  NEEDS HCHAR FROM DSK1.GRAFIX

: NEEDS  ( -- ?)  BL WORD FIND NIP  ;
: FROM   ( ? -- ) PARSE-NAME ROT IF  2DROP EXIT THEN  INCLUDED ;
