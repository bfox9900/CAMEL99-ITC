\ udotr.fth   unsigned and signed right aligned print number
: UD.R  ( ud n --) >R  <# #S #>  R> OVER -  SPACES TYPE ;
: U.R   ( u n -- )  0 SWAP  UD.R  ;
: .R    ( n n -- ) >R DUP ABS 0 <# #S ROT SIGN #>  R> OVER - SPACES TYPE ;

