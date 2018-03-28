\ udotr.fth   unsigned right aligned print number

\ unsigned double (32bit)  print, right justified
: UD.R  ( ud n --) >R  <# #S #> ( adr len -- ) R> OVER - SPACES TYPE ;

\ unsigned single (16bit)  print, right justified
: U.R   ( u n -- )  0 SWAP  UD.R  ;
