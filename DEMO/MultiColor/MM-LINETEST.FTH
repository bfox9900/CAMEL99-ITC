\  multicolor mode  tests  2024 Brian Fox 

NEEDS HLINE  FROM DSK1.MULTIMODE 
NEEDS RDN    FROM DSK1.RANDOM 

DECIMAL 
: RNDCOLOR ( -- )  16 RND  MCOLOR ! ;
: RNDX     ( -- n) 64 RND ;
: RNDY     ( -- n) 48 RND ;
: RNDLEN   ( -- n) 10 RND 2+ ;

: ANGLES  
   RNDCOLOR  40 0 0 HLINE   16 0 0 VLINE 
   RNDCOLOR  48 2 2 HLINE   24 2 2 VLINE 
   RNDCOLOR  56 4 4 HLINE   32 4 4 VLINE 
   RNDCOLOR  58 6 6 HLINE   40 6 6 VLINE 
;

: RNDLINES 
    CLEAR 
    100 0 
    DO 
      RNDCOLOR  RNDLEN RNDX RNDY HLINE 
      RNDCOLOR  RNDLEN RNDX RNDY VLINE 
    LOOP 
;

: DIAGONALS
    16 1
    DO 
       I MCOLOR !   
       32 12 
       DO  I  I J +  MM.PLOT  LOOP 
       100 MS  
    LOOP    
; 

: TEST 
   MULTICOLOR  
   BEGIN
        CLEAR
        ANGLES 
        DIAGONALS
        RNDLINES 
        500 MS 
        ?TERMINAL 
   UNTIL  
   TEXT ;

: TESTLINE 
   MULTICOLOR 
   CLEAR 
   500 0 DO 
     RNDCOLOR RNDX RNDY RNDX RNDY LINE 
   LOOP 
   TEXT
; 

: TESTLINE2 
   MULTICOLOR 
   BEGIN 
      CLEAR 
      RNDX RNDY MOVETO 
      20 0 
      DO  
         RNDCOLOR RNDX RNDY LINETO 
         ?TERMINAL 
         IF 
           UNLOOP TEXT ABORT 
         THEN 
      LOOP 
   AGAIN 
; 

: RNDSHAPE
   RNDCOLOR RNDX RNDY MOVETO 
   8 RND 3 +  0 
   DO  
      RNDX RNDY LINETO 
      ?TERMINAL 
      IF 
         UNLOOP TEXT ABORT 
      THEN 
   LOOP 
;   

: TESTLINE3
   MULTICOLOR 
   BEGIN 
      CLEAR 
      3 RND 1+  0 DO RNDSHAPE  LOOP 
      1000 MS 
   AGAIN 
;

