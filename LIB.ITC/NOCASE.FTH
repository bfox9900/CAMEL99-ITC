\ NOCASE.FTH   allows case insensitive code for Camel99   Fox  June 2021
: LOWER? ( c -- c')  [CHAR] a [ CHAR z 1+ ] LITERAL WITHIN ;
HEX
: TOUPPER ( addr len -- addr len) \ change string  in place
  2DUP BOUNDS ?DO  I C@ DUP LOWER? IF 05F AND THEN I C!  LOOP ;

: <LOINTERP>  ( addr len -- ) TOUPPER  <INTERP> ; \ New interpreter word

: UCASE     ['] <INTERP>    'IV ! ;
: NOCASE    ['] <LOINTERP>  'IV ! ;
