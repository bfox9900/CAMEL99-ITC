\ forth 2012 structures
\ A.15 The optional Facility word set

\ The standard currently defines an aligned field defining word for each of
\ the standard data types:
\     CFIELD: a character        ( single character)
\     FIELD:  a native integer   (single cell)

\     FFIELD: a native float     ( not defined in CAMEL99)
\     SFFIELD: a 32 bit float    ( not defined in CAMEL99)
\     DFFIELD: a 64 bit float    ( not defined in CAMEL99)

\     CHARS: a string            ( CUSTOM to CAMEL99)

NEEDS DUMP    FROM DSK1.TOOLS \ for debugging only
NEEDS BUFFER: FROM DSK1.BUFFER
NEEDS +FIELD  FROM DSK1.STRUC12

\ ===================================================================
\ example: using [ ] brackets as a naming convention
\ to identity record and fields
DECIMAL

     0 FIELD: REC#]        \ first field always has offset of 0
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
 S" (201)"    [EMPLOYEE AREACODE] PLACE
 S" 555-1212" [EMPLOYEE PHONE#] PLACE


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
