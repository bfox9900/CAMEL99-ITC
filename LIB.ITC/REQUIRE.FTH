\ REQUIRED  REQUIRES   Forth 2012

\ uses carnal knowledge of Camel Forth dictionary
: REQUIRED  ( addr len -- )
      2DUP PAD PLACE      \ copy path to PAD
      PAD FIND NIP        \ cuz find uses a counted string
      IF
        2DROP           \ if we find that path drop it
      ELSE
        2DUP INCLUDED        \ compile the file
        HEADER,              \ all ok. compile path string in dictionary
        COMPILE DOCON TRUE , \ make it a constant that returns TRUE
      THEN ;

: REQUIRE ( <PATH> ) PARSE-NAME REQUIRED ;
