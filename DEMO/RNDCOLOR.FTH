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

\ These lines are interesting because they uses floating point math
\ to compute a valid note on the musical scale. 
\ 160 N=INT(24*RND+1)
\ 170 note=110*(2^(1/12))^N 

\ Can we do this in Forth with only 16 bit integerS?
\ ( 2^1/12 ≈1.059463 ) 

\ we can multiply by 1.0594 and scale it with */ 
\ I found the value 10570 gave me more accurate pitches than 10594
: NOTE+ ( freq -- ) 10570 10000 */ 1+ ; \ compute next semitone 

\ step n semitones up from 110Hz 
: NOTE ( n -- freq) 110  SWAP 0 ?DO  NOTE+ LOOP  ;   

\ rather than use variables we make words with the same names
\ that calculate the numbers we need and leave them on the stack

: N  ( -- n )    24 RND  ;  \ random number between 0 and 23 
: CHR ( -- n )   80 RND 40 + ;  \ chars higher than ASCII 40 
: ROW ( -- n )   24 RND  ;      \ random row 0 to 23 
: COL ( -- n )   32 RND  ;      \ random col 0 to 31 

\ We can create a SOUND word from the primitives: HZ DB MS MUTE
\ : SOUND  ( dur freq att --) DB  HZ  MS MUTE ;
\ But there really is no point. The Forth words are easy to understand.

: RUN ( -- )
      CLEAR
      16 SCREEN  
      SET-COLORS
      GEN1      \ use sound generator 1 
      BEGIN
	     COL ROW CHR 1 HCHAR
          N NOTE HZ        \ set the frequency
          -2 DB            \ set the volume (turns on sound)  
          100 RND 50 + MS  \ hold note 
          MUTE             \ turn off the sound  
          40 MS            \ put a space after each note 
          ?TERMINAL
      UNTIL
      8 SCREEN
      4 19 2 1 COLORS
      CHARSET ;


