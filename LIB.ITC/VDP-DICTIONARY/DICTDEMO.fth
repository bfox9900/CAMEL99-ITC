\ dictionary examples   2025 Brian Fox

' ADD$  DROP  \ need to load DICTIONARY.FTH

DICTIONARY: VFORTH  \ Init a new dictionary in VDP RAM

HEX
\ copy Forth dictionary into VDP RAM dictionary
: COPY-DICTIONARY
    CR ." This will take a minute ... " CR
    LATEST @
    BEGIN
        DUP COUNT VFORTH ADD$ ." ."
        NFA>LFA @ DUP  \ follow link in Forth dictionary to next word
    0= UNTIL
    DROP
;

\ lets you see the contents of a dictionary
: VDP.TYPE  ( Vaddr len --) BOUNDS ?DO I VC@ EMIT LOOP ;

: DICT.WORDS  ( did -- ) \ dictionary ID argument required
    CR
    @
    BEGIN
        DUP VCOUNT VDP.TYPE SPACE
        NFA>LFA V@
        DUP 0=
    UNTIL
    DROP
;

: VWORDS   VFORTH DICT.WORDS  ;
CR .( commands ...)
\ COPY-DICTIONARY
\ VWORDS
