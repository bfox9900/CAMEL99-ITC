\ MYSTERIOUS EYES II                                         Jan 21 2021 Fox
\ demonstrates sprites, DATA statement, multi-tasking and saving binary program

\ INCLUDE DSK1.TOOLS  \ debug only

INCLUDE DSK1.DATABYTE
INCLUDE DSK1.MARKER         \ needed for LOCK
INCLUDE DSK1.MALLOC
INCLUDE DSK1.GRAFIX
INCLUDE DSK1.RANDOM
INCLUDE DSK1.DIRSPRIT
INCLUDE DSK1.MTASK99

DECIMAL
: CHARDEF4 ( data[] ascii# -- ) PAUSE  ]PDT 32 VWRITE ;

\ ****************************************
\ * Sprite Patterns
\ ****************************************
HEX
CREATE EYELIDS
RAM
  DATA 030C,1020,4040,8080    \ 0 Wide open
  DATA 8080,4040,2010,0C03
  DATA C030,0804,0202,0101
  DATA 0101,0202,0408,30C0

  DATA 030F,1F3F,4040,8080
  DATA 8080,4040,2010,0C03
  DATA C0F0,F8FC,0202,0101
  DATA 0101,0202,0408,30C0

  DATA 030F,1F3F,7F7F,8080
  DATA 8080,4040,2010,0C03
  DATA C0F0,F8FC,FEFE,0101
  DATA 0101,0202,0408,30C0

  DATA 030F,1F3F,7F7F,FFFF
  DATA 8080,4040,2010,0C03
  DATA C0F0,F8FC,FEFE,FFFF
  DATA 0101,0202,0408,30C0

  DATA 030F,1F3F,7F7F,FFFF
  DATA FFFF,4040,2010,0C03
  DATA C0F0,F8FC,FEFE,FFFF
  DATA FFFF,0202,0408,30C0

  DATA 030F,1F3F,7F7F,FFFF
  DATA FFFF,7F7F,2010,0C03
  DATA C0F0,F8FC,FEFE,FFFF
  DATA FFFF,FEFE,0408,30C0

  DATA 030F,1F3F,7F7F,FFFF
  DATA FFFF,7F7F,3F1F,0C03
  DATA C0F0,F8FC,FEFE,FFFF
  DATA FFFF,FEFE,FCF8,30C0

  DATA 030F,1F3F,7F7F,FFFF
  DATA FFFF,7F7F,3F1F,0F03
  DATA C0F0,F8FC,FEFE,FFFF
  DATA FFFF,FEFE,FCF8,F0C0    \ 7 FULLY CLOSED

DECIMAL
: ]EYELID  32 * EYELIDS + ;

CREATE PUPIL
HEX
  DATA 0000,0000,0001,0307
  DATA 0707,0301,0000,0000
  DATA 0000,0000,00C0,E0F0
  DATA F0F0,E0C0,0000,0000


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
DECIMAL

128 CONSTANT LEFTEYE
132 CONSTANT RIGHTEYE

136 CONSTANT LEFTPUPIL
140 CONSTANT RIGHTPUPIL

144 CONSTANT SCLERA     ( the white part of the eye)

VARIABLE FATIGUE    10 FATIGUE !
VARIABLE CALM       90 CALM    !

: BLINKER   FATIGUE @ MS  ;
: CLOSE2  ( -- )
    8 0 DO
        I ]EYELID DUP
        LEFTEYE  CHARDEF4
        RIGHTEYE CHARDEF4
        BLINKER
    LOOP ;

: OPEN2  ( -- )
    0 7 DO
        I ]EYELID DUP
        LEFTEYE  CHARDEF4
        RIGHTEYE CHARDEF4
        BLINKER
    -1 +LOOP ;

: BLINK2     CLOSE2 OPEN2 ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
CREATE EYE-XY  0 , 0 ,
EYE-XY    CONSTANT EROW
EYE-XY 2+ CONSTANT ECOL

: PIX.COL ( -- n)   ECOL @ 8* ;
: PIX.ROW ( -- n)   EROW @ 8* 1- ;

CHAR * CONSTANT '*'
CHAR ! CONSTANT '!'

: DEF.CHARS
  0 ]EYELID  LEFTEYE  CHARDEF4
  0 ]EYELID  RIGHTEYE CHARDEF4

  PUPIL LEFTPUPIL  CHARDEF4
  PUPIL RIGHTPUPIL CHARDEF4

  7 ]EYELID SCLERA CHARDEF4   ( define a white circle in 4 chars )
   SCLERA SET# 16 1 COLOR     ( make it white)
  2 MAGNIFY
  '*' SET# 13 1 COLOR
  '!' SET# 9  1 COLOR ;

: .EYELIDS
( char  colr    x             y       sp# -- )
    CLOSE2
   128   2    PIX.COL      PIX.ROW    0  SPRITE \ left eye
   132   2    PIX.COL 32 +  PIX.ROW   1  SPRITE \ left right
;

: .PUPILS
( char  colr     x             y      sp# -- )
   136   2     PIX.COL      PIX.ROW    2  SPRITE \ left pupil
   140   2     PIX.COL 32 +  PIX.ROW   3  SPRITE \ right pupil
;

: .SCLERA  ( col row --)
       2DUP AT-XY  144 EMIT 146 EMIT
         1+ AT-XY  145 EMIT 147 EMIT ;

: .2SCLERA  ( --)
        VROW 2@ 2>R  \ save cursor position
        EYE-XY 2@  2DUP .SCLERA
        SWAP 4 + SWAP .SCLERA
        2R> AT-XY  ; \ restore

: .EYES   ( col row -- ) EYE-XY 2! .2SCLERA  .EYELIDS  .PUPILS ;
: HORZ    ( offset -- )  DUP 2 SP.X VC!  32 +  3 SP.X VC! ;
: VERT    ( height -- )  DUP 2 SP.Y VC!  3 SP.Y VC! ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ TASKS
: BLINKING ( -- )
         BEGIN
           3000 RND FATIGUE @ + MS
           BLINK2
         AGAIN ;

: LEFT/RIGHT
         BEGIN
           2000 RND CALM @ + MS
           PIX.COL  9 RND 4 - +  HORZ
         AGAIN ;

DECIMAL
C/SCR @ 1-  CONSTANT N  \ chars per screen - 1

: THING
     BEGIN
        PAGE
        10 10 OPEN2 .EYES
        N 2/  0
        DO
           '!'     I   VC!
           '*'  N  I - VC!
           40 MS
        LOOP
        CLOSE2
     AGAIN
;

: UP/DOWN
     BEGIN


        3000 RND CALM @ + MS
        PIX.COL  9 RND 4 - +  VERT
        ?TERMINAL
     UNTIL ;
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ combine multi-tasking primitives to dynamically create a task
: SPAWN  ( xt -- )  USIZE MALLOC DUP FORK DUP WAKE  ASSIGN ;

HEX 83D6 CONSTANT NO-TIMEOUT

DECIMAL
: GO
      WARM GRAPHICS
      NO-TIMEOUT ON
      1 SCREEN
      DEF.CHARS
      INIT-MULTI
      MULTI
      ['] THING SPAWN
      2000 MS
      CLOSE2
      ['] BLINKING  SPAWN
      ['] LEFT/RIGHT SPAWN
      10 10 OPEN2 .EYES
      UP/DOWN   \ console task
      BYE
;

LOCK
INCLUDE DSK1.SAVESYS
' GO SAVESYS DSK3.EYESII
