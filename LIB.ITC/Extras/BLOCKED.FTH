\ simple block editor words based on HsForth circa 1992
\ ported and heavily modified for CAMEL99 Forth Mar 2021 Fox

NEEDS DUMP  FROM DSK1.TOOLS
NEEDS BLOCK FROM DSK1.BLOCKS
NEEDS .R    FROM DSK1.UDOTR
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS 80COLS FROM DSK1.80COL

80COLS

VARIABLE #LINE
VARIABLE SCR

DECIMAL
: LINE  ( l# -- addr n)  64 *  SCR @ BLOCK + 64 -TRAILING  ;
: .LINE   ( l# -- addr) LINE TYPE ;

: LIST  ( s# - )
        CR
        DUP SCR ! ." SCR#"  U.
        16 0
        DO
          CR  I 3 .R  SPACE  I .LINE
        LOOP
        CR ;

: PP  ( line# -- <TEXT> )
        1 PARSE  PAD PLACE
        PAD COUNT LINE SWAP CMOVE UPDATE ;

: PL
        DUP SCR @ <LINE> PAD 2DUP C! 1+ SWAP CMOVE $ACCEPT
        1+ SWAP scr @ <LINE> CMOVE UPDATE ;

: .INDEX ( blk# --)   0 SWAP .LINE ;
: CLEAR ( n -- ) BUFFER B/BUF BLANK  UPDATE ;

: COPY  ( src dst -- ) FLUSH SWAP  BLOCK  2- !  UPDATE ;

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
