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
INCLUDE DSK1.RANDOM.F
INCLUDE DSK1.SOUND.F
INCLUDE DSK1.CHARSET.F
INCLUDE DSK1.GRAFIX.F

DECIMAL
: SET-COLORS ( -- )
     19 4 DO   I I I COLOR   LOOP ;  \ Forth has different color sets

\ rather than use variables we make words with the same names
\ that calculate the numbers we need and leave them on the stack
: Y   ( -- n ) 1000 RND 110 + ;  \ does not calc. musical notes.
: CHR ( -- n )   80 RND 32 + ;
: ROW ( -- n )   24 RND  ;
: COL ( -- n )   32 RND  ;

\ We create a SOUND word from the primitives: HZ DB MS MUTE
: SOUND  ( dur freq att --) DB  HZ  MS MUTE ;

: RUN ( -- )
      RANDOMIZE
      CLEAR
      SET-COLORS
      BEGIN
 \        CHR COL ROW >VPOS VC!
 	 COL ROW CHR 1 HCHAR
         GEN1 250 Y -2 SOUND \ Select sound Generator #1
	 ?TERMINAL     \ check for the break key
      UNTIL
      8 SCREEN        \ restore things like BASIC
      4 19 2 1 COLORS
      CHARSET ;

