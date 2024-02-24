\ linput reads file record into a counted string more like BASIC 2024 Fox

NEEDS SELECT FROM DSK1.ANSFILES 

: LINPUT  ( $ handle -- )
    SELECT                \ select file PAB
    DUP 1+   ( -- $ addr ) 
    2 FILEOP ?FILERR      \ read file, test error#
    FGET ( -- u)          \ get PAB data into RAM 
    R> SWAP C!            \ update string length
;

