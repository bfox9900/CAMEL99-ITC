\  multicolor mode  tests  2024 Brian Fox 

NEEDS HLINE  FROM DSK1.GRAPHIC2
NEEDS RDN    FROM DSK1.RANDOM 

: ?BREAK  ?TERMINAL IF  TEXT  ABORT  THEN ;

DECIMAL 
: RNDCOLOR ( -- )  16 RND 0 COLOR ;
: RNDX     ( -- n) 200 RND ;
: RNDY     ( -- n) 180 RND ;
: RNDLEN   ( -- n) 75 RND 2+ ;

: ANGLES  
   GRAPHICS2 
   CLEAR 
   PENCIL IS STYLUS 
   25 0 
   DO 
 \  X Y LEN        X Y LEN
    I I 200 HLINE  I I 160 VLINE 
   3 +LOOP  
   24 184 200 HLINE  224 24 160 VLINE 
;

: DIAGONALS
    120 60
    DO 
       50  20
       DO  I  I J +  PLOT  LOOP 
       ?BREAK  
    2 +LOOP    
; 

: RNDLINES 
    GRAPHICS2 
    CLEAR 
    40 0 
    DO 
      RNDLEN RNDX RNDY HLINE 
      RNDLEN RNDX RNDY VLINE 
      ?BREAK
    LOOP 
;

: TEST 
   GRAPHICS2 
   CLEAR 
   PENCIL IS STYLUS 
   RNDCOLOR 
   BEGIN
        ANGLES BEEP 
        DIAGONALS BEEP 
        RNDLINES BEEP 
        ?TERMINAL 
   UNTIL  
   TEXT ;
