\ udotr.fth   unsigned and signed right aligned print number

NEEDS VTYPE  FROM DSK1.VTYPE

: FSPACES  ( n -- ) VPOS OVER BL VFILL  VCOL +! ;

\ unsigned double (32bit)  print, right justified
: UD.R  ( ud n --) >R  <# #S #>  R> OVER -  FSPACES VTYPE ;

\ unsigned single (16bit)  print, right justified
: U.R   ( u n -- )  0 SWAP  UD.R  ;

: .R   ( u n -- )
       >R DUP ABS 0 <# #S ROT SIGN #>  R> OVER - FSPACES VTYPE ;

