\ set text mode
HEX
: TEXT ( -- )
      0F0 DUP 83D4 C! \ KSCAN re-writes VDP Reg1 with this byte

( -- F0) 01 VWTR  \ VDP register 1: bit3 = 1 sets the TEXT Mode
      00 DUP 2 VWTR  400 * VPG !  ( DEFAULTS FROM EDITOR ASSEMBLER)
      0E  3 VWTR  \ color table
      01  4 VWTR  \ pattern table
      06  5 VWTR  \ sprite attribute table
       1  6 VWTR  \ sprite descriptor table is set
      12  7 VWTR  \ VDP register 7. FG/BG color
       2 VMODE !
      28 C/L!
 ;
