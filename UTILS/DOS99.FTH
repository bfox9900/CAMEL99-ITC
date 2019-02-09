\ simple disk utilities

NEEDS OPEN-FILE  FROM DSK1.ANSFILES
NEEDS VALUE      FROM DSK1.VALUES
NEEDS CASE       FROM DSK1.CASE

HERE
\ simple spinner to show activity
VARIABLE S
CREATE SPNR  CHAR | C, CHAR / C, CHAR - C, CHAR \ C,
: SPNR[S] ( -- addr) SPNR S @ + ;
: S++     ( -- )  S @ 1+ 3 AND S ! ;
: SPINNER ( -- ) SPNR[S] C@ EMIT BS S++ ;

\ use for file handles as needed
HEX
0 VALUE #1    0 VALUE #2   0 VALUE #3

\ CR if near end of screen
DECIMAL
: ?CR     OUT @ 10 + C/L@ > IF CR THEN ;

HEX
\ print unsigned int, right justified
: U.R  ( u n --) >R 0 <# #S #> ( adr len) R> OVER - SPACES TYPE ;

\ string helpers
: ARG$  ( -- addr len ) BL PARSE-WORD DUP ?FILE ;
: $.       ( $addr -- ) COUNT TYPE ;
: $.LEFT   ( $ width -- ) OVER C@ - >R $.  R> SPACES ;
: NEXT$    ( addr len -- addr' len') + COUNT ;

: SPACEBAR ( -- ) KEY? IF BEGIN KEY? UNTIL THEN ;

: ?BREAK-FILE ( hndl -- )
          ?TERMINAL
          IF CLOSE-FILE
             CR CR ." *BREAK*" ABORT
          ELSE
            DROP
          THEN ;

\ frequently used phrases
: OPEN  ( addr len -- ior ) OPEN-FILE ?FILERR ;
: CLOSE ( hndl -- )         CLOSE-FILE ?FILERR ;
: READH ( hndl -- )         READ-LINE ?FILERR 2DROP ;

: OPEN-CATFILE ( adr len -- hndl) RELATIVE 100 FIXED R/O BIN OPEN ;

\ 3 DIGIT BCD to int convertor. Limited to 999
HEX
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
          DECIMAL
          DUP  7 $.LEFT SPACE COUNT ( addr len)
          NEXT$
          ."  Size " NEXT$ F>INT 5 U.R   ."  Used " NEXT$ F>INT 5 U.R
          2DROP ;

: DIR.REC ( addr -- )
          DUP  11 $.LEFT SPACE COUNT ( addr len)
          NEXT$ DIR.TYPE
          NEXT$ F>INT 7 U.R
          NEXT$ F>INT 7 U.R
          2DROP ;

\ ========================================
\ *
\ * User commands: CAT DIR MORE DEL COPY
\ *

: CAT  ( <DSK?.> )   \  needs the '.' ONLY shows file name
          BASE @ >R DECIMAL
          ARG$ OPEN-CATFILE >R  \ store file handle

          PAD 80 R@ READH
          CR PAD HEAD.REC
          CR 13 SPACES  ." -type-  -sect- -b/rec-"

          LINES OFF
          BEGIN
             PAD DUP 80 R@ READH
           ( PAD)  C@   \ do while length > 0
          WHILE
             CR PAD DIR.REC
             1 LINES +!
             SPACEBAR
             R@ ?BREAK-FILE
          REPEAT
          R> CLOSE
          CR LINES @ . ." files" CR
          R> BASE ! ;
HEX
: DIR  ( <DSK?.> )
          ARG$ OPEN-CATFILE >R  \ push handle

          PAD 50 R@ READH
          CR PAD HEAD.REC CR

          LINES OFF
          BEGIN
            PAD DUP 80 R@ READH
          ( PAD) C@   \ do while length <> 0
          WHILE
             PAD 0C $.LEFT ?CR
             1 LINES +!
             SPACEBAR
             R@ ?BREAK-FILE
          REPEAT
          R> CLOSE
          DECIMAL
          CR LINES @ . ." files" CR
          HEX ;

: MORE  ( <filename>)
          ARG$ DV80 R/O OPEN >R
          BEGIN
             PAD DUP 50 R@ READ-LINE ?FILERR ( adr len flag)
          WHILE
             CR TYPE
             SPACEBAR
             R@ ?BREAK-FILE
          REPEAT
          R> CLOSE
          2DROP ;

: DEL   ( <filename>) ARG$ DELETE-FILE ?FILERR  ;

: COPY ( <file1> <file2> )
        ARG$ ARG$  ( -- addr len addr len )
        DV80 W/O OPEN TO #2
        DV80 R/O OPEN TO #1
        52 DUP MALLOC >R
        LINES OFF
        SPACE
        BEGIN
          R@  50  #1 READ-LINE ?FILERR ( -- #bytes eof?)
        WHILE
          R@ SWAP #2 WRITE-LINE ?FILERR
          LINES 1+!
          SPINNER
        REPEAT
        R> DROP                 \ DROP buffer address from rstack
      ( 52) MFREE               \ release the buffer memory
        #2 CLOSE
        #1 CLOSE
        BASE @ >R 
        DECIMAL
        CR ." Copy complete. " LINES @ . ." records"
        R> BASE ! ;

HERE SWAP - DECIMAL . .( bytes)