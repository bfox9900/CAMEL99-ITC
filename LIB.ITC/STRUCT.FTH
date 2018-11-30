\ forth 2012 structures
\ A.15 The optional Facility word set

\ The standard currently defines an aligned field defining word for each of
\ the standard data types:
\     CFIELD: a character
\     FIELD:  a native integer (single cell)
\     FFIELD: a native float
\     SFFIELD: a 32 bit float
\     DFFIELD: a 64 bit float

INCLUDE DSK1.TOOLS.F  \ for debugging only
INCLUDE DSK1.BUFFER.F

\ these 2012 Forth words are not necessary, but people like them
: BEGIN-STRUCTURE  \ -- addr 0 ; -- size
   CREATE
     HERE 0 0 ,        \ mark stack, lay dummy
   DOES> @             \ -- rec-len
;

: END-STRUCTURE  \ addr n --
   SWAP ! ;      \ set len


\ simplest FIELD creator
: +FIELD  \ n <"name"> -- ; Exec: addr -- 'addr
   CREATE OVER , +
   DOES> @  +
;

\ define forth 2012 field types for TI-99
: FIELD:   ( n1 "name" -- n2 ; addr1 -- addr2 ) ALIGNED 1 CELLS +FIELD ;
: CFIELD:  ( n1 "name" -- n2 ; addr1 -- addr2 )         1 CHARS +FIELD ;

\ BF custom field types
: DFIELD:  ( d1 "name" -- d2 ; addr1 -- addr2 ) ALIGNED 2 CELLS +FIELD ;
: CELLS:       DUP 1 < ABORT" CELLS: <= 0" CELLS +FIELD ;
: CHARS:       DUP 1 < ABORT" CHARS: <= 0" CHARS +FIELD ;


\ ===================================================================
\ example: using [ ] brackets as a naming convention 
\ to identity record and fields
DECIMAL

     0                                  \ start with 0 on stack
       FIELD: REC#]                     \ name field at offset 0
    32 CHARS: NAME]
    32 CHARS: FAMILY]
    64 CHARS: ADDRESS]
    32 CHARS: CITY]
    15 CHARS: PROV]
    25 CHARS: COUNTRY]
    10 CHARS: PHONE#]
    10 CHARS: AREACODE]
       DUP CONSTANT REC-SIZE       \ rec size defined as a constant
           BUFFER: [EMPLOYEE       \ and make a buffer that size

\ load a dummy record
 1            [EMPLOYEE REC#] !
 S" Brian"    [EMPLOYEE NAME] PLACE
 S" Fox"      [EMPLOYEE FAMILY] PLACE
 S" 116 Settlement Park Ave." [EMPLOYEE ADDRESS] PLACE
 S" Markham"  [EMPLOYEE CITY] PLACE
 S" Ontario"  [EMPLOYEE PROV] PLACE
 S" Canada"   [EMPLOYEE COUNTRY] PLACE
 S" (416)"    [EMPLOYEE AREACODE] PLACE
 S" 648-9133" [EMPLOYEE PHONE#] PLACE


: WRITE$   COUNT TYPE  ;
: TAB    ( n -- ) VCOL ! ;

: .REC
PAGE ." == Simple Database =="  25 TAB ." Record# " [EMPLOYEE REC#] @ .
CR
CR   ." Last  Name: " [EMPLOYEE FAMILY] WRITE$
CR   ." First Name: " [EMPLOYEE NAME] WRITE$
CR
CR   ." Address   : " [EMPLOYEE ADDRESS] WRITE$
CR   ." City      : " [EMPLOYEE CITY] WRITE$
CR   ." Prov      : " [EMPLOYEE PROV] WRITE$
CR   ." Country   : " [EMPLOYEE COUNTRY] WRITE$
CR
CR   ." Phone#    : " [EMPLOYEE AREACODE] WRITE$ SPACE
                      [EMPLOYEE PHONE#] WRITE$
CR
;
