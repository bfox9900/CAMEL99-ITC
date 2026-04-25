\ PURIFY.FTH   checks for control chars in data and replaces them with space .

DECIMAL
VARIABLE BADCHARS

: CONTROL-CHAR? ( c -- ?) DUP 0 BL WITHIN SWAP [CHAR] ~ > OR ;

: CLEAN$  ( VDPaddr len -- )
    BOUNDS  \ I becomes a VDP address
    DO
       I VC@ CONTROL-CHAR?
       IF
          BL I VC!     \ replace the character at I
          BADCHARS 1+!
          BEEP
       THEN
    LOOP
;

: PURIFY
    CR ." Cleaning line "
    BADCHARS OFF
    #LINES @ 0
    DO
       [CHAR] . EMIT
       I ]POOL$ CLEAN$
    LOOP
    .FSTATS
    CR  BADCHARS @ . ."  control chars replaced"
;
