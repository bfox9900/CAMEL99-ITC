\ DATA and BYTE directive with comma delimiting
\ More compatible with TI ASM DATA statements Jan 2018

\ Usage:
\ HEX
\ DATA DEAD,BEEF,AABB
\ DATA 0001,2200,3300,4440
\ BYTE 00,01,02,03,FF,BEEF  (aborts on 'BEEF')


HEX
: BYTE ( -- )
         BEGIN
           [CHAR] , PARSE-WORD  DUP
         WHILE
            EVALUATE  DUP FF00 AND  ABORT" Not a byte"
            C,
         REPEAT 
         2DROP ;

: DATA ( -- )
         BEGIN
            [CHAR] , PARSE-WORD  DUP
         WHILE
            EVALUATE ,
         REPEAT 
         2DROP ;