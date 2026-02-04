\ THE MATRIX Multi-tasking demonstration                Brian Fox 2021

\ NEEDS DUMP   FROM DSK1.TOOLS  \ DEBUG
NEEDS MARKER FROM DSK1.MARKER
NEEDS MALLOC FROM DSK1.MALLOC
NEEDS RND    FROM DSK1.RANDOM
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


\ : .JAPAN  CR  159 128 DO I EMIT LOOP ;  .JAPAN
\ : .JAPAN2  CR 207 176 DO I EMIT LOOP ;  .JAPAN2

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
176 128 - CONSTANT WHITECHAR  ( changes green character to white)

: >WHITE ( greenchar -- whitechar) WHITECHAR + ;
: RNDCHAR ( -- c)  32 RND 128 +  ; \ returns green charset only

: FINDEMPTY ( -- -1 | col) \ -1 means all full
    -1
    32 0 DO
        I 0 >VPOS VC@ BL =
        IF DROP I LEAVE
        THEN
    LOOP
;

: RNDCOL   ( -- col)
    FINDEMPTY DUP TRUE =
    IF DROP 32 RND
    THEN
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
       BEGIN
         RNDLEN  RNDCOL 0 FALLING
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

CREATE GREENS   13 , 3 , 4 , 13 , 4 , 3 , 13 , 3 ,
: ]GREEN ( n)  7 AND CELLS GREENS + ; \ circular access array

: SHIMMER  \ switches charsets to random greens, random times
      0    \ first []green index
      BEGIN
        PAUSE
        22 16 DO
         \ 100 TICKS
          I  OVER ]GREEN @ 1 PAUSE COLOR
          1+  \ increment index
        LOOP
      AGAIN
;

: TWINKLE ( colorset -- )
        DUP 15 1 PAUSE COLOR
        300 TICKS
        16 1 PAUSE COLOR   \ back to white
        400 TICKS
;

: TWINKLER
      BEGIN
        26 22 \ white character sets
        DO
          I TWINKLE
        LOOP
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
  ['] SPRITE-FALL SPAWN
;


HEX 83D6 CONSTANT ALWAYS  \ screen timeout control
: PATTERNS ( n -- n')  8* ; \ char patterns to write to pattern table

DECIMAL
: RUN
    WARM
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
    BEGIN      \ the console task loops to test the break key
      PAUSE
      ?TERMINAL
    UNTIL
    SINGLE
 \   BYE
;




  LOCK
  INCLUDE DSK1.SAVESYS
 ' RUN SAVESYS DSK3.THEMATRIX
