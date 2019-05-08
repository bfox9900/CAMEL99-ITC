\ TI sound list assembler.
\ Assembles TI sound lists in VDP RAM that are
\ compatible with VDP Background sound player  
\ (VDPBGSND.F)

NEEDS DUMP  FROM DSK1.TOOLS
NEEDS PLAY$ FROM DSK1.VDPBGSND
NEEDS (HZ)  FROM DSK1.SOUND

\ sound byte "assembler" commands compile values for the
\ currently selected generator. (GEN1 GEN2 GEN3 GEN4)
DECIMAL
: HZ,     ( f -- )     (HZ) SPLIT VC, VC,   ;
: DB,     ( level -- ) (DB) VC,  ;
: MUTE,   ( -- )       -30 DB,   ;
: MS,     ( n -- )     4 RSHIFT VC, ;  \ ms/16 = 1/60

\ turn all sound off
HEX
: SILENT, ( -- )  9F VC,  BF VC,  DF VC,  FF VC, ;

\ noise channel selects generator 4 by default
: NOISE,  ( n -- )  0F AND  GEN4 OSC @ OR  VC,  ;

DECIMAL
: SOUND: ( <text> -- ) VCREATE  !CSP ;

\ stack starting Vaddress & make space for string length
: [[     ( -- vaddr)   VHERE 0 VC, ;

\ back-fill string length into vaddr
: ]]     ( vaddr -- )  VHERE OVER - 1- SWAP VC! ;

\ mark end of sound list, check for clean stack
: ;SOUND ( -- )  /VEND ?CSP ;


\ sound assembler version
DECIMAL
SOUND: EXPLODE2
\ GEN3 controls Noise Generator Frequency
   [[ GEN1 MUTE, GEN2 MUTE, GEN3 MUTE, 7 NOISE, 0 DB,
      GEN3 999 HZ, ]] 80 MS, \ Parsec used "7". Sounds same as 999 Hz.
   GEN4                      \ control noise generator volume
   [[  -2 DB, ]]  96 MS,
   [[  -4 DB, ]] 112 MS,
   [[  -6 DB, ]] 128 MS,
   [[  -8 DB, ]] 144 MS,
   [[ -10 DB, ]] 256 MS,
   [[ -12 DB, ]] 272 MS,
   [[ -14 DB, ]] 288 MS,
   [[ -16 DB, ]] 304 MS,
   [[ -18 DB, ]] 320 MS,
   [[ -20 DB, ]] 336 MS,
   [[ -22 DB, ]] 352 MS,
   [[ -24 DB, ]] 368 MS,
   [[ -26 DB, ]] 384 MS,
   [[ -28 DB, ]] 768 MS,
   [[ -30 DB, ]]   0 MS,
;SOUND


\ create sound lists with the sound assembler
DECIMAL
SOUND: TONE
      GEN1 [[ 1000 HZ, 0 DB, ]] 1000 MS,
;SOUND

DECIMAL
SOUND: 2BEEP
      GEN1
      [[ 900 HZ, -4 DB, ]] 200 MS,
      [[ MUTE, ]] 20 MS,
      [[ 750 HZ,  0 DB, ]] 160 MS,
;SOUND

\ raw sound list format
HEX
VCREATE EXPLODE
       VBYTE 7,9F,BF,DF,E7,F0,C0,07,5
       VBYTE 1,F1,6
       VBYTE 1,F2,7
       VBYTE 1,F3,8
       VBYTE 1,F4,9
       VBYTE 1,F5,10
       VBYTE 1,F6,11
       VBYTE 1,F7,12
       VBYTE 1,F8,13
       VBYTE 1,F9,14
       VBYTE 1,FA,15
       VBYTE 1,FB,16
       VBYTE 1,FC,17
       VBYTE 1,FD,18
       VBYTE 1,FE,30
       VBYTE 1,FF,0
/VEND

