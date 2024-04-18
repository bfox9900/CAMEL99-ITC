\ using Camel99 Forth MUSICWRITER tO try some hard music.  
\ Apr 2024 Brian Fox 

NEW-TUNES 

DECIMAL 
\ Key is Ab 
: MELODY-LINE1  
    105 BPM 
    SOPRANO 
     
  ||: 4/4 NORMAL 
       1/4 F4  1/8. Ab4 1/8 F4 1/16 F4 1/8 Bb4 F4 Eb4          |
    |  1/4 F4  1/8. C5  1/8 F4 1/16 F5 1/8 Db5 C4 Ab4          |
    |  F4  C5  F5  1/16 F4 1/8 Eb4 1/16 Eb4 1/8 C4 G4 LEGATO F4 |
    |  1/2 F4 / / :||   
    
  ||
;

 

TASK1 SLEEP 
' MELODY-LINE1 TASK1 ASSIGN 

: GO    TASK1 RESTART ;






