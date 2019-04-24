\ forth 2012 structures
\ A.15 The optional Facility word set

\ These words are part of the standard but are not required.
\ Due to the small memory in the TI-99 we use took the smaller option
\ : BEGIN-STRUCTURE  \ -- addr 0 ; -- size
\   CREATE
\     HERE 0 0 ,        \ mark stack, lay dummy
\   DOES> @             \ -- rec-len
\ ;

\ : END-STRUCTURE  \ addr n --
\   SWAP ! ;          \ set len

\ NEEDS .S FROM DSK1.TOOLS

DECIMAL
: +FIELD  \ n <"name"> -- ; Exec: addr -- 'addr
   CREATE OVER , +
   DOES> @  + ;

\ using +field you can make your own field desciptors.
: FIELD:    ( n1 "name" -- n2 ; addr1 -- addr2 ) ALIGNED 1 CELLS +FIELD ;
: 2FIELD:   ( d1 "name" -- d2 ; addr1 -- addr2 ) ALIGNED 2 CELLS +FIELD ;
: CFIELD:   ( n1 "name" -- n2 ; addr1 -- addr2 )         1 CHARS +FIELD ;

: CELLS:    ( n -- )  CELLS +FIELD ;

\ we can add string size tests for a CHARS: field
: ?STRING   ( n -- n) DUP 1 256 WITHIN 0= ABORT" bad string length" ;
: CHARS:    ( n -- ) ?STRING CHARS +FIELD ;

\ ===================================================================
\ example code: using [ ] brackets as a naming convention to
\ identity structures and fields

    0  ( zero on the stack accumulates the record size)
       FIELD: REC#]
    32 CHARS: NAME]
    32 CHARS: FAMILY]
    64 CHARS: ADDRESS]
    32 CHARS: CITY]
    15 CHARS: PROV]
    25 CHARS: COUNTRY]
( -- n) CONSTANT RECORD-SIZE   \ record the size as a constant

: BUFFER:    CREATE  ALLOT ;
: ""   ( -- addr len) S" " ;      \ a null string

RECORD-SIZE BUFFER: [BUFF         \ and make a buffer that size

: ERASE.REC
           0  [BUFF REC#] !
           "" [BUFF NAME] PLACE
           "" [BUFF FAMILY] PLACE
           "" [BUFF ADDRESS] PLACE
           "" [BUFF CITY] PLACE
           "" [BUFF PROV] PLACE
           "" [BUFF COUNTRY] PLACE
;

: LOADREC
         1    [BUFF REC#] !
 S" Robert"   [BUFF NAME] PLACE
 S" Odrowsky" [BUFF FAMILY] PLACE
 S" 116 Settlement Park Ave." [BUFF ADDRESS] PLACE
 S" Markham"  [BUFF CITY] PLACE
 S" Ontario"  [BUFF PROV] PLACE
 S" Canada"   [BUFF COUNTRY] PLACE
;

: PRINT#   ( addr --)  @ . ;
: PRINT$   ( $addr --) COUNT TYPE ;
: PRINTLN  ( $addr --) CR PRINT$ ;

: PRINT.REC
        CR ." Record#: " [BUFF REC#] PRINT#
        [BUFF FAMILY] PRINTLN  ." , " [BUFF NAME] PRINT$
        [BUFF ADDRESS] PRINTLN
        [BUFF CITY] PRINTLN
        [BUFF PROV] PRINTLN
        [BUFF COUNTRY] PRINTLN ;
