\ THE MATRIX Multi-tasking demonstration                Brian Fox 2021

\ NEEDS DUMP   FROM DSK1.TOOLS  \ DEBUG
NEEDS MARKER FROM DSK1.MARKER
NEEDS MALLOC FROM DSK1.MALLOC
NEEDS RND    FROM DSK1.RANDOM
NEEDS QUIT-ON FROM DSK1.QUITKEY
NEEDS COLOR  FROM DSK1.GRAFIX
NEEDS SPRITE FROM DSK1.AUTOMOTION
NEEDS FORK   FROM DSK1.MTASK99

: HEX#, ( addr len  --) \ can be used for longstrings (128 bytes)
        BASE @ >R  \ save radix
        HEX               \ we are converting hex numbers in the string
        BEGIN
        DUP WHILE        \ while len<>0
            2DUP DROP 4  \ get 4 digits from left end of string
            NUMBER? ABORT" Bad number"  \ convert string to number
             ,           \ compile the integer into memory
            4 /STRING    \ cut 4 digits off left side of string
        REPEAT
        2DROP
        R> BASE !  \ restore radix
;

DECIMAL
CREATE Japanese
  S" 007E087E08300000"  HEX#,
  S" 007E020202027E00"  HEX#,
  S" 0044442404043800"  HEX#,
  S" 0000600464087000"  HEX#,
  S" 0004081030501000"  HEX#,
  S" 0028282828284400"  HEX#,
  S" 0000107C107C1000"  HEX#,
  S" 003C448404041800"  HEX#,
  S" 003C000000007E00"  HEX#,
  S" 003E020214080400"  HEX#,
  S" 0004040404043800"  HEX#,
  S" 0042424242023C00"  HEX#,
  S" 007C107C100C0000"  HEX#,
  S" 007C007C007C0000"  HEX#,
  S" 007C007C04380000"  HEX#,
  S" 007C44A404380800"  HEX#,
  S" 007E020438448000"  HEX#,
  S" 0020203824202000"  HEX#,
  S" 00107C1424480000"  HEX#,
  S" 00087C0808300000"  HEX#,
  S" 00407C4040403C00"  HEX#,
  S" 00007C007C106000"  HEX#,
  S" 00287C2808301400"  HEX#,
  S" 0060600404047800"  HEX#,
  S" 0054540404381400"  HEX#,
  S" 007C04281028C400"  HEX#,
  S" 007C040404043800"  HEX#,
  S" 0000107C04043800"  HEX#,
  S" 007C101010107C00"  HEX#,
  S" 00207C2420202000"  HEX#,
  S" 00107C0438540000"  HEX#,

\ for debugging
\ : .JAPAN  CR  159 128 DO I EMIT LOOP ;  .JAPAN
\ : .JAPAN2  CR 207 176 DO I EMIT LOOP ;  .JAPAN2

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
176 128 - CONSTANT WHITECHAR  ( changes green character to white)

: >WHITE ( greenchar -- whitechar) WHITECHAR + ;
: RNDCHAR ( -- c)  32 RND 128 +  ; \ returns green charset only

\ find space char along row '0'
: FINDEMPTY ( -- -1 | col) \ -1 means all full
    -1
    32 0 DO
        I 0 >VPOS VC@ BL =
        IF DROP I LEAVE
        THEN
    LOOP
;

: EMPTY-COL   ( -- -1 | col)
    FINDEMPTY DUP TRUE =
    IF DROP 32 RND THEN
;

 DECIMAL
: RNDLEN   21 RND 4 + ; ( max will be 20+4=24 )

: VROW++  ( -- ) VROW DUP @ 1+ 23 MIN SWAP ! ;

: FALLING ( length col row  -- )
          AT-XY
          ( len ) 0
          ?DO
             PAUSE
             RNDCHAR VPUT
             VROW++
             RNDCHAR >WHITE  VPUT
             10 RND 4 + TICKS
          LOOP
;

\ \\\\\\\\\\\\\\\\\\\\\ BACKGROUND TASKS ///////////////////
: FALLER
    32 0
    DO  \ initial fallers are in random columns
      RNDLEN  32 RND 0 FALLING
    LOOP
    BEGIN \ these ones find and empty column or use random
      RNDLEN  EMPTY-COL 0 FALLING
    AGAIN ;

