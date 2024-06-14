CR .( Sound control examples )

NEEDS HZ  FROM DSK1.SOUND

HEX
: ATT  ( n -- )  ATT @ OR SND! ;  \ fast attenuator (volume control)

\ envelope control
: WAIT     ( n -- )      0 ?DO LOOP ;   \ ~100us delay

: DECAY    ( speed -- ) 
  DUP 0= IF DROP EXIT THEN 
  10   0  DO  I ATT  DUP WAIT  LOOP DROP  ;

: ATTACK   ( speed -- ) 
  DUP 0= IF DROP EXIT THEN 
  0  0F  DO  I ATT  DUP WAIT  -1 +LOOP  DROP  ;

DECIMAL
: BELL    ( -- ) GEN1 1100 HZ  0 ATT   50 WAIT   1500 DECAY 50 TICKS MUTE ;
: CLINK   ( -- ) GEN2 1464 HZ  0 ATT   50 WAIT    250 DECAY MUTE ;
: CLUNK   ( -- ) GEN3  200 HZ  0 ATT  100 WAIT    250 DECAY MUTE ;
.( .)
: SWOOSH   ( -- )
        5 NOISE
        100 ATTACK
        600 DECAY
        MUTE ;

: OCEAN    ( -- )  5 NOISE  1000 ATTACK  4400 DECAY MUTE ;
.( .)

: 1/8      500 WAIT 700 DECAY  MUTE ;  \ U.K semi-quaver
: 1/4     1000 WAIT 1400 DECAY MUTE ;  \ U.K quaver

: BASS  ( n -- )
    15 *  GEN3  HZ MUTE   \ apply freq x 15 to GEN3 but mute it.
    3 NOISE 0 DB          \ NOISE 3 freq. is controlled by GEN3
;
.( .)
: THERUN     45 BASS 1/8  50 BASS 1/8  57 BASS 1/8 ;
: THELINE    60 BASS 1/4  45 BASS 1/4  60 BASS 1/8 ;

: COUNTRY  3 0 DO THERUN THELINE LOOP ;

CR .( Try these words:)
CR .( BELL  CLINK  CLUNK  SWOOSH  OCEAN)
CR .( Try this: COUNTRY)
CR .( Generates a bass line)
