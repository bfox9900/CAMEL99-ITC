\ simple block editor at utilities for BLOCKS
\ From HsForth circa 1991 James Kalihan, deceased
\ modified for Camel99 forth 

NEEDS BLOCKS    FROM DSK1.BLOCKS
NEEDS -TRAILING FROM DSK1.TRAILING 
NEEDS .R        FROM DSK1.UDOTR 

DECIMAL 
: LINE  ( line# -- addr )  8* 8*  SCR @ BLOCK + ;
: <LINE>  ( line# - addr n ) LINE 64  ;

: .LINE   ( l# -- ) <LINE> -TRAILING  TYPE  LINES 1+! ;

: LIST  ( s# - )
  CR
  DUP SCR ! ." SCR#" 4 U.R
  10 0
  DO
    CR  I 3 .R SPACE   I .LINE
  LOOP
  CR ;

: ?LINE#  ( n -- n) DUP 0 16 WITHIN 0= ABORT" 0..15 expected" ;

: PP  ( n -- ) ?LINE# >R  0 PARSE  R> LINE SWAP MOVE UPDATE ;

: .INDEX   0 SWAP .LINE ; 
: CLEAR ( n -- ) BUFFER B/BUF BLANK  UPDATE ;      
: COPY  ( n -- ) FLUSH  SWAP  BLOCK  2- ! UPDATE ; 
: THRU  ( 1st last -- )
        2DUP > ABORT" Can't go backwards" s
        1+ SWAP DO  I U.  I LOAD   LOOP ;

: CR'S  ( n -- )  0 DO   CR LINES 1+!  LOOP ;
: FORM-FEED ( -- )    0C EMIT  #PAGE 1+!   LINES OFF  ;
: .PAGE#     #PAGE @ IF ." Page:" #PAGE @ 3 .R THEN ;

: .HEADER
        CR  ACTIVE $.
        TAB  TAB  TIME@ TIME->$ $. SPACE SPACE DATE@ DATE->$ $. ;

: .FOOTER
        CR  CR
        L/PAGE LINES @ -  CR'S
        0F CTAB ." Camel99 Forth" 10 SPACES ." by Brian Fox"
        CR 40 CTAB .PAGE#
        FORM-FEED ;

: ?FORMFEED  LINES @  L/PAGE > IF .FOOTER .HEADER  THEN ;

: INDEX    ( from,to -- )
           DECIMAL
           HIGHBLK @ 1- MIN
           OVER L/PAGE / 1+ #PAGE !      \ calculate page# for 1st blk
           LINES OFF
           .HEADER CR CR
           1+ SWAP
           DO  CR  I 4 .R  4 SPACES  I .INDEX  ?FORMFEED  1 /LOOP
          .FOOTER ;

: 3'S    3 / 3 * ;

: TRIAD  ( scr# -- )
        DECIMAL
        #PAGE OFF .HEADER
        3'S DUP 3 + SWAP
        DO CR I LIST LOOP
        .FOOTER ;

: TRIADS  ( from,to -- )
           3'S  1+ SWAP  3'S   DO  I TRIAD  3 +LOOP ;

: LISTING  0 HIGHBLK @ 2 - TRIADS ;

: \     ( -- )
        source-id @ ABS 1-
        IF      [COMPILE] \
        ELSE    >IN @ 40 + -40 AND  >IN !
        THEN ;
        IMMEDIATE

: \S    ( -- )
        B/BUF >IN ! ; IMMEDIATE


\ ---- screen to file conversion
\ $" sourcef"   OPEN-BLOCKS                               To copy screens
\ $" dest-file" MAKE-OUTPUT                                      into a file
\                    OUTPUT @ scr#  BLOCKS->FILE          Do for each screen
\              CLOSE-OUTPUT         CLOSE-SCREEN

VARIABLE CTRL-Z  1A CTRL-Z !

: BLOCKS->FILE  ( n scr# -- )
        FIRST cell+ SWAP  RSCRNF                     \  >handle  scr# --
        LISTS @  SWAP                             \   >handle seg buf
        10 0
        DO
          2dup  40 -TRAILING ?DUP
          IF
             2dup + DUP>R DUP@ >R 0A0D SWAP !  cell+ DUP>R
             6 PICK WRITEH R> - ABORT" Write Failed"    DR> !
          ELSE  2drop
          THEN  40 +
        LOOP
        2drop LISTS @ CTRL-Z 1 4 PICK WRITEH DROP
        0 0 3 PICK LSEEK++ -1 -1 D+ ROT LSEEK 2drop ;

SF-IO  F-IO
\ ---- prompted screen to file conversion
: BLOCKS-TO-FILE ( -- )
        CR ." Source file for screens" IN$  OPEN-BLOCKS
        CR ." Append to old destination file? " ?YN
        CR ." Destination file" IN$ SWAP
        IF
            OPEN-OUTPUT -1 -1 OUTPUT @ LSEEK+  2drop
        ELSE
            MAKE-OUTPUT
        THEN
        BEGIN
          CR ." First screen to copy (0 to end)" #IN ?DUP
        WHILE
          ."  Last screen" #IN  2dup <=
          IF
              1+ SWAP
              DO
                  OUTPUT @ I BLOCKS->FILE
              LOOP
          THEN
        REPEAT
        CLOSE-OUTPUT CLOSE-BLOCKS ;
DECIMAL

[then]
