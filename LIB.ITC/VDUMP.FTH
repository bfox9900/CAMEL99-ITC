\ VDP ram dump utility
\ this is wasteful.   Should make a deferred word  mem@  memc@ can
\ read CPU ram or VDP by selection.
HEX

: V.ASCII ( adr n --)
          BOUNDS
          DO
            I VC@ DUP
            BL 1-  80 WITHIN
            0= IF DROP  '.'
            THEN EMIT
          LOOP ;


: VDUMP   ( offset n -- )
         BASE @ >R
         HEX
         BOUNDS   ( -- endadr startadr)
         DO PAUSE
         CR  I  .####  ':' EMIT
             I  ?80  BOUNDS DO  SPACE I V@ .####  2 +LOOP SPACE
             I  ?80  .ASCII
             ?BREAK
          ?80 +LOOP
          CR
          R> BASE ! ;
