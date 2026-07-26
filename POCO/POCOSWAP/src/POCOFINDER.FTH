\ POCOFINDER.FTH
CR .( search function for swapfile POCO)

NEEDS SEARCH FROM DSK1.SEARCH

\ Ugly but it works
: FINDER  ( addr len line# -- 0 | curpos )
   >R
   FALSE -ROT
   ROW OFF
   #LINES @ R>
    DO
        I ]POOL$ CURPOS @ /STRING  BL SKIP
        2OVER  SEARCH TRUE =
        IF  I TOPLINE !  \ set editor topline
            I ]POOL$
            ROT -
            NIP NIP NIP NIP  CURPOS !
            DROP TRUE
            LEAVE
        ELSE
            2DROP
            CURPOS OFF  \ start of new line
        THEN
    LOOP
    TRUE = IF TRUE  EXIT THEN
    DROP
;

CREATE SRCH$  42 ALLOT
: GETSTRING  1 PARSE-WORD  40 MIN SRCH$ PLACE ;

: ?EDIT   ( ? -- ) 0= ABORT" Can't find in file"   EDIT ;

: <FIND>  SRCH$ COUNT  TOPLINE @ FINDER  ?EDIT ;

: LOC  ( -- ?)
    TOPLINE OFF CURPOS OFF
    GETSTRING <FIND> ;

: LNEXT ( -- ?)  SRCH$ LEN CURPOS+! <FIND> ;
