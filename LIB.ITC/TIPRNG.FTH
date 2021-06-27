\ TI-FORTH RANDOM NUMBER GENERATOR

INCLUDE DSK1.TOOLS
INCLUDE DSK1.ASM9900

HEX
83C0 CONSTANT SEED   \ TI O/S has a number incrementing in main menu

\ : RNDW    ( -- n)
\          SEED @ 6FE5 * 7AB9 + 5 SRC DUP SEED ! ; \ 24+4=28 bytes

 CODE RNDW    ( -- n)    \ Code version if you need speed
              TOS PUSH,
              SEED @@ R3 MOV,
              R2 6FE5 LI,
              R2 R3 MPY,
              TOS 7AB9 AI,
              TOS 5 SRC,
              TOS SEED @@ MOV,
              NEXT,
              ENDCODE   \ 24 bytes

: RND     ( n -- n') RNDW ABS SWAP MOD ;
