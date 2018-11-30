\ SFP16.SCR                                  hhh 17:05 20.07.98
\  written using LMI PC/FORTH 3.2
\  Heinrich Hohl, Lucent Technologies

\ Modified for use with CAMEL99 Forth BJF Dec 29 2017

\ The floating point numbers used in this package are composed of
\ two signed single length numbers: a mantissa m (2OS) and an
\ exponent x (TOS).

\ The mantissa spans a range from -9999 through -1000 for
\ negative numbers and from 1000 through 9999 for positive
\ numbers. It contains an implied decimal point three digits from
\ the right. The numbers 1234 5 e.g. represent 1.234E5.

\ Floating point numbers are handled like double length numbers
\ with respect to stack operations, storage etc.

\ constants                                  hhh 17:05 20.07.98
4 CONSTANT FPSIZE

\ variables                                  hhh 17:05 20.07.98
VARIABLE exp       \ exponent of floating point numbers
VARIABLE sign      \ sign of mantissa or exponent
VARIABLE places    \ number of digits behind decimal point

\ basic operators                            hhh 17:05 20.07.98
CREATE F@    ( addr -- f )         ' 2@    @  ' F@    !
CREATE F!    ( f addr -- )         ' 2!    @  ' F!    !
\ CREATE F@L   ( ptr -- f )          ' 2@L   @  ' F@L   !
\ CREATE F!L   ( f ptr -- )          ' 2!L   @  ' F!L   !

CREATE FDROP ( f1 f2 -- f1)        ' 2DROP @  ' FDROP !
CREATE FDUP  ( f -- f f)           ' 2DUP  @  ' FDUP  !
CREATE FOVER ( f1 f2 -- f1 f2 f1)  ' 2OVER @  ' FOVER !
CREATE FSWAP ( f1 f2 -- f2 f1)     ' 2SWAP @  ' FSWAP !

: FROT ( f1 f2 f3 -- f2 f3 f1)  5 ROLL  5 ROLL ;

