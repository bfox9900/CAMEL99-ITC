\ structs demo for CAMEL99 Forth   B Fox Sept 17 2019

NEEDS +FIELD  FROM DSK1.STRUC12

\ ===================================================================
\ example code: using [ ] brackets as a naming convention to
\ identify structures and fields

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
        
