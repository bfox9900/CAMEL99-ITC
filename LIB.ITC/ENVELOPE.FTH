\ SOUND Envelope control

NEEDS DB FROM DSK1.SOUND

DECIMAL
: DELAYS   ( -- ) 0 ?DO 4 TICKS LOOP ;  \ simple delay loop ~106uS/loop

: ATTACK ( time -- )
         ?DUP 0= IF 0 DB EXIT THEN
         0 15 DO   I DB  DUP DELAYS    -1 +LOOP DROP  ;

: ONTIME ( time -- ) ?DUP 0> IF  DELAYS   THEN  ;

: DECAY  ( time -- )
         ?DUP 0= IF MUTE  EXIT THEN
         15 0 DO  I DB DUP DELAYS   LOOP DROP MUTE ;

: ENVELOPE ( attack on decay -- )
         >R >R  ATTACK  R> ONTIME R> DECAY ;

DECIMAL
: PING  (  -- )  1200 HZ  0 30 70 ENVELOPE  ;
: BLIP  ( --  ) 2000 HZ  0 40 0  ENVELOPE ;
: BONG          110 HZ   0 50 100 ENVELOPE ;
