\ TI sound list assembler.   B Fox  update  Apr 2024
\ Assembles TI sound lists in VDP RAM that are
\ compatible with VDP Background sound player  
\ (isrsound.fth)

NEEDS DUMP    FROM DSK1.TOOLS
NEEDS (HZ)    FROM DSK1.SOUND
NEEDS VHERE  FROM DSK1.VDPMEM

\ .............................................
\ ISR sound list player 
HEX
 83C2 CONSTANT AMSQ      \ interrupt DISABLE bits
\ AMSQ bit meaning:
\ 80 all interrupts disabled
\ 40 motion disabled
\ 20 Sound disabled
\ 10 quit key disabled

\ VDP byte string compiler
: ?BYTE ( n -- ) FF00 AND  ABORT" Not a byte" ;

: VBYTE ( -- )
         BEGIN  [CHAR] , PARSE-WORD DUP
         WHILE
            EVALUATE DUP ?BYTE
            VC,
         REPEAT
         2DROP ;

: /VEND   0 VC, 0 VC, ;   \ end the list with 2 bytes

CODE 0LIMI ( -- )  0300 , 0000 , NEXT, ENDCODE
CODE 2LIMI ( -- )  0300 , 0002 , NEXT, ENDCODE

HEX
: ISRPLAY ( addr -- )
            0LIMI                     \ interrupts off
            83CC !                    \ Vaddr -> sound table
            AMSQ C@  5 AND AMSQ C!    \ enable sound interrupts
            01 83CE C!                \ trigger sound list processing
            83FD C@  01 OR 83FD C!    \ set "VRAM is source" flag
            2LIMI ;                   \ interrupts on

\ ..........................................................
\ Sound List Assembler 
\ sound byte "assembler" commands compile values for the
\ currently selected generator (GEN1 GEN2 GEN3 GEN4) into VDP RAM.
\ They use the words (HZ) and (DB) from the sound libary
\ to mix the correct oscillator or attenuator values for 
\ the active signal generator channel.
DECIMAL
: HZ,     ( f -- )     (HZ) SPLIT VC, VC,   ;
: DB,     ( level -- ) (DB) VC,  ;
: MS,     ( n -- )     4 RSHIFT VC, ;  \ ms/16 = 1/60

\ turn sounds off
HEX
: MUTE,   -30 DB, ;
: SILENT, ( -- )  9F VC,  BF VC,  DF VC,  FF VC, ;


\ noise channel selects generator 4 by default
: NOISE,  ( n -- )  0F AND  GEN4 OSC @ OR  VC,  ;

\ ** NEW **  sound words play them selves when invoked 
DECIMAL
: SOUND: ( <text> -- ) 
     VCREATE VHERE ,  !CSP 
     DOES> @ ISRPLAY ;

\ VDP string starter. Make space for string length
: $[     ( -- vaddr)  VHERE 0 VC, ;

\ VDP end string. Updates the string size byte in VDP RAM
: ],    ( vaddr -- )  VHERE OVER - 1- SWAP VC! ;

\ mark end of sound list, check for clean stack
: ;SOUND ( -- )  0 VC,  ?CSP ;

\
\ *********************************************
\        * SET THE VDP RAM POINTER *
     
      1000 VP !  
\
\ *********************************************
\
\ sound assembler version of PARSEC explosion 
DECIMAL
SOUND: EXPLODE
\ GEN3 controls Noise Generator Frequency
   \ Parsec used "7". Sounds same as 999 Hz.
   $[ GEN1 MUTE, GEN2 MUTE, GEN3 MUTE, 7 NOISE, 0 DB, GEN3 999 HZ, ], 80 MS, 
   GEN4                   
   $[  -2 DB, ],  96 MS,  \ Fade NOISE volume down slowly
   $[  -4 DB, ], 112 MS,
   $[  -6 DB, ], 128 MS,
   $[  -8 DB, ], 144 MS,
   $[ -10 DB, ], 256 MS,
   $[ -12 DB, ], 272 MS,
   $[ -14 DB, ], 288 MS,
   $[ -16 DB, ], 304 MS,
   $[ -18 DB, ], 320 MS,
   $[ -20 DB, ], 336 MS,
   $[ -22 DB, ], 352 MS,
   $[ -24 DB, ], 368 MS,
   $[ -26 DB, ], 384 MS,
   $[ -28 DB, ], 768 MS,
   $[ -30 DB, ],   0 MS,
;SOUND

\ The same list as HEX numbers  
\ Which one is easier to understand?
\ HEX
\ VCREATE EXPLODE2
\    VBYTE 7,9F,BF,DF,E7,F0,C0,07,5
\    VBYTE 1,F1,6
\    VBYTE 1,F2,7
\    VBYTE 1,F3,8
\    VBYTE 1,F4,9
\    VBYTE 1,F5,10
\    VBYTE 1,F6,11
\    VBYTE 1,F7,12
\    VBYTE 1,F8,13
\    VBYTE 1,F9,14
\    VBYTE 1,FA,15
\    VBYTE 1,FB,16
\    VBYTE 1,FC,17
\    VBYTE 1,FD,18
\    VBYTE 1,FE,30
\    VBYTE 1,FF,0
\ /VEND

\ example sound lists with the sound assembler
DECIMAL
SOUND: TONE
 GEN1 $[ 1000 HZ, 0 DB, ], 1000 MS,
      $[ -30 DB, ],   0 MS,
;SOUND

DECIMAL
SOUND: 2BEEP
 GEN1 $[ 900 HZ, -4 DB, ], 200 MS,
      $[ -30 DB, ], 20 MS,
      $[ 750 HZ,  0 DB, ], 160 MS,
      $[ -30 DB, ], 0 MS,
;SOUND

\ ********************************
\  SAVE VDP MEMORY 