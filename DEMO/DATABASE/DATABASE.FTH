\ simple database using BLOCK file and Forth 2012 structures
\ A.15 The optional Facility word set

\ The standard currently defines an aligned field defining word for each of
\ the standard data types:
\     CFIELD: a character        ( single character)
\     FIELD:  a native integer   (single cell)

\  I add this word  CHARS:  to define a string         

NEEDS DUMP    FROM DSK1.TOOLS \ for debugging only
NEEDS BLOCK   FROM DSK1.BLOCKS 
NEEDS +FIELD  FROM DSK1.STRUC12

\ ===================================================================
\ example: using [ ] brackets as a naming convention
\ to identity record and fields
DECIMAL
    0                         \ first field always has offset of 0
     6 CHARS: ID#]            \ id# is a text field
    32 CHARS: NAME]
    32 CHARS: FAMILY]
    64 CHARS: ADDRESS]
    32 CHARS: CITY]
    15 CHARS: PROV]
    25 CHARS: COUNTRY]
    10 CHARS: PHONE#]
    10 CHARS: AREACODE]
    CONSTANT EMPLOYEE-REC-SIZE   \ rec size defined as a constant

\ COMPILE time compute data size per 1K block 
B/BUF EMPLOYEE-REC-SIZE /      CONSTANT RECS/BLOCK
RECS/BLOCK EMPLOYEE-REC-SIZE * CONSTANT BYTES/BLOCK 


\ We use BLOCK 0 (1K) of the database file for meta data.
\ Since blocks are virtual memory we can treat these variables like RAM.
\ Static allocation is used for simplicity
\ Lines 0 .. 11 are for 12 64 byte strings 
\ Last 256 bytes are for potentail 127 numberic variables 

\ We need some words to create these meta variables and strings 

\ string base address
: METASTR[] ( -- addr) 0 BLOCK ; 

\ integers base address
: METAVAR[] ( -- addr) 0 BLOCK [ 12 64 * ] LITERAL + ; 

\ create a meta variable 
: METAVAR:  ( n "name" -- addr) CREATE  ,  DOES> @ CELLS METAVAR[] + ;

\ create a meta string 
: METASTR:  ( n "name" -- addr) CREATE  ,  DOES> @ 64 * METASTR[] + ; 

\ Define the meta data 
0 METASTR: $DB     \ file path, database name 

0 METAVAR: LASTBLK 
1 METAVAR: LASTREC 

\ array of field x,y locations on the screen 
2 METAVAR: FLDXY[]  

: ]XY   ( n -- addr ) CELLS FLDXY[] + ;

\ x,y coordinates stored as 2 bytes in one cell. 
: ]XY!  ( x y fld# -- ) >R FUSE R> ]XY ! ;
: ]XY@   ( fld#-- x y ) ]XY @ SPLIT ;


\ system variables 
VARIABLE BLK# 
VARIABLE REC#

: RECORD ( n -- addr) 
  DUP 1 < ABORT" Can't access Record 0" 
  DUP REC# ! 
  256 UM*  ( -- d)             \ compute byte offset as 32bit int
  BYTES/BLOCK UM/MOD           \ compute blk# and block-offset   
  DUP BLK# !                   \ skip block 0, record blk# 
  BLOCK + ;                    \ select disk block and add offset  

\ record selector return base address of a record 
: [REC ( -- addr) REC# @ RECORD ;


: PRINT  ( Caddr --) COUNT TYPE  ;
: TAB    ( n -- ) VCOL ! ;

: UINT>$  ( u -- addr len) \ convert U to string, radix 10 
  BASE @ >R  DECIMAL  0 <#  # # # #  #>   R> BASE ! ; 

: .RECORD 
PAGE ." ==" $DB PRINT ." =="  25 TAB ." Record# " [REC ID#] PRINT 
CR
CR   ." Last  Name: " [REC FAMILY] PRINT
CR   ." First Name: " [REC NAME] PRINT
CR
CR   ." Address   : " [REC ADDRESS] PRINT
CR   ." City      : " [REC CITY] PRINT
CR   ." Prov      : " [REC PROV] PRINT
CR   ." Country   : " [REC COUNTRY] PRINT
CR
CR   ." Phone#    : " [REC AREACODE] PRINT ."  " [REC PHONE#] PRINT
CR
;

: ERASE  0 FILL ;

: WRITE-META ( lastblk addr len --) 
    2DUP OPEN-BLOCKS        \ open the database 
    0 BLOCK B/BUF ERASE     \ clear the metadata block 
    $DB PLACE               \ record file name and path 
    LASTBLK !               \ record the last block no. 
    UPDATE FLUSH              
    CLOSE-BLOCKS 
;

\ ============================================================
\            *** USER COMMANDS ***


\ COMMAND to create a database file of n blocks 
: BLOCKS  ( n -- ) 
  DUP>R                          \ need a copy for meta data  
  PARSE-NAME 2DUP PAD PLACE 
  MAKE-BLOCKS                    \ create the db. Closes file on completion
  R> PAD COUNT WRITE-META 
;

\ COMMAND to show a record on the screen 
: SHOW ( n -- ) REC# ! .RECORD ;

\ command to set the active database file 
: DATABASE= ( <text> ) PARSE-NAME 2DUP OPEN-BLOCKS ;    

\ COMMAND to set the active record number
: REC     REC# ! ;

\ COMMAND to move to the next REC# 
: >>   REC# DUP 1+! @ SHOW  ;

\ COMMAND to move the previous REC# 
: <<   REC# @  1-  1 MAX  REC# !  REC# @ SHOW ;

: EDIT ( x y --)   ;

\  === DEMO CODE ===
\ create a a dummy record
: DUMMYREC  ( -- )  
    REC# @ UINT>$ [REC ID#] PLACE 
    S" Howard"    [REC NAME] PLACE
    S" Smith"      [REC FAMILY] PLACE
    S" 213 Lincoln Park Ave." [REC ADDRESS] PLACE
    S" Markham"  [REC CITY] PLACE
    S" Ontario"  [REC PROV] PLACE
    S" Canada"   [REC COUNTRY] PLACE
    S" (201)"    [REC AREACODE] PLACE
    S" 555-1212" [REC PHONE#] PLACE
    LASTREC 1+!   
;    

\ create a new database 
DECIMAL 
100 BLOCKS DSK8.EMPLOYEES  

DATABASE= DSK8.EMPLOYEES

: FILLDB  ( -- ) 
    LASTREC OFF 
    50 1  
    DO  
      I . 
      I RECORD EMPLOYEE-REC-SIZE ERASE
      I REC# ! DUMMYREC  UPDATE 
    LOOP 
    FLUSH ;   

\  FILLDB   \ make a dummy database 
