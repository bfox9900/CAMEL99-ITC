\ Block utilities

NEEDS DUMP      FROM DSK1.TOOLS
NEEDS BLOCK     FROM DSK1.BLOCKS
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS 80COLS     FROM DSK1.80COL

DECIMAL
: COLD  TEXT COLD ;

63 CONSTANT L/PAGE

VARIABLE #LINE
VARIABLE #PAGE

: LINE  ( l# -- addr n)  64 *  SCR @ BLOCK + 64   ;
: .LINE   ( l# -- ) LINE -TRAILING 0 MAX TYPE  ;

: CR   CR  #LINE 1+! ; \ count lines

: LIST  ( s# - )
        CR
        DUP SCR ! ." SCR#"  3 .R
        16 0 DO  CR  I 3 .R  [CHAR] | EMIT I .LINE  LOOP
        CR ;

: BLANK ( n -- ) 0 FILL ;
: CELL-  2- ;
: CLEAR ( n -- ) BUFFER B/BUF BLANK  UPDATE ;
: COPY  ( n -- ) FLUSH  SWAP  BLOCK CELL- !  UPDATE ;
: THRU  ( 1st-block last-block -- )  1+ SWAP DO  I DUP . LOAD  LOOP ;

: CR'S  ( n -- )  0 ?DO   CR  LOOP ;

: FORM-FEED      12 EMIT  #PAGE 1+!   #LINE OFF ;
: .PAGE#         #PAGE @ IF ." Page:" #PAGE @ 3 .R THEN ;


: .FOOTER
   CR  CR
   L/PAGE #LINE @ -  CR'S
   4 SPACES ." Camel99 Forth"  40 SPACES ." Brian Fox 2022"
   CR 35 SPACES .PAGE# ;

: ?FORMFEED  #LINE @  L/PAGE > IF .FOOTER FORM-FEED .HEADER  THEN ;

: .INDEX   0 .LINE ;

: INDEX    ( from,to -- )
           DECIMAL
           HIGHBLK @ 1- MIN
           OVER L/PAGE / 1+ #PAGE !      \ calculate page# for 1st blk
           #LINE OFF
           .HEADER CR CR
           1+ SWAP
           DO  CR  I 4 .R  4 SPACES  I SCR !  .INDEX  ?FORMFEED  LOOP
          .FOOTER ;

: 3'S    3 / 3 * ;

: TRIAD  ( scr# -- )
        DECIMAL
        #PAGE OFF
        .HEADER
        3'S DUP 3 + SWAP   DO CR I LIST LOOP
        .FOOTER ;

: TRIADS  ( from,to -- )  3'S  1+ SWAP  3'S DO  I TRIAD  3 +LOOP ;

: LISTING  0 HIGHBLK @ 2 - TRIADS ;
