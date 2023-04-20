\ S T R I N G   T H I N G S

TARGET-COMPILING

\ CAMEL Forth calls this ">COUNTED"
: PLACE   ( src n dst -- ) 2DUP C! 1+ SWAP CMOVE ;

SLOWER [IF]
: /STRING ( caddr1 u1 n - caddr2 u2 ) TUCK - >R + R> ; \ 10 bytes

[ELSE]

CODE /STRING ( c-addr1 u1 n -- c-addr2 u2 ) \ ~20uS!!       Clks
              TOS   *SP  SUB,                               \ 18
              TOS 2 (SP) ADD,                               \ 22
              TOS POP,                         \ refill TOS   22
              NEXT,                            \ 8 bytes      62  ~20uS
              ENDCODE
[THEN]

: S,       ( c-addr u -- ) HERE OVER 1+ ALLOT PLACE  ALIGN ;

\ run-time action of S"   (For ITC Forth only)
: (S")    ( -- c-addr u) R>  COUNT  2DUP + ALIGNED  >R ;
