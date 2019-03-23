 \ some string things TI BASIC doesn't have

: LEFT$    ( $ n -- top$) >R COUNT DROP R> SPUSH ;
: RIGHT$   ( $ n -- top$) >R COUNT DUP R> - 0 MAX /STRING SPUSH ;

: CPOS    ( char $ -- $ position) \ fast 1 char search
           SWAP >R COUNT 2DUP R> SCAN NIP - NIP 1+ ;

\ : CPOS   ( char $ -- ?) COUNT ROT SCAN NIP  ;  \ much faster find 1 char in string

: -TRAILING  ( adr len -- adr len') \ remove trailing blanks (spaces)
               BEGIN
                 1-           \ shorten length
                 DUP 0= IF EXIT THEN
                 2DUP + C@    \ get last char
                 BL <>        \ test for blank
               UNTIL          \ until TRUE
               1+ ;

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
