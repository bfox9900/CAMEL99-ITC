\ Demo from TI-BASIC USER'S REFERENCE GUIDE translated to FbForth 

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


DECIMAL
: SET-COLORS ( -- )
    4  1 1 COLOR      \ set space character to transparent
    20 5 DO   
        I I I COLOR   \ **Forth has different color set numbers
    LOOP ;  

\ These lines are interesting because they use floating point math
\ to compute a valid note on the musical scale. 
\ 160 N=INT(24*RND+1)
\ 170 note=110*(2^(1/12))^N 

\ Can we do this in Forth with only 16 bit integerS?
\ ( 2^1/12 ≈1.059463 ) 

\ we can multiply by 1.0594 and scale it with */ 
\ I found the value 10570 gave me more accurate pitches than 10594
: NOTE+ ( freq -- ) 10570 10000 */ 1+ ; \ compute next semitone 

\ step n semitones up from 110Hz 
: NOTE ( n -- freq) 110  SWAP 0 DO  NOTE+ LOOP  ;   

\ rather than use variables we make words with the same names
\ that calculate the numbers we need and leave them on the stack

: N  ( -- n )    24 RND  ;  \ random number between 0 and 23 
: CHR ( -- n )   80 RND 40 + ;  \ chars higher than ASCII 40 
: ROW ( -- n )   24 RND  ;      \ random row 0 to 23 
: COL ( -- n )   32 RND  ;      \ random col 0 to 31 

: MS   0 DO  9 0 DO LOOP LOOP ;

: MUTE  0 15 1 SOUND ;

HEX 11 CONSTANT BLK/BLK 

DECIMAL 
: RUN ( -- )
      GRAPHICS 
      BLK/BLK SCREEN  
      SET-COLORS
      BEGIN
	    COL ROW 1 CHR HCHAR
        N NOTE 2 1 SOUND 
        100 RND 50 + MS  \ hold note 
        MUTE             \ turn off the note  
        40 MS            \ put a space after each note 
        ?TERMINAL
      UNTIL
      COLD ;


