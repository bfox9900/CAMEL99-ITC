\ simplest busy spinner

VARIABLE SPIN#

CREATE SCHARS   CHAR | C, CHAR / C, CHAR - C, CHAR \ C,

\ returns a different character when called 
: SPINCHAR ( -- char) 
  SPIN# @ 1+  3 AND DUP SPIN# ! SCHARS + C@  ;


: TESTSPIN
    VROW 2@ 
     BEGIN  
        2DUP AT-XY  SPINCHAR VPUT 
        100 MS 
        ?TERMINAL
    UNTIL   
;