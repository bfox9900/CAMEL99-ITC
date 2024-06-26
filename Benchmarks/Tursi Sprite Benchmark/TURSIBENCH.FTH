\ TURSI'S TI-99 Sprite Benchmark    Updated Feb 2024 B. Fox
\ Demonstration shows different ways to improve code speed

NEEDS MOV,     FROM DSK1.ASM9900
NEEDS MARKER   FROM DSK1.MARKER
NEEDS LOCATE   FROM DSK1.DIRSPRIT
NEEDS INLINE[  FROM DSK1.INLINE
NEEDS ELAPSE   FROM DSK1.ELAPSE


MARKER /TURSI

( vanilla Forth using DSK1.DIRSPRIT library )
DECIMAL
: TURSI.FORTH
       100 0
       DO
           239 0 DO    I   0  0 LOCATE       LOOP
           175 0 DO  239   I  0 LOCATE       LOOP
           0 239 DO    I 175  0 LOCATE   -1 +LOOP
           0 175 DO    0   I  0 LOCATE   -1 +LOOP
       LOOP ;

\ ITC 56    v2.62b: 53,  v2.66: 47.00,
\ Feb 2022: Same Classic99, Same libs
\           v2.67: 48.68,  v2.69: 47.8
\ DTC 2.0  50 secs         v2.68  44.1


( Forth using DSK1.DIRSPRIT library Fox words )
\ Thinking FORTH
\ Add words to the language to do what you actually need
\ LOCATE is too general purpose.
\ We only want to move 1 SPRITE horizontally or vertically

DECIMAL
: TURSI.FOX
       100 0
       DO
           239 0 DO    I  0 SP.X VC!      LOOP
           175 0 DO    I  0 SP.Y VC!      LOOP
           0 239 DO    I  0 SP.X VC!   -1 +LOOP
           0 175 DO    I  0 SP.Y VC!   -1 +LOOP
       LOOP ;
\ ITC v2.69   31.5
\ DTC V2.68   28.9

HEX 300 CONSTANT $300
    301 CONSTANT $301

DECIMAL
( more direct translation of Tursi ASM code to Forth)
: TURSI.OPT
      100 0
      DO
           239 0 DO   I $301 VC!     LOOP
           175 0 DO   I $300 VC!     LOOP
           0 239 DO   I $301 VC! -1  +LOOP
           0 175 DO   I $300 VC! -1  +LOOP
      LOOP ;

\ ITC 30    v2.62b  28
\ Feb 2022: Same Classic99, Same libs
\           v2.67:          28.46
\ v2.69                     27.9
\ V2.69   W/ optimized VC!  26.16

\ -DTC
\  2.0                      27
\ V2.68                     24.0


( Forth using DSK1.DIRSPRIT library words )
\ Method: compute the sprite address at compile time.
: ]FOLD      ]  POSTPONE LITERAL ;  IMMEDIATE

DECIMAL
: TURSI.OPT2
       100 0
       DO
           239 0 DO    I [ 0 SP.X ]FOLD  VC!     LOOP
           175 0 DO    I [ 0 SP.Y ]FOLD  VC!      LOOP
           0 239 DO    I [ 0 SP.X ]FOLD  VC!   -1 +LOOP
           0 175 DO    I [ 0 SP.Y ]FOLD  VC!   -1 +LOOP
       LOOP ;
\ itc v2.69  27.4

( optimize inner loop code)
: TURSI.INLINE
      100 0
      DO
  INLINE[ 239 0 ] DO  INLINE[ I $301 VC! ]     LOOP
  INLINE[ 175 0 ] DO  INLINE[ I $300 VC! ]     LOOP
  INLINE[ 0 239 ] DO  INLINE[ I $301 VC! -1 ] +LOOP
  INLINE[ 0 175 ] DO  INLINE[ I $300 VC! -1 ] +LOOP
      LOOP ;
\ *ITC*
\ v2.66  21.43  v2.67 new vdp driver 20.31 ( different Classic99)
\ v2.69  w/new VC!                   22.0
\ *DTC*
\  v2.68 w/new VC!                   18.8


\ ASM BOOSTER :-) ..........................

HEX
8C00 CONSTANT VDPWD               \ vdp ram write data PORT
8C02 CONSTANT VDPWA               \ vdp ram read/write address PORT

CODE MoveSprite ( Vaddr2 Vaddr1 SprAddr direction -- )
    ( R4 = direction)
    R1 POP,                  \ Sprite table address
    R1 4000  ORI,            \ set control bits to write mode (01)
    R2 POP,                  \ 1st screen location
    R3 POP,                  \ last screen location
\ port addresses in registers     
    R0  VDPWD LI, 
    R13 VDPWA LI,  
    R8 STWP,                  \ workspace in kept in R8
    0 LIMI,
    BEGIN,
        3 R8 () R13 ** MOVB,   \ write odd byte of  R1
        R1 R13 ** MOV,         \ MOV write the even byte
    
        5 R8 () R0 ** MOVB,    \ write char to vdp data port
        TOS R2 ADD,
        R2  R3 CMP,
    EQ UNTIL,
    TOS POP,                   \ refill TOS register R4
    NEXT,
ENDCODE

DECIMAL
: TURSI.BOOSTER
    100
    0 DO
    \ end  start  spr dir
      239    0   $301  1 MoveSprite
      175    0   $300  1 MoveSprite
        0  239   $301 -1 MoveSprite
        0  175   $300 -1 MoveSprite
    LOOP
