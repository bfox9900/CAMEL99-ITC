\ Traditional INDEX for block files
\ Line 0 of each block must hold a comment describing the code

: .INDEX ( blk# --)   0 SWAP .LINE ;

: CR'S  ( n -- )
        0 DO
             CR #LINE 1+!
          LOOP ;

: FORM-FEED   0C EMIT  PAGE# 1+!   #LINE 0!  ;

: .PAGE#      PAGE# @ IF ." page:" PAGE# @ 3 .R THEN ;

: .HEADER
  CR  ACTIVE $.
  TAB  TAB  TIME@ TIME->$ $. SPACE SPACE DATE@ DATE->$ $. ;

: .FOOTER
        CR  CR
        L/PAGE #LINE @ -  CR'S
        0F CTAB ." Camel99 Forth" 10 SPACES ." Brian Fox"
        CR 40 CTAB .PAGE#
        FORM-FEED ;

\ : ?FORMFEED  #LINE @  L/PAGE > IF .FOOTER .HEADER  THEN ;

: INDEX    ( from,to -- )
           DECIMAL
           HIGHBLK @ 1- MIN
           OVER L/PAGE / 1+ PAGE# !      \ calculate page# for 1st blk
           #LINE 0!
           .HEADER CR CR
           1+ SWAP
           DO  CR  I 4 .R  4 SPACES  I .INDEX ( ?FORMFEED)  1 /LOOP
          .FOOTER ;

: 3'S    3 / 3 * ;

: TRIAD  ( scr# -- )
        DECIMAL  PAGE# OFF
         .HEADER
        3'S DUP 3 + SWAP
        DO CR I LIST LOOP
        .FOOTER ;

: TRIADS  ( from,to -- )
           3'S  1+ SWAP  3'S   DO  I TRIAD  3 +LOOP ;

: LISTING  0 HIGHBLK @ 2 - TRIADS ;
