\ ASCII character busy spinner

CREATE SCHARS   CHAR | C, CHAR / C, CHAR - C, CHAR \ C,

VARIABLE SPIN#

: SPINCHAR ( -- char ) SPIN# @ 1+ 3 AND DUP SPIN# ! SCHARS + C@  ;
: SPINNER    SPINCHAR VPUT ;
