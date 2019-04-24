\ simple block editor words based on HsForth circa 1992

NEEDS $ACCEPT FROM DSK1.INPUT

VARIABLE #LINE

HEX
: <LINE>  ( l# s# - addr #c )
        BLOCK  SWAP  C/L @ *  + 40  C/L @ ;

: .LINE   ( l# s# - )
        <LINE> -TRAILING  TYPE  #LINE 1+! ;

: LIST  ( s# - )
        CR
        DUP SCR ! ." SCR#"  U.
        10 0
         DO
             CR  I 3 .R SPACE   I SCR @ .LINE
         LOOP
         CR ;

: PP
        0 TEXT PAD 1+ SWAP  SCR @ <LINE> CMOVE UPDATE ;

: PL
        0D EMIT OUT OFF
        C/L @ SPACES
        0D EMIT
        ." ?"
        0D EMIT
        DUP SCR @ <LINE> PAD 2DUP C! 1+ SWAP CMOVE $ACCEPT
        1+ SWAP scr @ <LINE> CMOVE UPDATE ;

: .INDEX   0 SWAP .LINE ;                              \      scr -

: CLEAR ( n -- )
        BUFFER B/BUF BLANK  UPDATE ;                   \  scr -

: COPY  ( n -- )
        SAVE-BUFFERS    SWAP  BLOCK  2-  !  UPDATE ;   \  from to -

: THRU  ( 1st-block last-block -- )
        1+ SWAP
        DO
            I U. I LOAD
        LOOP ;

: CR'S  ( n -- )
        0 DO
             CR #LINE 1+!
          LOOP ;

: FORM-FEED
        0C EMIT  #PAGE 1+!   #LINE 0!  ;

: .PAGE#
        #PAGE @ IF ." page:" #PAGE @ 3 .R THEN ;

: .HEADER
        CR  ACTIVE $.
        TAB  TAB  TIME@ TIME->$ $. SPACE SPACE DATE@ DATE->$ $. ;

: .FOOTER
        CR  CR
        L/PAGE #LINE @ -  CR'S
        0F CTAB ." HS/FORTH V5.0" 10 SPACES ." Intelect Systems"
        CR 40 CTAB .PAGE#
        FORM-FEED ;

: ?FORMFEED  #LINE @  L/PAGE > IF .FOOTER .HEADER  THEN ;

: INDEX    ( from,to -- )
           DECIMAL
           HIGHBLK @ 1- MIN
           OVER L/PAGE / 1+ #PAGE !      \ calculate page# for 1st blk
           #LINE 0!
           .HEADER CR CR
           1+ SWAP
           DO  CR  I 4 .R  4 SPACES  I .INDEX  ?FORMFEED  1 /LOOP
          .FOOTER ;

: 3'S    3 / 3 * ;

: TRIAD  ( scr# -- )
        DECIMAL
        #PAGE 0! .HEADER
        3'S DUP 3 + SWAP
        DO CR I LIST LOOP
        .FOOTER ;

: TRIADS  ( from,to -- )
           3'S  1+ SWAP  3'S   DO  I TRIAD  3 +LOOP ;

: LISTING  0 HIGHBLK @ 2 - TRIADS ;
