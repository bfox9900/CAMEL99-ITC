\ rpn lists of strings and support functions

\ string list structure
\
\ <link><len>< .... string ....><link><len>< .... string ....><nil>
\   |                              ^                           ^
\   ------------>------------------|------------->-------------|

\ Concept:
\ }   creates new links  and stores the data in the new links
\ { sets up all the data and CARs on the Forth data stack


INCLUDE DSK1.TOOLS.F
\          CAR   CDR
\          ---   ---
CREATE NIL  0 ,   0 ,             \ an empty list
\ 1ST CELL is pointer to next list
\ 2nd cell is pointer to some data

: 3RD   2 PICK ;

2 CELLS CONSTANT CONSSIZE
1 CELLS CONSTANT ATOMSIZE
: CAR   ( list -- 'data)     @ ;
: >CDR   CELL+ ;
: CDR   ( list -- 'list)    CELL+ @ ;
: CADR  ( list -- '1stdata) CDR CAR ;
: CDDR  ( list -- '2nddata) CAR CDR ;
\ : CONS  ( list item1 item2 -- list) SWAP 3RD 2! ;
: >LINK  ( list -- ) CONSSIZE + ;

\ CONS is Lisp talk for "consectutive addresses"
: CONS   ( car data   -- car')
          SWAP DUP >R
          >CDR !             \ put data in CDR
          R@ >LINK DUP R> !  \ create new list
          DUP , 0 , 
 ;

\ start a new empty list in dictionary,

VARIABLE  LVL          \ count number of lists on the stack
: '{  ( -- car atom 'cdr)
        HERE DUP DUP , 0 ,
\       1 LVL +!
       !CSP ;          \ mark data stack position


: {   ( car item1  -- car item car' )
         OVER >CDR
\        1 LVL +!
;

: }   ( car  data  --  )
\        LVL @ 1- DUP 0< ABORT" List underflow"
\        LVL !
         CONS 
         DROP ;

: {LEN}   ( list -- n )  \ count the no. of items in a list
          0 >R
          BEGIN
             CAR DUP
             R> 1+ >R
          0= UNTIL
          DROP
          R> 1- ;
          
: {U.}   ( list -- n )  \ print a list of numbers
          CR ." { "
          0 >R
          BEGIN
             DUP @
          WHILE
            DUP CDR U.
            CAR
            R> 1+ >R
          REPEAT
          ." }"
          DROP
          R> CR . ." items" ;



: STR  ( car addr len -- car' )   \ compile stack string into a list
        HERE OVER + 1+ ALIGNED    \ compute HERE+length of string
        CELL+ ,                   \ compute address of next string, compile into memory
        S, ;                      \ compile the string into memory

: "   ( -- )                 \ make a link-list string
      [CHAR] " PARSE-WORD  STR} ;  ( -- addr len)

: NTH}    ( list n -- $addr )  \ the nth string in a list
            0 DO  CAR  LOOP ;

: {PRINT} ( link -- ) 'CDR  COUNT CR TYPE ;

: {LEN}   ( list -- n )  \ count the no. of items in a list
          0 >R
          BEGIN
             CAR DUP
             R> 1+ >R
          0= UNTIL
          DROP
          R> 1- ;

: PRINT} ( list -- )  \ print a list
          CR ." { "
          0 >R
          BEGIN
             DUP @
          WHILE
            DUP 'CDR COUNT TYPE SPACE
            CAR
            R> 1+ >R
          REPEAT
          ." }"
          DROP
          R> CR . ." items" ;

CREATE EVALBUFF  0 ,

: EVAL}  ( list -- )
          BEGIN
             DUP CAR
          WHILE
            DUP 'CDR DUP EVALBUFF ! EVALUATE
            CAR
          REPEAT
          DROP ;

: }:     ( addr -- ) }
          LVL @ 0 > ABORT" Missing brace(s)}
          CONSTANT ;


'{ S" This is a Forth literal string" STR}
   S" And so is this" STR}
   S" Each string is compiled into this list with 'STR}'" STR}
 }: LISTA

'{ " This list is using the quote string compiler" }: LISTB


'{ " VARIABLE X  1 1 + X ! " }: XPRESSION



\ KEYWORDS {WITH  TOUPPER  MAP}
: {WITH   STATE @
          IF   POSTPONE [']
          ELSE '
          THEN ;

\ xt must be a clean string function that leaves nothing on the stack
: MAP} ( list xt -- )  \ for view
          >R
          BEGIN
            DUP CAR
          WHILE
             DUP R@ EXECUTE
             CAR
          REPEAT
          R> DROP
          DROP ;


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

VARIABLE MEMBR  \ so much easier (AND FASTER) with counter variable :-)

: {MEMBER}  ( $ {list} -- 0 | ndx )  \ is a member of {list} in $
          MEMBR OFF                  \ false flag under inputs
          SWAP COUNT NEW: TOP$ PLACE
          BEGIN
            DUP @
          WHILE
            1 MEMBR +!
            DUP CAR TOP$ POS$
            IF
               DROP
               NIL
            ELSE
               CAR
            THEN
          REPEAT
          DROP$                \ clean string stack
          DROP                 \ clean data stack
          MEMBR @  ;           \ get the counter






