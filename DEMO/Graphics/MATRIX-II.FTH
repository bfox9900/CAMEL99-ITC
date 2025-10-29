\ THE MATRIX Multi-tasking demonstration                Brian Fox 2021

\ NEEDS DUMP   FROM DSK1.TOOLS  \ DEBUG
NEEDS MARKER FROM DSK1.MARKER
NEEDS MALLOC FROM DSK1.MALLOC
NEEDS RND    FROM  DSK1.RANDOM
NEEDS COLOR  FROM DSK1.GRAFIX
NEEDS SPRITE FROM DSK1.DIRSPRIT
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

CREATE Japanese
DECIMAL
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

176 128 - CONSTANT WHITECHAR  ( changes green character to white)
: >WHITE ( greenchar -- whitechar) WHITECHAR + ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ : CLIP     ROT MIN MAX ;
: RNDCHAR ( -- c)  30 RND 128 +  ; \ returns green charset only
: RNDX    32 RND ;  \ 31 CLIP ;
: RNDLEN    19 RND 4 + ;

: VROW++  ( -- ) VROW DUP @ 1+ 23 MIN SWAP ! ;

: FALLING ( length col row  -- )
          AT-XY
          ( len ) 0
          ?DO
             RNDCHAR PAUSE VPUT
             VROW++
             RNDCHAR >WHITE PAUSE VPUT
             150 RND 10 + MS
          LOOP
;

\ \\\\\\\\\\\\\\\\\\\\\ BACKGROUND TASKS ///////////////////
: FALLER
       BEGIN
         PAUSE
         RNDLEN  RNDX  0 FALLING
       AGAIN ;

: ERASER
       BEGIN
          RNDX 0 AT-XY
          24 0
          DO
             PAUSE
             BL VPUT
             VROW++
             4000 RND 300 + MS
          LOOP
       AGAIN ;

CREATE GREENS   13 , 3 , 4 ,
: RND-GREEN  ( -- n) 3 RND CELLS  GREENS + @ ;

: SPARKLER \ switches charsets to random greens, random times
      BEGIN
          PAUSE
          16 RND-GREEN 1 COLOR
          17 RND-GREEN 1 COLOR
          PAUSE
          18 RND-GREEN 1 COLOR
          19 RND-GREEN 1 COLOR
          PAUSE
          20 RND-GREEN 1 COLOR
          21 RND-GREEN 1 COLOR
      AGAIN
;
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ SPAWN allocates USER area in Low RAM, FORKS,
\ sets the awake flag and assigns a Forth word to RUN
: SPAWN  ( xt -- )  USIZE MALLOC DUP FORK DUP WAKE  ASSIGN  ;

: SPAWN-JOBS ( --) \ stagger the start times for the opening
  ['] FALLER SPAWN 1000 RND MS
  ['] FALLER SPAWN 1000 RND MS
  ['] ERASER SPAWN

  ['] FALLER SPAWN 1000 RND MS
  ['] FALLER SPAWN 1000 RND MS
  ['] ERASER SPAWN

  ['] FALLER SPAWN 1000 RND MS
  ['] FALLER SPAWN 1000 RND MS
  ['] ERASER SPAWN

  ['] SPARKLER SPAWN
;


HEX 83D6 CONSTANT ALWAYS  \ screen timeout control

DECIMAL
: RUN
    GRAPHICS
    CLEAR
    Japanese 128 ]PDT  30 8* VWRITE  \ GREEN charset
    Japanese 176 ]PDT  30 8* VWRITE  \ WHITE charset

    INIT-MULTI
    CR ." Spawning tasks... "
    SPAWN-JOBS

    1 SCREEN
    128 SET# 168 SET#  4 1 COLORS   ( green)
    176 SET# 228 SET# 16 1 COLORS   ( white)
    MULTI
    ALWAYS ON  \ prevent screen timeout
    BEGIN      \ the console task loops to test the break key
      PAUSE
      ?TERMINAL
    UNTIL
    SINGLE
    8 SCREEN
    BL SET#  [CHAR] Z SET#  2 1 COLORS
    BYE
;
