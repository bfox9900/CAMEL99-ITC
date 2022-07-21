\ Demo from TI-BASIC USER'S REFERENCE GUIDE

\ 100 REM  Random Color Dots
\ 110 RANDOMIZE
\ 120 CALL CLEAR
\ 130 FOR C=2 TO 16
\ 140 CALL COLOR(C,C,C)
\ 150 NEXT C
\ 160 N=INT(24*RND+1)
\ 170 Y=110*(2^(1/12))^N
\ 180 CHAR=INT(120*RND)*40
\ 190 ROW=INT(23*RND)+1
\ 200 COL=INT(31*RND)+1
\ 210 CALL SOUND(-500,Y,2)
\ 220 CALL HCHAR(ROW,COL,CHAR)
\ 230 GOTO 160

\ Random Color Dots
NEEDS RND      FROM DSK1.RANDOM
NEEDS HZ       FROM DSK1.SOUND
NEEDS COLOR    FROM DSK1.GRAFIX
NEEDS CHARSET  FROM DSK1.CHARSET

DECIMAL
: SET-COLORS ( -- )
     BL SET# 2 2 COLOR
     20 5 DO   I I I COLOR   LOOP ;  \ Forth has different color sets

\ rather than use variables we make words with the same names
\ that calculate the numbers we need and leave them on the stack
: Y   ( -- n ) 1000 RND 110 + ;  \ does not calc. musical notes.
: CHR ( -- n )   80 RND 40 + ;   \ chars higher than space
: ROW ( -- n )   24 RND  ;
: COL ( -- n )   32 RND  ;

\ We create a SOUND word from the primitives: HZ DB MS MUTE
: SOUND  ( dur freq att --) DB  HZ  MS MUTE ;

: RUN ( -- )
      16 SCREEN  CLEAR
      SET-COLORS
      BEGIN
	 COL ROW CHR 1 HCHAR
         GEN1 150 Y -2 SOUND
        ?TERMINAL
      UNTIL
      8 SCREEN
      4 19 2 1 COLORS
      CHARSET ;


