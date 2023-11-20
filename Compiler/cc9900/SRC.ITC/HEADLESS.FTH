\ HEADLESS.FTH  explores using VDP RAM for word names  June 11 2023

INCLUDE DSK1.VDPMEM
: VALIGN    VHERE ALIGNED VP ! ;

: VS,       ( c-addr u -- ) VHERE OVER 1+ VALLOT VPLACE VALIGN ;

NEEDS .S     FROM DSK1.TOOLS
NEEDS S=     FROM DSK1.COMPARE
NEEDS 4TH    FROM DSK1.3RD4TH

: 2OVER    ( a b c d -- a b c d a b) POSTPONE 4TH  POSTPONE 4TH ; IMMEDIATE

: FIND-NAME ( addr len -- nfa ) \ nfa is "name field address"
           CONTEXT @ @  ( -- nfa )
           BEGIN DUP
           WHILE ( tos<>0)
              DUP 1+ 2OVER S=
           WHILE ( compare<>0)
              NFA>LFA @   ( follow link to next name)
           REPEAT
           THEN NIP NIP ;

: NFA>XT ( nfa -- XT -1|0|1)
          ?DUP 0= IF 0 EXIT THEN
          DUP NFA>CFA
          SWAP 1- C@ DUP 0= OR
;


: VDP.FIND-NAME ( wid -- ) 


;


: VHEADER,  ( addr len --)
      ALIGN
      CURRENT @ @ ,        \ get last NFA & compile in this LFA field
      0 VC,                 \ compile the precedence byte (immediate flag)
      VHERE >R              \ save HERE (ie: new NFA location)
      VS,                   \ compile (addr len) as counted string
      WARNINGS @
      IF
        R@ VDP.FIND ( xt ?) NIP ( ?)
        IF
          SPACE  R@ VCOUNT 1F AND VDP.TYPE  ."  isn't unique "
        THEN
      THEN
      R> DUP LATEST !     \ HERE is NFA of last word defined
      CURRENT @ !  \ Also store in the current 'WID'
;

