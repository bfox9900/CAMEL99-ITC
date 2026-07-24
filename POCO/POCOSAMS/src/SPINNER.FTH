\ simple waiting spinner

VARIABLE SPIN#
CREATE SCHARS  S" |/-\"  S,

: SPINCHAR ( -- char) SPIN# @ 3 AND  SCHARS 1+ + C@   SPIN# 1+! ;

\ VPUT writes to screen at cursor position but does not change cursor
: SPINNER    SPINCHAR VPUT ;
