\ SOUND Envelope control

DECIMAL
: DELAYS   ( -- ) 0 ?DO LOOP ;  \ simple delay loop ~106uS/loop

: ATTACK ( time -- )
         ?DUP 0>  \ if it's zero attack time, just skip it
         IF  0 15 DO   I ATTENUATE  DUP TICKS    -1 +LOOP DROP
         THEN ;

: ONTIME ( time -- ) ?DUP 0> IF   MS  THEN  ;

: DECAY  ( time -- )
         ?DUP 0>
         IF    15 0 DO  I DB DUP DELAYS   LOOP DROP MUTE
         ELSE  MUTE
         THEN ;

VARIABLE ATAK   VARIABLE ONTM   VARIABLE DCAY


: ENV-PLAY  ( -- )

             ATAK @ ATTACK
             ONTM @ ONTIME
             DCAY @ DECAY ;

: DUP3   ( a b c -- a b c a b c )  2 PICK 2 PICK 2 PICK ;

: ENVELOPE ( att% on% dec% -- )
           DUP3 + + 100 > ABORT" Envelope>100%"
           NOTE >R    ( R-- note_duration)
           R@ SWAP %  ATAK !
           R@ SWAP %  ONTM !
           R> SWAP %  DCAY ! ;


: PING  ( HZ -- )  HZ  1200 DECAY ;
: BLIP  ( HZ -- )  HZ  0 10 90 ENVELOPE ;


