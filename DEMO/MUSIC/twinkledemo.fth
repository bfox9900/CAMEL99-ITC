\ ======================[ Demonstration ]===================

\ This system makes sense if you understand traditional music notation.

NEW-TUNES 

: TWINKLE  SOPRANO
      120 BPM  
      4/4 NORMAL 
      mf
      | 1/4  A4 A4  E5  E5  | F#5 F#5   1/2 E5 |
      | 1/4  D5 D5  C#5 C#5 | B4  B4    1/2 A4 |
      mp 
      | 1/4  E5 E5  D5  D5  | C#5 C#5   1/2 B4 |
      | 1/4  E5 E5  D5  D5  | C#5 C#5   1/2 B4 | 
      forte
      | 1/4  A4 A4  E5  E5  | F#5 F#5   1/2 E5 |
      | 1/4  D5 D5  C#5 C#5 |  B4  B4 
      NORMAL 80 BPM 1/1 A4 ||
;  

: DESCANT  ALTO
   120 BPM 
   4/4 LEGATO 
   mf
   | 1/8  A3  C#4  B3  A3  E4  A3  C#4 E4 |
   |      F#4 A4   G#4 F#4 E4  A3  C#4 E4 |
   |      D4  F#4  E4  D4  C#4 E4  D4 C#4 |
   |      B3  A4   B4  F#4 E4  F#4 E4 F#4 | 
   piano 
   |      C#4 E4   C#4 E4  D4  E4  D4  E4 |
   |      C#4 E4   C#4 E4  D4  B3  D4  E4 |
   mp
   |      C#4 E4   C#4 E4  D4  E4  D4  E4 |
   |      C#4 E4   C#4 E4  D4  B3  D4  E4 |
   mf
   |      A3  C#4  B3  A3  E4  A3    C#4 E4 |
   |      F#4 A4   G#4 F#4 E4  A3    C#4 E4 |
   |      D4  F#4  E4  D4  C#4 E4    D4 C#4 |
   |  B3  E4   F#4 G#4  A4 G#4  
   NORMAL 80 BPM  1/1 C#4 || ( last note sustain)
 ;

: BASSLINE  BASS
   120 BPM 
   4/4 NORMAL 
   forte
   | 1/2  A1    C#2     | D2      A1     |
   |      E2    A1      | E2      A1     |
   mf STACCATO
   | 1/4  A1 A1 D2 D2   | E2  E2  1/2 E2 |
   | 1/4  A1 A1 D2 D2   | E2  E2  1/2 E1 |
   ff
   | 1/2  A1    C#2     | D2        A1   |
   |      E2    A1      | E1  NORMAL 80 BPM 1/1  A1 ||
;

' TWINKLE   TASK1 ASSIGN 
' DESCANT   TASK2 ASSIGN
' BASSLINE  TASK3 ASSIGN 

MULTI 

: PLAY.TWINKLE  TASK1 RESTART  TASK2 RESTART  TASK3 RESTART  ;

: WITHBASS   TASK1 RESTART  TASK3 RESTART ;

