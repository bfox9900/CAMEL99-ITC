\ file sys test suite

: A$  S" DSK1.CASE.F"  ;
: B$  S" DSK1.DEFER.F" ;

HEX
: DSRNAM  ( -- adr len )  834A 8354 @ ;  \ looks like a stack string to Forth :-)

: .FID   ." FID=" 8356 ? ;

A$ OPN    .S  .FID
B$ OPN    .S  .FID
A$ OPN    .S  .FID
B$ OPN    .S  .FID

CLS .S
CLS .S
CLS .S
CLS .S