;
( ITC ~5.3 seconds)
( DTC ~6.0 seconds)


HEX
8C00 CONSTANT VDPWD         \ vdp ram write data
8C02 CONSTANT VDPWA         \ vdp ram read/write address

\ MACRO to setup VDP write address from a register argument
: VDPWA, ( reg -- )
       DUP VDPWA @@  MOVB,   \ write 1st byte of address to VDP chip
       DUP           SWPB,
           VDPWA @@  MOVB,   \ write 2nd byte of address to VDP chip
;

\ Macro to convert integer to 9900 byte at compile time
: byte  ( n -- c )
        DUP FF > ABORT" Not a byte"
        >< ;  \ swap bytes for 9900

CODE MOVERIGHT ( -- )
          0 LIMI,
          R3 CLR,            \ for x=0
DECIMAL   R8 239 byte LI,    \ to 239
          BEGIN,
HEX          R0 4301 >< LI,   ( >< swaps bytes at compile time)
             R0 VDPWA,
             R3 VDPWD @@ MOVB,
             R3 1 byte AI,      \ next x
             R3 R8 CMP,
          EQ UNTIL,
          NEXT,
          ENDCODE

CODE MOVEDOWN
          0 LIMI,
          R4 CLR,              \ for y=0
DECIMAL   R8 175 byte LI,      \ to 175
          BEGIN,
HEX          R0 4300 >< LI,
             R0 VDPWA,
             R4 VDPWD @@ MOVB,
             R4  1 byte AI,    \ next y
             R4 R8 CMP,
          EQ UNTIL,
          NEXT,
          ENDCODE

CODE MOVELEFT
          0 LIMI,
DECIMAL   R3 239 byte LI,       \ for x=239 downto 0
HEX       BEGIN,
             R0 4301 >< LI,
             R0 VDPWA,
             R3 VDPWD @@ MOVB,
             R3 -0100 AI,        \ next x
          EQ UNTIL,
          NEXT,
          ENDCODE

CODE MOVEUP
          0 LIMI,
DECIMAL   R4 175 byte LI,        \ * for y=175 downto 0
          BEGIN,
HEX          R0 4300 >< LI,
             R0 VDPWA,
             R4 VDPWD @@ MOVB,
             R4  -0100 AI,
          EQ UNTIL,
          NEXT,
          ENDCODE

DECIMAL
: TURSI.CODE
    CLEAR
\    Ascii   color  y x spr#
    [CHAR] *   2    1 1  0 SPRITE
    1 MAGNIFY
    100 0
    DO
       MOVERIGHT
       MOVEDOWN
       MOVELEFT
       MOVEUP
    LOOP ;
 \ ~ 5 seconds

( Change the problem <smiley face> )
( will anybody see the difference ...)
( if we move the sprite 11 pixels in each move?)
DECIMAL
: TURSI.CHEAT
    100 0
    DO
        239 0 DO    I   0  0 LOCATE    11 +LOOP
        175 0 DO  239   I  0 LOCATE    11 +LOOP
        0 239 DO    I 175  0 LOCATE   -11 +LOOP
        0 175 DO    0   I  0 LOCATE   -11 +LOOP
    LOOP ;

: TITLE  PAGE 3 12 AT-XY   ;  \ resets timer 
: RESET  BEEP  TICKER OFF ;
: .TIME   5 13 AT-XY  .ELAPSED 2000 MS ;

: DO-TESTS 
   TITLE ." Using LOCATE command"          RESET TURSI.FORTH   .TIME
   TITLE ." Using SP.X, SP.Y VDP arrays "  RESET TURSI.FOX     .TIME 
   TITLE ." Using CONSTANT VDP address"    RESET TURSI.OPT     .TIME
   TITLE ." Using constant folding"        RESET TURSI.OPT2    .TIME
   TITLE ." Using INLINE[] optimizer"      RESET TURSI.INLINE  .TIME
   TITLE ." Using MoveSprite ASM function" RESET TURSI.BOOSTER .TIME
   TITLE ." Using Forth Assembler"         RESET TURSI.CODE    .TIME
   TITLE ." Forth LOCATE, cheating :)"     RESET TURSI.CHEAT   .TIME 
;

: TITLE-PAGE 
15 SCREEN 
PAGE ." * Tursi's Language Benchmark * "
CR 
CR ." This tests sprite movement speed"
CR ." This program uses different"
CR ." optimization techiques that can"
CR ." be done with Camel99 Forth"
CR
CR ." 1. Forth with LOCATE command"
CR ." 2. SP.X SP.Y VDP arrays"
CR ." 3. CONSTANT for VDP address"
CR ." 4. Constant folding SP.X SP.Y"
CR ." 5. INLINE[  ]  optimizer" 
CR ." 6. ASM MoveSprite function"
CR ." 7. Optimized ASM code"
CR ." 8. Forth LOCATE 'cheating'"
CR
CR ." Press a KEY to run the tests"
KEY DROP ;


: RUN  
    TITLE-PAGE 
    PAGE   
    [CHAR] *  9  0 0  0 SPRITE 
    1 MAGNIFY 
    DO-TESTS 
    CR 
    CR 
    DELALL
    CR ." Done "
;