: ERASER
    5000 MS
    BEGIN
        32 RND 0 AT-XY
        50 RND 6 +  \ loop speed on stack
        24 0
         DO
            PAUSE BL VPUT
            VROW++
            DUP MS    \ delay to loop speed
        LOOP
        DROP         \ DROP loop speed
        2000 RND 400 + MS
    AGAIN ;

\ fg/bg color values of different greens for 6 character sets
\ BLIT these directly into the color table with VWRITE
HEX
CREATE GREENS   C0 C,  20 C,  30 C, C0 C, 20 C,
CREATE GREENS2  30 C,  C0 C,  20 C, 30 C, C0 C,
CREATE GREENS3  20 C,  30 C,  C0 C, 20 C, 30 C,

DECIMAL
: SHIMMER  \ switches charsets to random greens, random times
    BEGIN
      PAUSE
      GREENS  [ 16 ]CTAB ] LITERAL  5 VWRITE
      50 MS
      GREENS2 [ 16 ]CTAB ] LITERAL  5 VWRITE
      50 MS
      GREENS3 [ 16 ]CTAB ] LITERAL  5 VWRITE
      50 MS
    AGAIN
;

HEX
CREATE WHITE1 E0 C, F0 C, E0 C, F0 C, E0 C,
CREATE WHITE2 F0 C, E0 C, F0 C, E0 C, F0 C,

DECIMAL
: TWINKLER
    BEGIN
      PAUSE
      WHITE1  [ 22 ]CTAB ] LITERAL  5 VWRITE
      50 RND 100 + MS
      WHITE2  [ 22 ]CTAB ] LITERAL  5 VWRITE
      50 RND 50 +  MS
    AGAIN
;

: SPRITE-FALL
    8000 MS     \ wait until the screen gets full
    12 MOVING   \ set number of sprites that auto move
    BEGIN
        6 RND 6 +  0
        DO
           \ char   colr   x       y   spr#
            PAUSE
            RNDCHAR  16  210 RND 18 +  0    I SPRITE
            PAUSE
            0  2 RND 5 +  I MOTION
            300 RND 700 + MS
        LOOP
    AGAIN
;

\ : TEST   BEGIN   22 16 DO  I ]GREEN @ . LOOP  ?TERMINAL UNTIL ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ SPAWN allocates USER area in Low RAM, FORKS,
\ sets the awake flag and assigns a Forth word to RUN
: SPAWN  ( xt -- )  USIZE MALLOC DUP FORK DUP WAKE  ASSIGN  ;

: SPAWN-JOBS ( --)
  ['] FALLER SPAWN
  ['] FALLER SPAWN
  ['] FALLER SPAWN
  ['] FALLER SPAWN
  ['] ERASER SPAWN
  ['] ERASER SPAWN
  ['] ERASER SPAWN
  ['] SHIMMER SPAWN
  ['] TWINKLER SPAWN
;


HEX 83D6 CONSTANT ALWAYS  \ screen timeout control

\ no, of char patterns to write to pattern table (8 bytes/pattern)
: PATTERNS ( n -- n')  8* ;

DECIMAL
: RUN
    WARM
    QUIT-ON      \ Enable quit key interrupt
    GRAPHICS
    \ source   dest.    Quantity
    \ ------   ----    ----------
    Japanese  128 ]PDT  31 PATTERNS VWRITE \ GREEN charset
    Japanese  176 ]PDT  31 PATTERNS VWRITE  \ WHITE charset

    128 SET# 168 SET#  4 1 COLORS   ( green)
    176 SET# 228 SET# 16 1 COLORS   ( white)

    INIT-MULTI
    ." Spawning tasks..."
    SPAWN-JOBS
    1 SCREEN
    MULTI
    ALWAYS ON  \ prevent screen timeout
    AUTOMOTION
    SPRITE-FALL  \ Console runs the sprite-fall task forever
;


  LOCK \ Lock the dictionary to this point.

\ this code will load into unallocated space so not part of the final image
  INCLUDE DSK1.SAVESYS
 ' RUN SAVESYS DSK3.THEMATRIX
