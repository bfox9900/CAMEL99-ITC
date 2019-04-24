\ lists of strings and support functions

\ string list structure
\
\ <link><len>< .... string ....><link><len>< .... string ....><nil>
\   |                              ^                           ^
\   ------------>------------------|------------->-------------|

: C"      POSTPONE " ; IMMEDIATE  \ need to rename this. We use " here

: POS$  ( $1 $2 -- n )  \ return "position" $1 in $2
           DUP -ROT DUP -ROT
           COUNT BOUNDS         \ step $2 char by char
           DO
             I OVER COUNT S=
             0= IF
                  NIP I SWAP
                  LEAVE
             THEN
           LOOP
           DROP - ABS ;
\
\ ---[ list words ]---
\
CREATE {NIL}   0 ,                      \ nil list

: {   ( -- ) !CSP   ;    \ list starts with 0 in link-fld, record stack pos.
: }   ( -- ) ALIGN {NIL} @ ,  ?CSP ;     \ ends list, check stack

: "   ( -- )                 \ make a link-list string
      [CHAR] " PARSE-WORD      ( -- addr len)
      HERE OVER + 1+ ALIGNED   \ compute HERE+length of string
      CELL+                    \ compute address of the next string
      ,                        \ compile the link into memory
      S,  ;                    \ compile the string into memory

\ : CAR  ( list -- next)  @ ;
\ : CDR  ( list -- addr) CELL+ ;

: {NEXT}   ( list -- list' )  @  ;  \ get next string in a list
: {$}     ( link -- $)  CELL+ ;

: {NTH}    ( list n -- $addr )  \ the nth string in a list
           1-  0 DO  {NEXT}  LOOP ;


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
            ?BREAK
          REPEAT
          DROP
          R> CR . ." items" ;
          
\ KEYWORDS {WITH  TOUPPER  MAP}
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

VARIABLE MEMBR  \ so much easier (AND FASTER) with counter variable :-)

: {MEMBER}  ( $ {list} -- 0 | ndx )  \ is a member of {list} in $
          MEMBR OFF                  \ false flag under inputs
          SWAP COUNT NEW: TOP$ PLACE
          BEGIN
            DUP @
          WHILE
            1 MEMBR +!
            DUP {$} TOP$ SEARCH
            IF
               DROP
               {NIL}
            ELSE
               {NEXT}
            THEN
          REPEAT
          DROP$                \ clean string stack
          DROP                 \ clean data stack
          MEMBR @  ;           \ get the counter

CREATE PHRASES
    { " I AM"      \ 1
      " I HAVE"    \ 2
      " I'VE"      \ 3
      " I'M"       \ 4
      " I WILL"    \ 5
      " I'D"       \ 6
      " I'LL"      \ 7
      " MINE"      \ 8
      " ARE"       \ 9
      " WERE"      \ 10
      " YOU"       \ 11
      " ME"        \ 12
      " YOUR"      \ 13
      " IS"        \ 14
     }


CREATE CONJUGATIONS
    { " YOU ARE"    \ 1
      " YOU'VE"     \ 2
      " YOU'VE"     \ 3
      " YOU'RE"     \ 4
      " YOU'LL"     \ 5
      " YOU WOULD"  \ 6
      " YOU WILL"   \ 7
      " YOURS"      \ 8
      " AM"         \ 9
      " WAS"        \ 10
      " I"          \ 11
      " YOU"        \ 12
      " MY"         \ 13
      " BEING"      \ 14
     }

