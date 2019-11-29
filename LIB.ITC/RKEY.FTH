\ Repeating key based on Nouspikel TI-99 tech pages
DECIMAL
\ set LONG & SHORT to your preferences
\ 65 CONSTANT LONG      \ delay before auto-repeat kicks in
\  4 CONSTANT SHORT     \ Delay between repeats

VARIABLE NEWKEY        \ key buffer
VARIABLE OLDKEY        \ previous key buffer

CREATE DLY  41 ,       \ Initialized long delay

HEX
: (RKEY) ( -- )
    DLY @ 0
    DO
        83C8 ON         \ force repeating KSCAN
        KEY? DUP NEWKEY !
        OLDKEY @  <>    \ different than before?
        IF
          NEWKEY @  OLDKEY !  \ Memorize current key (=0 if no key)
          41 DLY !      \ reload waiting delay
          UNLOOP  EXIT  \ jump out of the routine (to the semi-colon )
        THEN
    LOOP
    4 DLY !             \ Wait expired: load repeat delay
;

: RKEY   ( -- char)
         VPOS VC@ >R    \ store char under cursor
         BEGIN
           TMR@ 1FFF >   \ read 9901 timer. compare to >2000
           IF CURS @     \ true? fetch cursor char
           ELSE R@       \ false? fetch screen char
           THEN VPUT     \ multi-tasking friendly screen write
          (RKEY) NEWKEY @ \ get the newkey value
          ?DUP
         UNTIL
         R> VPUT ;       \ put the char back
