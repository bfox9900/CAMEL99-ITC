[CC] cr .( Hi-level FORTH Primitives...)
TARGET-COMPILING
SLOWER [IF]
    : HERE   ( -- addr) DP @  ;
[ELSE]
 ( faster HERE speeds up the compiler)
 CODE HERE   ( -- addr) TOS PUSH, TOS STWP,  24 (TOS) TOS MOV,  NEXT, ENDCODE
[THEN]

: ALLOT     ( n --)   DP +! ;
: ,         ( n -- )  HERE ! 2 ALLOT ;
: COMPILE,  ( n -- )  , ;
: C,        ( n -- ) HERE C! 1 ALLOT  ;
: ALIGN     ( -- )   HERE ALIGNED DP ! ;
: PAD       ( -- addr) HERE TPAD @ + ;
: COMPILE   ( -- )  R> DUP 2+ >R @ COMPILE, ;
: IMMEDIATE ( --)   01 LATEST @ 1-  C! ;
: LITERAL   ( n -- n|~) STATE @ IF  COMPILE LIT  COMPILE,  THEN ;  XIMMEDIATE
: ]         ( -- ) STATE ON  ;
: [         ( -- ) STATE OFF ;  XIMMEDIATE
: DEPTH     ( -- n ) SP0 SP@ 2+ - 2/ ;

\ ======================================================================
\ PAB base address
: VDPTOP  ( -- n) 8370 @ 2- ;

\ ======================================================================
\ S T A C K   P R I M I T I V E S
[CC] cr .( Stack primitives ...)  [tc]

: TUCK  ( w1 w2 --  w2 w1 w2 ) SWAP OVER ;

CODE 2>R    ( d -- ) ( r-- n n)
              RP -4 ADDI,          \ 14
              TOS 2 (RP) MOV,      \ 22
             *SP+   *RP MOV,       \ 26
              TOS POP,             \ 22
              NEXT,              \ = 84
              ENDCODE

CODE 2R>     ( -- d )
              TOS PUSH,            \ 28
              SP DECT,             \ 10
             *SP  RPOP,            \ 26
              TOS RPOP,            \ 22
              NEXT,              \ = 88
              ENDCODE

\ *G NOT standard forth. Nice native 9900 instructions
CODE 1+! ( addr -- )  *TOS INC,  TOS POP,  NEXT,   ENDCODE
CODE 1-! ( addr -- )  *TOS DEC,  TOS POP,  NEXT,   ENDCODE

\ =====================================================================
\ C O M P A R I S O N   O P E R A T O R S

TARGET-COMPILING
: U>  ( n n -- ?)  SWAP U< ;
: 0>  ( n -- ?)    1- 0< INVERT ;
: <>  ( n n -- ?)  =  INVERT ;

: UMIN ( u1 u2 -- u )  2DUP U> IF SWAP THEN DROP ;
: UMAX ( u1 u2 -- u )  2DUP U< IF SWAP THEN DROP ;

SLOWER [IF]
    : WITHIN ( u lo hi -- t ) OVER - -ROT - U> ;
[ELSE]
CODE WITHIN   ( n  lo  hi -- flag )
        *SP  TOS  SUB,
        *SP+ *SP  SUB,
         TOS *SP+ SUB,
         TOS CLR,
         NC IF,  TOS SETO, ENDIF,
         NEXT,
         ENDCODE  \ 2 bytes bigger than Forth
[THEN]
