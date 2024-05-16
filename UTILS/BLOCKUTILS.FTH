\ simple block editor at utilities for BLOCKS

NEEDS BLOCK FROM DSK1.BLOCKS
NEEDS .R     FROM DSK1.UDOTR 
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS 80COLS FROM DSK1.80COL

80COLS 

DECIMAL 
VARIABLE #LINE 
: 'LINE  ( n -- addr) 64 *  SCR @ BLOCK  + ;

: LINE$ ( line# - addr n ) 'LINE 64 ;

: .LINE   ( l# - )  LINE$ -TRAILING 0 MAX TYPE ;

: LIST  ( s# - )
        CR
        DUP SCR ! ." SCR#"  U.
        16 0
        DO
            CR  I 2 .R SPACE   I .LINE 
        LOOP
        CR ;

S" DSK7.FBLOCKS" OPEN-BLOCKS 


: .INDEX   0 .LINE ;  

: CLEAR ( n -- ) BUFFER B/BUF BLANK  UPDATE ;
: COPY  ( from to -- ) FLUSH  SWAP  BLOCK  2- ! UPDATE ;
: SMOVE ( from to n ) 1+ BOUNDS DO  DUP I COPY  1+  LOOP FLUSH ;

: THRU  ( 1st last -- )
        2DUP > ABORT" Can't go backwards" s
        1+ SWAP DO  I U.  I LOAD   LOOP ;

: CR'S  ( n -- )  0 DO   CR #LINE 1+!  LOOP ;

: FORM-FEED ( -- )  0C EMIT  #PAGE 1+!   #LINE OFF  ;

: .PAGE#
        #PAGE @ IF ." Page:" #PAGE @ 3 .R THEN ;

: .HEADER  CR  ACTIVE COUNT TYPE ; 

: .FOOTER
        CR  CR
        L/PAGE #LINE @ -  CR'S
        0F CTAB ." Camel99 Forth" 10 SPACES ." by Brian Fox"
        CR 40 SPACES .PAGE#
        FORM-FEED ;

: ?FORMFEED  #LINE @  L/PAGE > IF .FOOTER .HEADER  THEN ;

: INDEX    ( from,to -- )
           DECIMAL
           HIGHBLK @ 1- MIN
           OVER L/PAGE / 1+ #PAGE ! \ calculate page# for 1st blk
           #LINE OFF
           .HEADER CR CR
           1+ SWAP
           DO  
               CR  I 4 .R  4 SPACES  I .INDEX  
               ?FORMFEED  
           1 +LOOP
          .FOOTER ;

: 3'S    3 / 3 * ;

: TRIAD  ( scr# -- )
        DECIMAL
        #PAGE OFF .HEADER
        3'S DUP 3 + SWAP
        DO 
          CR I LIST 
        LOOP
        .FOOTER ;

: TRIADS  ( from,to -- )
           3'S  1+ SWAP  3'S   DO  I TRIAD  3 +LOOP ;

: LISTING  0 HIGHBLK @ 2 - TRIADS ;
HEX
: \     ( -- )
        SOURCE-ID @ ABS 1-
        IF   POSTPONE \
        ELSE >IN @ 40 + -40 AND  >IN !
        THEN ; IMMEDIATE

: \S    ( -- )  B/BUF >IN ! ; IMMEDIATE

DECIMAL
