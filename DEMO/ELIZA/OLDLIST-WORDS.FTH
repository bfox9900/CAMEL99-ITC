\ ---[ list words ]---
\
CREATE {NIL}  0 , 0 ,                 \ nil list

: CAR  ( list -- next) @ ;
: CDR  ( list -- addr) CELL+ ;

: '{  ( -- addr)  HERE ALIGN !CSP  ;  \ starts a new list

: }   ( addr -- )
     ALIGN {NIL} , ?CSP             \ end list, check stack
    ( CAR -- ) CREATE DUP , CDR ,  ;  \ compile a tuple ie: a list

: $"   ( -- )                 \ compile a linked-list string
      HERE 0 ,               \ make space for link
      [CHAR] $" WORD DUP C@ 1+ ALLOT ALIGN
      HERE SWAP 2- ! DROP ;  \ fill in the link

: {NEXT} ( list -- list' )  @ ;  \ get next string in a list
: {$}    ( link -- $)  CELL+ ;

: {NTH}  ( car n -- car' ) 0 ?DO  CAR  LOOP  ;

: {PRINT} ( link -- ) CDR COUNT CR TYPE ;

: {LEN}   ( list -- n )  \ count the no. of items in a list
          0 >R
          BEGIN
            {NEXT} DUP
            R> 1+ >R
          0= UNTIL
          DROP
          R> 1- ;

: {VIEW} ( list -- )  \ view a list
          CR
          0 >R
          BEGIN
             DUP @
          WHILE
            DUP CDR COUNT
            DUP 4 + C/L@ > IF  CR THEN TYPE ." , "
            CAR
            R> 1+ >R
          REPEAT
          DROP
          R> CR . ." items" ;

\ USAGE:   KEYWORDS {WITH  TOUPPER  MAP}
: {WITH   STATE @
          IF   POSTPONE [']
          ELSE '
          THEN ;

\ xt must be a clean string function that leaves nothing on the stack
: MAP} ( list xt -- )  \ for view
          >R
          BEGIN
            DUP @
          WHILE
             DUP R@ EXECUTE
            {NEXT}
          REPEAT
          R> DROP
          DROP ;

VARIABLE MFLAG     \ simpler than stack juggling :-)
VARIABLE POSITION  \ ALSO record the position keyword in $
: {MEMBER}  ( $ {list} -- -1 | ndx ) \ is ANY member of {list} in $
          MFLAG ON                   \ -1 flag means not found
          SWAP COUNT NEW: TOP$ PLACE \ $ goes on string stack
          0 >R                       \ counter on rstack
          BEGIN
            DUP @
          WHILE
            DUP {$} TOP$ POS$ DUP POSITION !
            IF R@ MFLAG !
               DROP {NIL}      \ drop {list}, replace with {nil}
                               \ to end the loop
            ELSE
               {NEXT}
               R> 1+ >R        \ inc the counter
            THEN
          REPEAT
          DROP$                \ clean string stack
          DROP                 \ clean data stack
          R> DROP
          MFLAG @  ;           \ return the mflag value
          
: {SIZEOF} ( list -- n) CELL+ @ ;
.( .)

