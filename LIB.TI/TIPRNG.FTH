\ TI-FORTH RANDOM NUMBER GENERATOR
HEX

83C0 CONSTANT SEED   \ TI O/S has a number incrementing in main menu

: RNDW    ( -- n)
          SEED @ 6FE5 * 7AB9 + 5 SRC DUP SEED ! ; \ 24+4=28 bytes

\ CODE: RNDW    ( -- n)    \ Forth version if you need speed
\              TOS PUSH,
\              83C0 @@ R3 MOV,
\              R2 6FE5 LI,
\              R2 R3 MPY,
\              TOS 7AB9 ADDI,
\              TOS 5 SRC,
\              TOS 83C0 @@ MOV,
\              NEXT,
\              END-CODE   \ 24 bytes

: RND     ( n -- n') RNDW ABS SWAP MOD ;

