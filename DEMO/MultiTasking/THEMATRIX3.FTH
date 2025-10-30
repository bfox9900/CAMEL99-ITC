\ THE MATRIX Multi-tasking demonstration                Brian Fox 2021

NEEDS DUMP   FROM DSK1.TOOLS  \ DEBUG
NEEDS MARKER FROM DSK1.MARKER
NEEDS MALLOC FROM DSK1.MALLOC
NEEDS RND    FROM DSK1.RANDOM
NEEDS COLOR  FROM DSK1.GRAFIX
NEEDS SPRITE FROM DSK1.DIRSPRIT
NEEDS MOTION FROM DSK1.AUTOMOTION
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
: RNDCOL   ( -- col)  32 RND ;

DECIMAL
: RNDLEN   21 RND 4 + ; ( max will be 20+4=24 )
: VROW++  ( -- ) VROW DUP @ 1+ 23 MIN SWAP ! ;
: DREAMS  ( n ) 0 ?DO  PAUSE  LOOP PAUSE ;

: FALLING ( length col row  -- )
    AT-XY
    ( len ) 0
    ?DO
      PAUSE
      RNDCHAR VPUT
      VROW++
      RNDCHAR >WHITE VPUT
      12 RND 5 + DREAMS
    LOOP
;


\ \\\\\\\\\\\\\\\\\\\\\ BACKGROUND TASKS ///////////////////
: FALLER
       BEGIN
         RNDLEN  RNDCOL 0 FALLING
       AGAIN ;

: ERASER
    BEGIN
      32 RND 0 AT-XY
      50 RND 6 +  DREAMS
      24 0
      DO
        PAUSE
        BL VPUT
        VROW++
        20 RND DREAMS
      LOOP
    AGAIN ;

CREATE GREENS   13 , 3 , 4 , 13 , 4 , 3 , 13 , 3 ,
: ]GREEN ( n)  7 AND CELLS GREENS + @ ; \ circular access array

: RND-GRN  7 RND ]GREEN  ;

: SHIMMER  \ switches charsets to random greens, random times
      0    \ first []green index
      BEGIN
        PAUSE
        22 16 DO
         PAUSE
          I  OVER ]GREEN 1 COLOR
          1+  \ increment index
          PAUSE
        LOOP
      AGAIN
;

: RNDX ( -- xpixel ) 240 RND 8 + ;
: RNDFALL  8 RND 2 + ;

\ make sprite characters fall from the top
DECIMAL
: WHITE-RAIN
  1000 MS
  BEGIN
    10 0
    DO
      PAUSE
      ( char   colr  x  y sp# )
      RNDCHAR  16  RNDX 0  I SPRITE  0 RNDFALL I MOTION
      100 DREAMS
    LOOP
  AGAIN
;

: GREEN-RAIN
  2000 MS
  BEGIN
    21 11
    DO
      PAUSE
      ( char        colr     X   y sp# )
      RNDCHAR  8 RND ]GREEN RNDX 0  I SPRITE  0 RNDFALL I MOTION
      100 DREAMS
    LOOP
  AGAIN
;

: TWINKLE ( colorset -- )
    PAUSE
    DUP 15 1 COLOR
    5 DREAMS
    16 1 COLOR   \ back to white
    5 DREAMS
;

: TWINKLER
    BEGIN
      26 22 \ white character sets
      DO
        I TWINKLE
      LOOP
    AGAIN
;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ SPAWN allocates USER area in Low RAM, FORKS,
\ sets the awake flag and assigns a Forth word to RUN
: SPAWN  ( xt -- )  USIZE MALLOC DUP FORK DUP WAKE  ASSIGN ;

HEX
: SPAWN-JOBS ( --)
  2000 H !
  ['] FALLER SPAWN
  ['] FALLER SPAWN
  ['] FALLER SPAWN
  ['] FALLER SPAWN
  ['] ERASER SPAWN
  ['] ERASER SPAWN
  ['] ERASER SPAWN
  ['] SHIMMER SPAWN
  ['] TWINKLER SPAWN
  ['] WHITE-RAIN SPAWN
  ['] GREEN-RAIN SPAWN
;

HEX 83D6 CONSTANT ALWAYS  \ screen timeout control
: PATTERNS ( n -- n')  8* ; \ char patterns to write to pattern table

: DO-CHARS
   \ source   dest.    Quantity
    \ ------   ----    ----------
    Japanese  128 ]PDT  31 PATTERNS VWRITE  \ GREEN charset
    Japanese  176 ]PDT  31 PATTERNS VWRITE  \ WHITE charset

    128 SET# 168 SET#  4 1 COLORS   ( green)
    176 SET# 228 SET# 16 1 COLORS   ( white)
;

DECIMAL
: RUN
    WARM
    GRAPHICS
    DO-CHARS
    INIT-MULTI
    ." Spawning tasks..."
    SPAWN-JOBS

    1 SCREEN
    MULTI
    ALWAYS ON  \ prevent screen timeout
    AUTOMOTION
    20 MOVING
    BEGIN      \ the console task loops to test the break key
      PAUSE
      ?TERMINAL
    UNTIL
   \ 8 SCREEN
    SINGLE
    DELALL
    STOPMOTION
    BYE
;

\ Make a binary program
  LOCK
  INCLUDE DSK1.SAVESYS

 ' RUN SAVESYS DSK3.THEMATRIX
