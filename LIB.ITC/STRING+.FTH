\ string things TI BASIC doesn't have

NEEDS -TRAILING FROM DSK1.TRAILING

: LEFT$    ( $ n -- top$) >R COUNT DROP R> SPUSH ;
: RIGHT$   ( $ n -- top$) >R COUNT DUP R> - 0 MAX /STRING SPUSH ;

: CPOS    ( char $ -- $ position) \ fast 1 char search
           SWAP >R COUNT 2DUP R> SCAN NIP - NIP 1+ ;

: TRIM$    ( $ -- top$)      COUNT -TRAILING SPUSH ;   \ trim trailing spaces
: SKIP$    ( $ char -- top$) >R COUNT R> SKIP SPUSH ;  \ removes leading char
: CLEAN$   ( $ -- $')  COUNT BL SKIP -TRAILING SPUSH ;
: RPT$     ( $1 u -- top$)  \ like TI Extended BASIC
            NEW:
            SWAP COUNT ROT
            0 ?DO
                2DUP TOP$ LEN OVER + SSW > ABORT" RPT$>255"
                TOP$ +PLACE
            LOOP
            2DROP
            TOP$ ;

: APPEND-CHAR ( char caddr -- ) \ add a ascii char onto the end of a string
              DUP >R COUNT DUP 1+ R> C! + C! ;
