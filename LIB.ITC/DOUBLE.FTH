CR .( Optional Double-Number word set)

\ INCLUDE DSK1.TOOLS  \ for debugging

HERE
HEX
: 2LITERAL  ( d -- )
       ?COMP SWAP
       POSTPONE LITERAL
       POSTPONE LITERAL ; IMMEDIATE

CODE 2R@  ( -- d )
       0646 ,        \ TOS PUSH,
       C5A4 , 0002 , \ 2 (RP) TOS MOV,
       C114 ,        \ *RP PUSH,
       NEXT,
ENDCODE

CODE 2INVERT ( d -- -d)
       0556 , \ *SP INV,
       0544 , \ TOS INV,
       NEXT,
ENDCODE

CODE DSIGN   ( d -- d ?)  \ 2DUP XOR
       0646 , C584 , \ TOS PUSH,
       2926 , 0002 , \ 2 (SP) TOS XOR,
       NEXT,
ENDCODE

: 2CONSTANT  ( d -- <text>) CREATE   ,   ,  DOES> 2@ ;
: 2VARIABLE  ( d -- <text>) CREATE 0 , 0 , ;

: D0<  ( d -- ? )  NIP 0< ;
\ : S>D  ( n -- d )  DUP 0< ;
: D2*  ( d -- d')  SWAP S>D NEGATE SWAP 2* ROT 2* ROT + ;

: D2/  ( d -- d')
       DUP 1 AND
       IF  [ TRUE 1 RSHIFT INVERT ] LITERAL  ( HEX 8000)
       ELSE 0
       THEN SWAP 2/ ROT 1 RSHIFT ROT + SWAP ;

: D<   ( d d -- ?) ROT >  IF 2DROP -1  ELSE U<  THEN ;
: D>               D< 0= ;
: DU<  ( d d -- ?) ROT U> IF 2DROP -1  ELSE U<  THEN ;
: D0=  ( d -- ?)   OR 0= ;
: D=   ( d d -- ?) ROT = -ROT = AND ;
: D>S  ( d -- n)   DROP ;

CODE 2OVER ( d1 d2 -- d1 d2 d1)   \ 2x faster
       0646 , C584 ,   \ TOS PUSH,
       C126 , 0006 ,   \ 6 (SP) TOS MOV,
       0646 , C584 ,   \ TOS PUSH,
       C126 , 0006 ,   \ 6 (SP) TOS MOV,
       NEXT,           \ 100
ENDCODE         \ 16 bytes

: 2ROT   ( d d2 d3 -- d2 d3 d) 2>R 2SWAP 2R> 2SWAP ;

\ : DNEGATE  ( d1 -- d2 )  SWAP INVERT SWAP INVERT 1 M+ ;
: DNEGATE  ( d1 -- d1) 2INVERT 1 M+ ;

: D-       ( d d -- d)   DNEGATE D+ ;
: ?DNEGATE ( d1 n -- d2) 0< IF DNEGATE THEN ;
: DABS     ( d -- d)   DUP ?DNEGATE ;

 : M*      ( n1 n2 -- d)       ( signed 16*16->32 multiply)
       DSIGN >R            ( carries sign of the result)
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
          EXIT
       THEN
       DROP ;

: RJUST ( addr len n -- ) OVER - SPACES TYPE ;
: UD.R  ( d n --) >R <# #S #> R> RJUST ;
: D.R   ( d n --) >R TUCK DABS <# #S ROT SIGN #> R> RJUST ;
: D.    ( d  -- ) 0 D.R SPACE ;

: 4DUP   ( d d -- d d d d ) 2OVER 2OVER ;
\ : 2NIP   ( d d' -- d')    2SWAP 2DROP ;

CODE 2NIP  ( d d' -- d')
       C036 , \ *SP+ R0 MOV,
       05C6 , \      SP INCT,
       C580 , \  R0 *SP MOV,
       NEXT,
ENDCODE

: DMAX   ( d d -- d)  4DUP D< IF 2DROP ELSE 2NIP THEN ;
: DMIN   ( d d -- d)  4DUP D< IF 2NIP  ELSE 2DROP THEN ;

HERE SWAP - DECIMAL  CR . .( bytes)
