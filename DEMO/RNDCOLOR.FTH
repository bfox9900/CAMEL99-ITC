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

\ These lines are interesting because they uses floating point math
\ to compute a valid note on the musical scale. 
\ 160 N=INT(24*RND+1)
\ 170 Y=110*(2^(1/12))^N 

\ Can we do this in Forth with only 16 bit integerS?
\ ( 2^1/12 ≈1.059463 ) 
\ Probably but it would simpler and make faster code to make
\ a table of note frequencies and select them randomly.

CREATE NOTES[]   \ create a name for the data
\ put the number into memory with the comma operator
\ FREQ    MIDI Note 
\ ----    ---- ----
  110 , \  45	A2   
  117 , \  46	A#2/Bb2
  123 , \  47	B2
  131 , \  48	C3
  139 , \  49	C#3/Db3
  147 , \  50	D3
  156 , \  51	D#3/Eb3
  165 , \  52	E3
  175 , \  53	F3
  185 , \  54	F#3/Gb3
  196 , \  55	G3
  208 , \  56	G#3/Ab3
  220 , \  57	A3
  233 , \  58	A#3/Bb3
  247 , \  59	B3
  262 , \  60	C4 (middle C)
  277 , \  61	C#4/Db4
  294 , \  62	D4
  311 , \  63	D#4/Eb4
  330 , \  64	E4
  349 , \  65	F4
  370 , \  66	F#4/Gb4
  392 , \  67	G4
  415 , \  68	G#4/Ab4
  440 , \  69	A4 concert pitch
  466 , \  70	A#4/Bb4
  494 , \  71	B4
  523 , \  72	C5
  554 , \  73	C#5/Db5
  587 , \  74	D5
  622 , \  75	D#5/Eb5
  659 , \  76	E5
  698 , \  77	F5
  740 , \  78	F#5/Gb5
  784 , \  79	G5
  831 , \  80	G#5/Ab5
  880 , \  81	A5
  932 , \  82	A#5/Bb5
  988 , \  83	B5
  1047 , \  84	C6
  1109 , \  85	C#6/Db6
  1175 , \  86	D6
  1245 , \  87	D#6/Eb6
  1319 , \  88	E6
  1397 , \  89	F6
  1480 , \  90	F#6/Gb6
  1568 , \  91	G6
  1661 , \  92	G#6/Ab6
  1760 , \  93	A6
  1865 , \  94	A#6/Bb6
  1976 , \  95	B6
  2093 , \  96	C7
  2217 , \  97	C#7/Db7
  2349 , \  98	D7
  2489 , \  99	D#7/Eb7
  2637 , \ 100	E7
  2794 , \ 101	F7
  2960 , \ 102	F#7/Gb7
  3136 , \ 103	G7
  3322 , \ 104	G#7/Ab7
  3520 , \ 105	A7
  3729 , \ 106	A#7/Bb7
  3951 , \ 107	B7
  4186 , \ 108	C8

\ make word that indexes into the table and fetches the frequency
: ]NOTE ( n -- freq) CELLS NOTES[] +  @ ;

: n   ( -- n )   12 RND 20 + ;  \ random number between 0 and 23 
: CHR ( -- n )   80 RND 40 + ;  \ chars higher than ASCII 40 
: ROW ( -- n )   24 RND  ;      \ random row 0 to 23 
: COL ( -- n )   32 RND  ;      \ random col 0 to 31 

\ We can create a SOUND word from the primitives: HZ DB MS MUTE
\ : SOUND  ( dur freq att --) DB  HZ  MS MUTE ;
\ But there really is no point. The Forth words easy to understand.

: RUN ( -- )
      CLEAR
      16 SCREEN  
      SET-COLORS
      GEN1      \ use sound generator 1 
      BEGIN
	   COL ROW CHR 1 HCHAR

        n ]NOTE HZ     \ set the frequency
        -2 DB          \ set the volume (turns on sound)  
        70 MS MUTE     \ wait and then turn off the sound 
        64 RND MS      \ wait to put a space after the note 
        ?TERMINAL
      UNTIL
      8 SCREEN
      4 19 2 1 COLORS
      CHARSET ;


