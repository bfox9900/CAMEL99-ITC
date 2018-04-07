\ read a TI disk directory
HEX
\ TI Floppy-disk directory record
\ filename   TYPE     records  REC LEN
\ --------   -------  -------  -------
\ len,name,  8,@,int, 8,@,int  8,@,int

MARKER DIRTEST

\ unsigned single (16bit)  print, right justified
: U.R  ( ud n --) >R 0 <# #S #> ( adr len -- ) R> OVER - SPACES TYPE ;

\ print string left justified
: $.LEFT  ( $ width -- ) OVER C@ - >R COUNT TYPE   R> SPACES ;


VARIABLE X

: NEXT$    ( $addr -- adr len )  + COUNT ;

DECIMAL
\ simple 2 DIGIT BCD to int convertor
: F>INT   ( addr len -- n)
          OVER C@ 64 - >R   ( R-- mantissa)
          OVER DUP 1+ C@ 10 *
          OVER     2+ C@ +
          R@ 0= 
          IF   10 / R> DROP
          ELSE  R> 10 * *
          THEN ;


: DIR.#  ( addr -- )  F>INT 5 U.R ;

: DIR.REC ( addr -- )
          DUP
          CR 10 $.LEFT  COUNT NEXT$ DIR.#  NEXT$ DIR.#  NEXT$ DIR.#
          2DROP 2DROP DROP
 ;

HEX
: DIR  ( <DSK?.> )   \  needs the '.' ONLY shows file name
          BL PARSE-NAME
          RELATIVE 100 FIXED  R/O BIN   OPEN-FILE  ?FILERR
          >R                    \ push handle onto Return stack
          DECIMAL
          PAD 50 R@ READ-LINE ?FILERR
          CR PAD COUNT TYPE
          LINES OFF
          BEGIN
             PAD 50 R@ READ-LINE ?FILERR
          WHILE
             DROP               \ don't need the byte count
             PAD DIR.REC
(     1 X +!)
(     X @ 09 >   \ )
          ?TERMINAL
          IF R> CLOSE-FILE      \ if detected we're done here
                2DROP
                CR CR ." *BREAK*" ABORT
          THEN 1 LINES +!
          REPEAT
          R> CLOSE-FILE
          2DROP 2DROP
          DECIMAL
          CR CR LINES @ . ." files"
          HEX ;
