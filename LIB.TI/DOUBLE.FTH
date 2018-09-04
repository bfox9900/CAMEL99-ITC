\ The optional Double-Number word set

INCLUDE DSK1.TOOLS.F  \ for debugging

\    D2/   D2*   DU<  D0=   D0<  D.  D<   D>S  M+ 2ROT
\    2CONSTANT  2LITERAL    2VARIABLE
\    DABS D.R  D=    DMAX   DMIN   D-   DNEGATE

\    M*/    ( not implemented)
\    2VALUE ( not implemented)

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
\             NEXT,               \ = 80
\             END-CODE

: 2LITERAL  ( d -- )
            ?COMP SWAP 
            POSTPONE LITERAL
            POSTPONE LITERAL ; IMMEDIATE

: 2CONSTANT  ( d -- <text>) CREATE  ,  ,  DOES> 2@ ;
: 2VARIABLE  ( d -- <text>) CREATE 0 , 0 , ;

: D0<  ( d -- ? )  NIP 0< ;
: S>D  ( n -- d )  DUP 0< ;
: D2*  ( d -- d')  SWAP S>D NEGATE SWAP 2* ROT 2* ROT + ;

: D2/  ( d -- d')
       DUP 1 AND
       IF  [ TRUE 1 RSHIFT INVERT ] LITERAL  ( -- >8000)
       ELSE 0
       THEN SWAP 2/ ROT 1 RSHIFT ROT + SWAP ;

: D<   ( d d -- ?) ROT >  IF 2DROP -1  ELSE U<  THEN ;
: DU<  ( d d -- ?) ROT U> IF 2DROP -1  ELSE U<  THEN ;
: D0=  ( d -- ?)   OR 0= ;
: D=   ( d d -- ?) ROT = -ROT = AND ;
: D>S  ( d -- n)   DROP ;


\ : 2OVER  2>R 2DUP  2R> 2SWAP ;   \ slow
: 2OVER  ( d d2 -- d d2 d)  3 PICK 3 PICK ; \ 20% faster
\ : 2OVER  4TH 4TH ;             \ 60% faster!

: 2ROT   ( d d2 d3 -- d2 d3 d) 2>R 2SWAP 2R> 2SWAP ;

: 4DUP   ( d d -- d d d d ) 2OVER 2OVER ;
: 2NIP   ( d d' -- d')      2SWAP 2DROP  ;
: DMAX   ( d d -- d)  4DUP D< IF 2DROP ELSE 2NIP THEN ;
: DMIN   ( d d -- d)  4DUP D< IF 2NIP ELSE 2DROP THEN ;

\ m*/ ( d n1 n2 -- d*n1/n2 )

: ?NEGATE    ( n1 n2 -- n3) 0< IF NEGATE THEN ;
: DNEGATE    ( d1 -- d2 )   SWAP INVERT SWAP INVERT 1 M+ ;
: D-         ( d d -- d) DNEGATE D+ ;
: ?DNEGATE   ( d1 n -- d2)  0< IF DNEGATE THEN ;
: DABS       ( d -- d)      DUP ?NEGATE ;

\ print  un-signed DOUBLE
: DU.  ( u -- ) <#  #S  #>  TYPE SPACE ;

: D.R  ( d n --)
       >R TUCK DABS <# #S ROT SIGN #> R> OVER - SPACES TYPE ;

: D.   (  n -- ) 0 D.R SPACE ;

: ?DNUMBER ( addr len -- d ? )  \ flag is true on good conversion
           0 0 2SWAP >NUMBER NIP 0= ;

\ DECIMAL
\ : 1.    ( -- d ?)  S" 1" ?DNUMBER ;
\ : PI    ( -- d ?)  S" 3141262" ?DNUMBER ;


