\ The optional Double-Number word set

\ INCLUDE DSK1.TOOLS  \ for debugging

HERE
HEX
\ CODE D+   ( lo hi lo' hi' -- d) \ Moved to kernel
\  C036 , \  *SP+    R0  MOV,  \              22
\  A136 , \  *SP+    TOS ADD,  \ add hi #s    22
\  A580 , \  R0      *SP ADD,  \ add lo #s    18
\  1701 , \  OC IF,            \ carry set?   10
\  0584 , \     TOS INC,       \ incr hi      10
\         \  ENDIF,
\  NEXT,                           \          82
\ ENDCODE

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

: DNEGATE  ( d1 -- d2 )  SWAP INVERT SWAP INVERT 1 M+ ;
: D-       ( d d -- d)   DNEGATE D+ ;
: ?DNEGATE ( d1 n -- d2) 0< IF DNEGATE THEN ;
: DABS     ( d -- d)   DUP ?DNEGATE ;

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
: D.R  ( d n --) >R TUCK DABS <# #S ROT SIGN #> R> OVER - SPACES TYPE ;
: D.   ( d  -- ) 0 D.R SPACE ;

: 4DUP   ( d d -- d d d d ) 2OVER 2OVER ;
: 2NIP   ( d d' -- d')      2SWAP 2DROP ;
: DMAX   ( d d -- d)  4DUP D< IF 2DROP ELSE 2NIP THEN ;
: DMIN   ( d d -- d)  4DUP D< IF 2NIP  ELSE 2DROP THEN ;

HERE SWAP - DECIMAL  CR . .(  bytes)
