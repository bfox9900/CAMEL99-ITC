\ ROLL.FTH from MPE posted on comp.lang.forth
\ modified for Camel99 Forth DUP>R
: ROLL \ nn..n0 n -- nn-1..n0 nn ; 6.2.2150
  DUP>R PICK
  SP@ DUP CELL+ R> 1+ CELLS CMOVE> DROP
;
