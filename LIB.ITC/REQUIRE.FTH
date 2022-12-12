\ REQUIRED  REQUIRE   Forth 2012                  Dec 29 2021 B Fox

: REQUIRED  ( addr len -- )
      2DUP PAD PLACE       \ copy path to PAD
      PAD FIND NIP         \ don't need the CFA, just the flag
      IF  2DROP  EXIT THEN \ Path was found. we are done.
    \ not in dictionary: make it so
      2DUP INCLUDED        \ compile the file
      HEADER,              \ all ok. compile path string in dictionary
      COMPILE NEXT,        \ does nothing
;

: REQUIRE ( <PATH> ) PARSE-NAME REQUIRED ;