: FLITERAL  ( f -- )  ?COMP  COMPILE dlit  SWAP , , ; IMMEDIATE
: FCONSTANT ( f -- )  CREATE  , ,  ( -- f) DOES> 2@ ;
: FVARIABLE ( -- )    CREATE  0 , 0 , ;
\ normalize and shift /1/                    hhh 17:05 20.07.98
: INFLATE ( ud -- ud')
  BEGIN  2DUP 1.000 D<  WHILE  10 D* -1 exp +!  REPEAT ;
\ inflate mantissae smaller than 1.000 and adjust exponent


: DEFLATE ( ud -- ud')
  BEGIN  2DUP 9.999 D>  WHILE  10 D/  1 exp +!  REPEAT ;
\ deflate mantissae larger than 9.999 and adjust exponent

\ normalize and shift /2/                    hhh 17:05 20.07.98
: TRIM ( d n -- d' n')
  exp !                       \ store exponent
  2DUP D0=                    \ adjust only if d<>0
  IF    0                     \ d=0 needs a zero exponent
  ELSE  DUP 0<  >R            \ save sign on return stack
        DABS INFLATE DEFLATE  \ adjust mantissa and exponent
        R> ?DNEGATE           \ restore sign of mantissa
        exp @                 \ put exponent on top of mantissa
  THEN ;

\ Trim a double length number (d) with exponent (n) so that
\ afterwards the absolute value of the mantissa spans a range
\ from from 1000 through 9999. A zero mantissa is always
\ returned with a zero exponent.

\ normalize and shift /3/                    hhh 17:05 20.07.98
: DSHIFT ( d x -- d')
  DUP 0<
  IF    NEGATE
        0  DO 10 D/  LOOP
  ELSE  0 ?DO 10 D*  LOOP  THEN ; \ decimal left shift (x<0 shifts |x| digits to the right)

\ conversion                                 hhh 17:05 20.07.98
: FLOAT ( d -- f)  3  DPL @ 0 MAX -  TRIM NIP ;  \ convert double length number to float considering DPL
: D>F ( d -- f)  3 TRIM NIP ;  \ convert double length number to float (ignoring DPL)
: S>F ( n -- f)  S>D D>F ; \ convert single length number to float
: F>D ( f -- d)  >R S>D R>  3 - DSHIFT ; \ convert floating point number to double length number
: F>S ( f -- n)  F>D DROP ; \ convert floating point number to single length number

\ arithmetics /1/                            hhh 17:05 20.07.98
: FABS    ( f -- f')  SWAP ABS SWAP ;
: FNEGATE ( f -- f')  SWAP NEGATE SWAP ;

\ arithmetics /2/                            hhh 17:05 20.07.98
: F+ ( f1 f2 -- f3)
  OVER 0= IF 2DROP EXIT THEN
  2SWAP
  OVER 0= IF 2DROP EXIT THEN
  ROT                          \ ds: m2 m1 x1 x2
  2DUP MAX exp !               \ keep larger exponent
  -                            \ ds: m2 m1 (x1-x2)
  DUP 0>                       \ is x1 the larger exponent?
  IF  >R SWAP R>  THEN         \ yes: use m2 for right shifts
  ABS DUP 3 >                  \ number of shifts too large?
  IF    2DROP exp @            \ yes: return f with larger exp.
  ELSE  0 ?DO 10 / LOOP        \  no: perform right shifts
        + S>D                  \      calculate new mantissa
        exp @ TRIM NIP         \      get exponent and trim
  THEN ;

\ arithmetics /3/                            hhh 17:05 20.07.98
: F- ( f1 f2 -- f3)  FNEGATE F+ ;

\ arithmetics /4/                            hhh 17:05 20.07.98
: F* ( f1 f2 -- f3)
  >R  SWAP                  \ save exponents
  >R                        \
  M*                        \ multiply mantissae
  1000 D/                   \ scale result
  R> R> +                   \ calculate exponent
  TRIM NIP ;

: F10* ( f -- f')  OVER  IF 1+ THEN ;
\ multiply by ten by increasing exponent by one (unless f=0)

\ arithmetics /5/                            hhh 17:05 20.07.98
: F/ ( f1 f2 -- f3)
  >R  SWAP                  \ save exponents
  >R                        \
  DUP 0< >R  ABS  SWAP      \ save signs and form absolutes
  DUP 0< >R  ABS            \
                            \ ds: |m2||m1|  rs: s1 s2 x1 x2
  10000 UM*                 \ inflate numerator
  ROT  D/                   \ divide mantissae
  R> R> XOR  ?DNEGATE       \ calculate and apply sign
  R> R> - 1-                \ calculate exponent
  TRIM NIP ;

: F10/ ( f -- f')  OVER  IF 1- THEN ;  \ divide by ten by decreasing exponent by one (unless f=0)

\ comparison                                 hhh 17:05 20.07.98
: F0=  ( f -- ?)  DROP 0= ;
: F0<> ( f -- ?)  DROP 0<> ;
: F0<  ( f -- ?)  DROP 0< ;
: F0>  ( f -- ?)  DROP 0> ;

: F=  ( f1 f2 -- ?)  D= ;
: F<> ( f1 f2 -- ?)  D<> ;
: F<  ( f1 f2 -- ?)  F- F0< ;
: F>  ( f1 f2 -- ?)  F- F0> ;

: FMAX ( f1 f2 -- f3)
  2OVER 2OVER F<  IF 2SWAP THEN  2DROP ;

: FMIN ( f1 f2 -- f3)
  2OVER 2OVER F>  IF 2SWAP THEN  2DROP ;
\ number input /1/                           hhh 17:05 20.07.98
: CONVERT-MANTISSA ( addr -- d addr')
  0. ROT  DUP 1+ C@  ASCII - =  DUP sign !  -  CONVERT
  DUP C@  ASCII . =
  IF    DUP >R  CONVERT  DUP R> - 1- DPL !
  ELSE  -1 DPL !  THEN
  >R  sign @ ?DNEGATE  R> ;  \ convert mantissa and return address of terminating character

: CONVERT-EXPONENT ( addr -- n addr')
  0. ROT  DUP 1+ C@  ASCII - =  DUP sign !  -  CONVERT
  >R  DROP sign @ ?NEGATE  R> ;  \ convert exponent and return address of terminating character

\ number input /2/                           hhh 17:05 20.07.98
: NUMBER? ( ^str -- d ?)
  CONVERT-MANTISSA
  DUP C@  ASCII E =
  IF  CONVERT-EXPONENT >R
      3 +  DPL @ 0 MAX -  TRIM NIP
     -2 DPL !  R>
  THEN
  C@  DUP BL =  SWAP 0=  OR ;   \ DPL=-2 if float; -1 if single; 0, 1, 2,... if double

: FNUMBER? ( ^str -- f ?)
  NUMBER? DUP >R
  IF  DPL @ 2+ IF FLOAT THEN  THEN R> ;


\ number input /3/                           hhh 17:05 20.07.98
: NUMBER, ( d ? -- )
  0= ?UNDEFINED
  DPL @  -1 =
  IF    DROP [COMPILE] LITERAL
  ELSE  [COMPILE] DLITERAL  THEN ; \ executed by compiler after NUMBER? (compiles n|d|f)

: /NUMBER ( d ? -- n|d|f)
  0= ?UNDEFINED  DPL @  -1 =  IF DROP THEN ; \ executed by interpreter after NUMBER? (puts n|d|f on stack)

: INSTALL-SFP ( -- )
  ['] NUMBER?     [ 73 ORIGIN+ ] LITERAL !
  ['] NUMBER,     [ 74 ORIGIN+ ] LITERAL !
  ['] /NUMBER DUP [ 75 ORIGIN+ ] LITERAL !  FENCE ! ;
\ formatted output /1/                       hhh 17:05 20.07.98
: PLACES ( n -- )  0 MAX  places ! ; \ specify number of places behind the decimal point

: (FD.) ( fd -- addr len)
  TUCK DABS
  <#  places @ 0 ?DO # LOOP  ASCII . HOLD  #S  ROT SIGN  #> ;
\ convert fixed point double length number to formatted string

\ formatted output /2/                       hhh 17:05 20.07.98
: (E.) ( f -- addr len)
  ?DECIMAL
  exp !
  S>D  places @ 3 -  DSHIFT  (FD.)
  " E" COUNT STRCAT  exp @ (.) STRCAT ; \ convert f to a formatted string in exponential format

: E. ( f -- )  (E.) TYPE SPACE ;   \ display f in exponential format

: E.R ( f width -- )
      >R (E.) R> OVER - SPACES TYPE ;  \ display f right justified in a field of specified width


\ formatted output /3/                       hhh 17:05 20.07.98
: (F.) ( f -- addr len)
  ?DECIMAL
  exp !
  S>D  places @ 3 - exp @ +  DSHIFT  (FD.) ; \ convert f to a formatted string in fixed format

: F. ( f -- )  (F.) TYPE SPACE ; \ display f in fixed format

: F.R ( f width -- )
      >R (F.) R> OVER - SPACES TYPE ; \ display f right justified in a field of specified width


\ functions /1/                              hhh 17:05 20.07.98
2VARIABLE arg

: SQRT ( d -- u)
  arg 2!
  9999                          \ ds: u
  BEGIN  DUP >R
         arg 2@ R>              \ ds: u ud u
         UM/MOD NIP             \ ds: u (ud/u)
         2DUP U>
  WHILE  + 2/  REPEAT           \ ds: u'
  DROP ;   \ Newton iteration x' = ?(x+a/x) for a ? 9999?



\ functions /2/                              hhh 17:05 20.07.98
: FSQRT ( f -- f')
  2DUP D0= IF EXIT THEN
  2 /MOD  >R                    \ calc and save new exponent
  IF  10000                     \ for odd exponents
  ELSE 1000 THEN                \ for even exponents
  UM*                           \ inflate mantissa
  SQRT                          \ calculate new mantissa
  R> ;                          \ get new exponent


\ functions /3/                              hhh 13:50 03.08.98
CREATE logtable
(  1.0) 00000 , 00413 , 00791 , 01139 , 01461 ,
        01760 , 02041 , 02304 , 02552 , 02787 ,
(  2.0) 03010 , 03222 , 03424 , 03617 , 03802 ,
        03979 , 04149 , 04313 , 04471 , 04623 ,
(  3.0) 04771 , 04913 , 05051 , 05185 , 05314 ,
        05440 , 05563 , 05682 , 05797 , 05910 ,
(  4.0) 06020 , 06127 , 06232 , 06334 , 06434 ,
        06532 , 06627 , 06720 , 06812 , 06901 ,
(  5.0) 06989 , 07075 , 07160 , 07242 , 07323 ,
        07403 , 07481 , 07558 , 07634 , 07708 ,
(  6.0) 07781 , 07853 , 07923 , 07993 , 08061 ,
        08129 , 08195 , 08260 , 08325 , 08388 ,
(  7.0) 08450 , 08512 , 08573 , 08633 , 08692 ,
        08750 , 08808 , 08864 , 08920 , 08976 ,
\ functions /4/                              hhh 15:37 03.08.98
(  8.0) 09030 , 09084 , 09138 , 09190 , 09242 ,
        09294 , 09344 , 09395 , 09444 , 09493 ,
(  9.0) 09542 , 09590 , 09637 , 09684 , 09731 ,
        09777 , 09822 , 09867 , 09912 , 09956 ,
( 10.0) 10000 ,

: LOG ( u -- u')
  100 /MOD
  10 - ( offset) 2* logtable +
  2@  DUP >R  -  100 */  R> + ; \ interpolate logtable for 1.000 <= u <= 9.999

: FLOG ( f -- f')
  10000 M*  ROT LOG 0  D+  -1 TRIM NIP ;

\ functions /5/                              hhh 17:05 20.07.98
CREATE alogtable
( 0.00) 01000 , 01023 , 01047 , 01071 , 01096 ,
        01122 , 01148 , 01174 , 01202 , 01230 ,
( 0.10) 01258 , 01288 , 01318 , 01348 , 01380 ,
        01412 , 01445 , 01479 , 01513 , 01548 ,
( 0.20) 01584 , 01621 , 01659 , 01698 , 01737 ,
        01778 , 01819 , 01862 , 01905 , 01949 ,
( 0.30) 01995 , 02041 , 02089 , 02137 , 02187 ,
        02238 , 02290 , 02344 , 02398 , 02454 ,
( 0.40) 02511 , 02570 , 02630 , 02691 , 02754 ,
        02818 , 02884 , 02951 , 03019 , 03090 ,
( 0.50) 03162 , 03235 , 03311 , 03388 , 03467 ,
        03548 , 03630 , 03715 , 03801 , 03890 ,
( 0.60) 03981 , 04073 , 04168 , 04265 , 04365 ,
        04466 , 04570 , 04677 , 04786 , 04897 ,
\ functions /6/                              hhh 13:59 03.08.98
( 0.70) 05011 , 05128 , 05248 , 05370 , 05495 ,
        05623 , 05754 , 05888 , 06025 , 06165 ,
( 0.80) 06309 , 06456 , 06606 , 06760 , 06918 ,
        07079 , 07244 , 07413 , 07585 , 07762 ,
( 0.90) 07943 , 08128 , 08317 , 08511 , 08709 ,
        08912 , 09120 , 09332 , 09549 , 09772 ,
( 1.00) 10000 ,

: ALOG ( u -- u')
  10 /MOD  2* alogtable +
  2@  DUP >R  -  10 */  R> + ;  \ interpolate alogtable for 0.000 <= u <= 0.999

: FALOG ( f -- f')
  SWAP S>D ROT  DSHIFT  1000 M/MOD  SWAP ALOG SWAP ;
\ main command                               hhh 17:05 20.07.98
  DECIMAL  3 PLACES

: SFP ( -- )
  INSTALL-SFP
  DECIMAL  3 PLACES ;

\ excise headers                             hhh 17:05 20.07.98
\ EXCISE exp places
\ EXCISE INFLATE DEFLATE
\ EXCISE CONVERT-MANTISSA CONVERT-EXPONENT
\ EXCISE NUMBER? NUMBER?
\ EXCISE NUMBER, INSTALL-SFP
\ EXCISE (FD.) (FD.)
\ EXCISE arg SQRT
\ EXCISE logtable LOG
\ EXCISE alogtable ALOG



