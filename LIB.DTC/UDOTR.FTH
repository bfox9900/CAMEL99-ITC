\ udotr.fth   unsigned and signed right aligned print number

\ unsigned double (32bit)  print, right justified
: UD.R  ( ud n --) >R  <# #S #>  R> OVER - SPACES TYPE SPACE ;

\ unsigned single (16bit)  print, right justified
: U.R   ( u n -- )  0 SWAP  UD.R  ;

: .R   ( u n -- )
       >R DUP ABS 0 <# #S ROT SIGN #>  R> OVER - SPACES TYPE SPACE ;

