\ simple list words     BJF  22AUG2018

CREATE {NIL}   0 ,                      \ nil list

: {   ( -- ) ALIGN !CSP  ;
: }   ( -- ) ALIGN {NIL} @ , ?CSP ;     \ ends list, check stack


: "   ( -- )                 \ compile a linked-list string
      HERE 0 ,               \ make space for link
      [CHAR] " WORD DUP C@ 1+ ALLOT ALIGN
      HERE SWAP 2- ! DROP ;   \ fill in the link


\ : CAR  ( list -- next)  @ ;
\ : CDR  ( list -- addr) CELL+ ;

: {NEXT}   ( list -- list' )  @  ;  \ get next string in a list
: {$}     ( link -- $)  CELL+ ;

: {NTH}    ( list n -- $addr )  \ the nth string in a list
             0  ?DO  {NEXT}  LOOP ;

: {PRINT} ( link -- ) {$} COUNT CR TYPE ;

: {LEN}   ( list -- n )  \ count the no. of items in a list
          0 >R
          BEGIN
            {NEXT} DUP
            R> 1+ >R
          0= UNTIL
          DROP
          R> 1- ;

: {LIST} ( list -- )  \ for view
          CR
          0 >R
          BEGIN
             DUP @
          WHILE
            DUP {$} COUNT
            DUP 4 + C/L@ > IF  CR THEN TYPE ." , "
            {NEXT}
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

VARIABLE MFLAG     \ simpler that stack juggling :-)
VARIABLE POSITION  \ ALSO record the position of keyword in $
: {MEMBER}  ( $ {list} -- -1 | ndx )  \ is ANY member of {list} in $
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
