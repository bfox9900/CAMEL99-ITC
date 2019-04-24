\ The optional Double-Number word set

  INCLUDE DSK1.TOOLS  \ for debugging

HERE
\    D2/   D2*   DU<  D0=   D0<  D.  D<   D>S  M+ 2ROT
\    2CONSTANT  2LITERAL    2VARIABLE
\    DABS D.R  D=    DMAX   DMIN   D-   DNEGATE
\    M*/
\    2VALUE ( not implemented)

HEX
 CODE D+   ( lo hi lo' hi' -- d)  \ hi'is in TOS register  *TESTED*
      C084 ,   \  TOS R2 MOV,   \ hi'->r2
      C076 ,   \ *SP+ R1 MOV,   \ lo'->R1
      C136 ,   \ *SP+ TOS MOV,  \ hi ->tos
      A581 ,   \  R1 *SP A,     \ add low in place on data stack
      1701 ,   \  OC IF,        \ carry flag set?
      0584 ,   \    TOS INC,    \ incr hi
               \  ENDIF,
      A102 ,   \  R2 TOS A,     \ add hi' to hi
      NEXT,
ENDCODE

\ CODE: 2R@  ( -- d )           \ fixed June 18 2019 V2.0.17
\             TOS PUSH,
\             2 (RP) TOS MOV,
\            *RP PUSH,
\             NEXT,             \ = 80
\             END-CODE

: 2LITERAL  ( d -- )
            ?COMP SWAP
            POSTPONE LITERAL
            POSTPONE LITERAL ; IMMEDIATE

: 2CONSTANT  ( d -- <text>) CREATE   ,   ,  DOES> 2@ ;
: 2VARIABLE  ( d -- <text>) CREATE 0 , 0 , ;

: D0<  ( d -- ? )  NIP 0< ;
: S>D  ( n -- d )  DUP 0< ;
: D2*  ( d -- d')  SWAP S>D NEGATE SWAP 2* ROT 2* ROT + ;

: D2/  ( d -- d')
       DUP 1 AND
       IF  [ TRUE 1 RSHIFT INVERT ] LITERAL  ( HEX 8000)
       ELSE 0
       THEN SWAP 2/ ROT 1 RSHIFT ROT + SWAP ;

: D<   ( d d -- ?) ROT >  IF 2DROP -1  ELSE U<  THEN ;
: DU<  ( d d -- ?) ROT U> IF 2DROP -1  ELSE U<  THEN ;
: D0=  ( d -- ?)   OR 0= ;
: D=   ( d d -- ?) ROT = -ROT = AND ;
: D>S  ( d -- n)   DROP ;

\ : 2OVER  ( d d2 -- d d2 d) 2>R 2DUP  2R> 2SWAP ;   \ slow
\ : 2OVER  ( d d2 -- d d2 d) 3 PICK 3 PICK ; \ 20% faster
\ : 2OVER  ( d d2 -- d d2 d)  4TH 4TH ;      \ 60% faster!

CODE 2OVER ( d1 d2 -- d1 d2 d1)   \ 2x faster
            0646 , C584 ,   \ TOS PUSH,
            C126 , 0006 ,   \ 6(SP) TOS MOV,
            0646 , C584 ,   \ TOS PUSH,
            C126 , 0006 ,   \ 6(SP) TOS MOV,
            NEXT,           \ 100
            ENDCODE   \ 16 bytes!!

: 2ROT   ( d d2 d3 -- d2 d3 d) 2>R 2SWAP 2R> 2SWAP ;

: 4DUP   ( d d -- d d d d ) 2OVER 2OVER ;
: 2NIP   ( d d' -- d')      2SWAP 2DROP ;
: DMAX   ( d d -- d)  4DUP D< IF 2DROP ELSE 2NIP THEN ;
: DMIN   ( d d -- d)  4DUP D< IF 2NIP ELSE 2DROP THEN ;

\ : ?NEGATE  ( n1 n2 -- n3) 0< IF NEGATE THEN ;
: DNEGATE  ( d1 -- d2 )  SWAP INVERT SWAP INVERT 1 M+ ;
: D-       ( d d -- d)   DNEGATE D+ ;
: ?DNEGATE ( d1 n -- d2) 0< IF DNEGATE THEN ;
: DABS     ( d -- d)     DUP ?DNEGATE ;

 : M*      ( n1 n2 -- d)          ( signed 16*16->32 multiply)
           2DUP XOR >R            ( carries sign of the result)
           SWAP ABS SWAP ABS UM*
           R> ?DNEGATE ;

\ from GForth
: M*/  ( d1 n1 +n2 -- d2 )  ( 52.9 mS LOL! )
       >R                           \ save divisor
       S>D >R                       \ save multiplier sign
       ABS -ROT
       S>D R> XOR R> SWAP           \ compute signs
       >R >R                        \ push signs
       DABS ROT TUCK UM* 2SWAP UM* SWAP >R 0 D+  \ mult. step, add sign
       R> -ROT R@ UM/MOD -ROT R> UM/MOD -ROT     \ divide step
       R>                                        \ get sign data
       IF                                        \ add sign with logic
          IF
            1 0 D+
          THEN
          DNEGATE
       ELSE
          DROP
       THEN ;

\ print un-signed DOUBLE
\ : DU.  ( u -- )  <#  #S  #>  TYPE SPACE ;
  : D.R  ( d n --) >R TUCK DABS <# #S ROT SIGN #> R> OVER - SPACES TYPE ;
  : D.   ( d  -- ) 0 D.R SPACE ;

\ non-standard: convert stack string to double number (Like ?NUMBER in CAMEL Forth)
: ?DNUMBER ( addr len -- d ?)
            OVER C@ [CHAR] - = DUP >R      \ test for minus, push result
            IF 1 /STRING THEN
            0 0 2SWAP >NUMBER NIP 0=       \ convert return success flag
            R> IF >R DNEGATE R> THEN  ;    \ if minus, dnegate

\ examples
DECIMAL
 S" 1" ?DNUMBER       DROP 2CONSTANT 1.
 S" 3141262" ?DNUMBER DROP 2CONSTANT PI

HERE SWAP - DECIMAL  CR . .(  bytes)
HEX
