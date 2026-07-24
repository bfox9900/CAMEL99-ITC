\ POCOLOCATE.FTH

NEEDS SEARCH FROM DSK1.SEARCH

\ Ugly but it works
: FINDER  ( addr len line# -- 0 | curpos )
   >R
   FALSE -ROT
   ROW OFF
   #LINES @ R>
    DO
        I ]POOL$ PAD VDP$.GET
        PAD COUNT RIGHTSIDE  2OVER  SEARCH
        TRUE =
        IF  I TOPLINE !  \ set editor topline
            DROP NIP
            ROT DROP TRUE -ROT
            LEAVE
        ELSE
            2DROP
            CURPOS OFF  \ start of new line
        THEN
    LOOP
    ROT
    IF   NIP PAD - 1- 0 MAX CURPOS !  TRUE
    ELSE 2DROP FALSE
    THEN
;

CREATE SRCH$  42 ALLOT
: GETSTRING  1 PARSE-WORD  40 MIN SRCH$ PLACE ;

: ?EDIT  0= ABORT" Can't find in file"  EDIT ;

: <FIND>  SRCH$ COUNT  TOPLINE @ FINDER  ?EDIT ;

: FIND  ( -- ?)
    TOPLINE OFF CURPOS OFF
    GETSTRING <FIND> ;

: FNEXT ( -- ?)  SRCH$ LEN CURPOS+! <FIND> ;
