\ CAT command: read a TI disk directory
HEX
\ TI Floppy-disk directory record
\ filename   TYPE     records  REC LEN
\ --------   -------  -------  -------
\ len,name,  8,float, 8,float  8,float

NEEDS OPEN-FILE FROM DSK1.ANSFILES
NEEDS CASE      FROM DSK1.CASE
 
\ print unsigned int, right justified
: U.R  ( u n --) >R 0 <# #S #> ( adr len) R> OVER - SPACES TYPE ;
 
\ string helpers
: $.       ( $addr -- ) COUNT TYPE ;
: NEXT$    ( addr len -- addr len ) + COUNT ;
 
\ print string left justified '
: $.LEFT  ( $ width -- ) OVER C@ - >R $.  R> SPACES ;
 
HEX
\ crude 3 DIGIT BCD to int convertor. Limited to 999
: F>INT   ( addr len -- addr len n)
          OVER C@  ( -- mantissa)
          CASE
            0 OF  0                    ENDOF
           40 OF  OVER 1+ C@           ENDOF
           41 OF  OVER 1+ C@ 64 * >R
                  OVER 2+ C@  R> +     ENDOF
           ( default)  -1  \ bad # indicator
           ENDCASE ;
DECIMAL
: DIR.TYPE  ( addr -- )
          F>INT
          CASE
             1 OF ." Txt/Fix"  ENDOF
             2 OF ." Txt/Var"  ENDOF
             3 OF ." Bin/Fix"  ENDOF
             4 OF ." Bin/Var"  ENDOF
             5 OF ." Program"  ENDOF
             ." ????"
          ENDCASE ;
 
: HEAD.REC ( addr -- )
          DUP  7 $.LEFT SPACE COUNT ( addr len)
          NEXT$
          ."  Size" NEXT$ F>INT 5 U.R   ."  Used" NEXT$ F>INT 5 U.R
          2DROP  ;
 
: DIR.REC ( addr -- )
          DUP  11 $.LEFT SPACE COUNT ( addr len)
          NEXT$ DIR.TYPE
          NEXT$ F>INT 7 U.R
          NEXT$ F>INT 7 U.R
          2DROP  ;

: PAGEBRK ( -- )
          LINES @ L/SCR 3 - MOD 0=  \ bottom of page?                                 
          IF
            CR ." Press any key..." KEY DROP
          THEN ;

: CAT  ( <DSK?.> )   \  needs the '.' ONLY shows file name
          BASE @ >R  DECIMAL
          BL PARSE-WORD
          RELATIVE 256 FIXED  R/O BIN OPEN-FILE ?FILERR
          >R                        \ store file handle

          PAD 80 R@ READ-LINE ?FILERR 2DROP
          CR PAD HEAD.REC
          CR 13 SPACES  ." -type-  -sect- -b/rec-"

          LINES OFF
          BEGIN
             PAD DUP 80 R@ READ-LINE ?FILERR 2DROP
           ( PAD)  C@   \ do while length > 0
          WHILE
             PAD CR DIR.REC
             1 LINES +!
             PAGEBRK
             ?TERMINAL
             IF
                R> CLOSE-FILE
                CR ." *BREAK*" ABORT
             THEN
          REPEAT
          R> CLOSE-FILE  ?FILERR
          CR LINES @ . ." files" CR
          R> BASE ! ;

 
