\ Multi-User memory management experiment 

\ Method: Map contiguous pages into all 4K sections of TI-99 RAM

NEEDS MOV,  FROM DSK1.ASM9900
NEEDS DUMP  FROM DSK1.TOOLS
NEEDS PAGED FROM DSK1.SAMSFTH

\ compute SAMS registers for all TI-99 RAM pages
HEX
2000 0B RSHIFT 4000 + CONSTANT R2000  \ R3
3000 0B RSHIFT 4000 + CONSTANT R3000  \ R4
A000 0B RSHIFT 4000 + CONSTANT RA000  \ R10
B000 0B RSHIFT 4000 + CONSTANT RB000  \ R11
C000 0B RSHIFT 4000 + CONSTANT RC000  \ R12
D000 0B RSHIFT 4000 + CONSTANT RD000  \ R13
E000 0B RSHIFT 4000 + CONSTANT RE000  \ R14
F000 0B RSHIFT 4000 + CONSTANT RF000  \ R15

CODE MOVE16
    C036 , C076 , C104 , 1306 , 0584 ,
    0244 , FFFE , CC31 , 0644 , 15FD ,
    C136 ,
NEXT,
ENDCODE



VARIABLE TEMP  \ pointer to pages in use

\ Test version
: MAPALL  ( page# -- )
      ><                \ swap bytes, bank# must be in left byte
      SAMSCARD 0SBO     \ turn on the card
         DUP R2000 !
      1- DUP R3000 !
      1- DUP RD000 !
      1-     RE000 !
      0SBZ              \ turn off card
;

: *R1      R1 **  ;
: *R1+     R1 *+ ;


CODE USER2MEM  ( -- ) \ fixed pages
        R12 1E00 LI,
        0 SBO,             \ sams card on
        4000 LWPI,         \ WKSP = SAMS registers
        R3  FFFF MOV,
        R4  FEFE MOV,
        R10 FDFD MOV,
        R11 FCFC MOV,
        R12 FBFB MOV,
        R13 FAFA MOV,
        R14 F9F9 MOV,
        R15 F8F8 MOV,
        8300 LWPI,        \ return to Forth WKSP
        0 SBZ,
        NEXT,
        ENDCODE


CODE MAPFAST ( SAMSpage# --)
        R4 SWPB,      \ R4 holds the initial SAMS page
        R12 1E00 LI,
        R1  4004 LI,   \ first SAMS register to use
        0 SBO,         \ card enabled
\ low RAM mapping
        R4 *R1+ MOV,   \ MAP 2000
        R4 DEC,
        R4 *R1  MOV, \ MAP 3000
\ HI RAM mapping
        R1 4014 LI,    \ HI ram SAMS register for A000
        R4 *R1+ MOV,  \ MAP A000
        R4 DEC,
        R4 *R1+ MOV,  \ MAP B000
        R4 DEC,
        R4 *R1+ MOV,  \ MAP C000
        R4 DEC,
        R4 *R1+ MOV,  \ MAP D000
        R4 DEC,
        R4 *R1+ MOV,  \ MAP E000
        R4 DEC,
        R4 *R1+ MOV,  \ MAP F000
        R4 DEC,
        0 SBZ,        \ card off
        R4 POP,       \ refill Forth top of stack register
        NEXT,
        ENDCODE


CREATE MAP1
      0000 , 0101 , 0202 , 0303 ,
      0404 , 0505 , 0606 , 0707 ,
      0808 , 0909 , 0A0A , 0B0B ,
      0C0C , 0D0D , 0E0E , 0F0F ,

CREATE MAP2
      0000 , 0101 , F8F8 , F9F9 ,
      0404 , 0505 , 0606 , 0707 ,
      0808 , 0909 , FAFA , FBFB ,
      FCFC , FDFD , FEFE , FFFF ,
