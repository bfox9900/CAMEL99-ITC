\ REQUIRED  REQUIRE   Forth 2012                 May 2026 B Fox

\ Usage:  REQUIRE DSK1.BUFFER
\ If DSK1.BUFFER is not found in dictionary,
\ put that name in the dictionary and load the file.

: REQUIRED  ( addr len -- )
      2DUP PAD PLACE       \ copy path to PAD
      PAD FIND NIP         \ don't need the CFA, just the flag
      IF  2DROP  EXIT THEN \ Path was found. we are done.

\ not in dictionary: make path a constant that returns true
      2DUP HEADER, COMPILE DOCON  TRUE , \ compile as constant. = true
      INCLUDED             \ load the file path
;

: REQUIRE ( <PATH> ) PARSE-NAME REQUIRED ;
