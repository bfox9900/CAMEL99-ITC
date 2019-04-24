\ Fixed point printing examples

\ CAMEL Forth source code, Brad Rodriguez
: DNEGATE  ( d -- d)  SWAP INVERT SWAP INVERT 1 M+ ;
: ?DNEGATE ( d1 n -- d2) 0< IF DNEGATE THEN ; \  negate d1 if n negative
: DABS     ( d1 -- +d2 )  DUP ?DNEGATE ; \ absolute value dbl.prec.

: >.<   [CHAR] . HOLD ;
: >$<   [CHAR] $ HOLD ;

: U.##  ( u -- ) S>D TUCK DABS   <#  # # >.< #S #>  TYPE SPACE  ;

: .$    ( n -- ) S>D  TUCK DABS  <#  # # >.< #S ROT SIGN >$<   #>  TYPE SPACE ;