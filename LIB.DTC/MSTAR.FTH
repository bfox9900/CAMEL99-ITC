\ MSTAR  ANS Forth CORE word

: ?NEGATE    ( n1 n2 -- n3) 0< IF NEGATE THEN ;
: DNEGATE    ( d1 -- d2 )   SWAP INVERT SWAP INVERT 1 M+ ;
: ?DNEGATE   ( d1 n -- d2)  0< IF DNEGATE THEN ;

: M*  ( n1 n2 -- d) \  signed 16*16->32 multiply
      2DUP XOR >R      \  carries sign of the result
      SWAP ABS SWAP ABS UM*
      R> ?DNEGATE ;