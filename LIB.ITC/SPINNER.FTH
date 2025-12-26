\ busy spinner updates Dec 26 2025

VARIABLE SPIN#
: SCHARS   S" |/-\" ;
: SPINCHAR ( -- char ) SPIN# @ 3 AND  SCHARS DROP + C@   SPIN# 1+! ;

\ VPUT writes to screen but does not change cursor
: SPINNER    SPINCHAR VPUT ;

\ : TEST  0 0 AT-XY BEGIN  SPINNER  75 MS  ?TERMINAL UNTIL ;