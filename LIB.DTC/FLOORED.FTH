( ANS Forth signed and floor division )
( Thanks to Brad Rodriguez, Camel Forth  MSP430 )

 : ?NEGATE    ( n1 n2 -- n3)                     (  negate n1 if n2 negative)
              0< IF NEGATE THEN ;                ( ...a common factor)


 : DNEGATE    ( d1 -- d2 )                       ( negate double precision)
              SWAP NEGATE SWAP NEGATE 1 M+ ;

 : ?DNEGATE   ( d1 n -- d2)                      ( negate d1 if n negative)
              0< IF DNEGATE THEN ;               ( ...a common factor)

 : DABS       ( d -- d)  DUP ?NEGATE ;

 : SM/REM     ( d1 n1 -- n2 n3 )                ( symmetric signed div.)
              2DUP XOR >R                        ( sign of quotient)
              OVER >R                            ( sign of remainder)
              ABS >R DABS R> UM/MOD
              SWAP R> ?NEGATE
              SWAP R> ?NEGATE ;

( Ref. dpANS-6 section 3.2.2.1.)
 : FM/MOD     ( d1 n1 -- n2 n3)                  ( floored signed div'n)
              DUP >R                             ( divisor)
              2DUP XOR >R                        ( sign of quotient)
              >R                                 ( divisor)
              DABS R@ ABS UM/MOD
              SWAP R> ?NEGATE SWAP               ( apply sign to remainder)
              R> 0<
              IF                                 ( if quotient negative.)
                NEGATE OVER
                IF                               ( if remainder nonzero,)
                   R@ ROT -  SWAP 1-             ( adjust rem,quot)
               THEN
              THEN
              R> DROP ;

 : M*         ( n1 n2 -- d)                      ( signed 16*16->32 multiply)
              2DUP XOR >R                         ( carries sign of the result)
              SWAP ABS SWAP ABS UM*
              R> ?DNEGATE ;

: */MOD       ( n1 n2 n3 -- n4 n5)  >R M* R> FM/MOD ; \ n1*n2/n3, rem&quot

: S>D         ( n -- d)     DUP 0< ;

: /MOD        ( n1 n2 -- n3 n4)  >R S>D R> FM/MOD ;  \ signed divide/rem'dr
: *           ( n n -- n)   UM* DROP ;
: /           ( n n -- n)   /MOD NIP ;           \ these are smaller than CODE words. (4 bytes each)
: MOD         ( n n -- n)   /MOD DROP ;
: */          ( n n n -- n) */MOD NIP ;
